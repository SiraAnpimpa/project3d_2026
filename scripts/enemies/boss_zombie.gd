extends NormalZombie
## A committed charge: readable windup, fixed direction, solid collision and recovery.

enum ChargePhase { CHASE, WINDUP, CHARGING, RECOVERY, LEAP_WINDUP, LEAPING }
signal charge_phase_changed(phase: int)
signal charge_warning_changed(seconds: float)
const CHARGE_DAMAGE := 60.0
const CHARGE_SPEED := 11.0
const WINDUP_TIME := 2.5
const CHARGE_DISTANCE := 14.0
const CHARGE_RADIUS := 1.4
const CHARGE_TIME := CHARGE_DISTANCE / CHARGE_SPEED
const RECOVERY_TIME := 1.4
const CHARGE_COOLDOWN := 15.0
const LEAP_DAMAGE := 60.0
const LEAP_WINDUP_TIME := 3.0
const LEAP_COOLDOWN := 15.0
const LEAP_RADIUS := 4.5
const LEAP_FLIGHT_TIME := 0.95
const LEAP_HEIGHT := 4.0
var charge_phase := ChargePhase.CHASE:
	set(value):
		charge_phase = value
		charge_phase_changed.emit(value)
var charge_direction := Vector3.ZERO
var charge_hits := 0
var _charge_timer := 0.0
var _charge_cooldown := 2.0
var _leap_cooldown := 6.0
var _leap_target := Vector3.ZERO
var _leap_start := Vector3.ZERO
var _leap_elapsed := 0.0
var _landing_started := false
var _landing_ghost := false
var _prefer_leap := false
var _normal_mask := 3
var _landing_tween: Tween
var leap_hits := 0
var _leap_warning: MeshInstance3D
var _fall_on_death := false
var _death_floor := 0.0
var _death_fall_speed := 0.0
var _charge_hit := false
var _eyes: Array[MeshInstance3D] = []
var _eye_bones: Array[int] = []
var _warning: MeshInstance3D
var _warning_distance := CHARGE_DISTANCE
var _distance_remaining := 0.0
var _last_warning_tick := -1
const EYE_MATERIAL = preload("res://resources/materials/boss_eyes.tres")
const WARNING_MATERIAL = preload("res://resources/materials/boss_warning.tres")

func _ready() -> void:
	super._ready()
	if head_skeleton == null: return
	for bone_name in ["Eyelid.L", "Eyelid.R"]:
		var bone := head_skeleton.find_bone(bone_name)
		if bone < 0: continue
		var eye := MeshInstance3D.new()
		eye.name = bone_name.replace(".", "") + "RedEye"
		var sphere := SphereMesh.new()
		sphere.radius = 0.042 * data.visual_scale
		sphere.height = sphere.radius * 2
		sphere.radial_segments = 10
		sphere.rings = 5
		sphere.material = EYE_MATERIAL
		eye.mesh = sphere
		eye.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(eye)
		eye.top_level = true
		_eyes.append(eye)
		_eye_bones.append(bone)
	_warning = preload("res://scripts/effects/charge_telegraph.gd").new()
	_warning.name = "ChargeTelegraph"
	add_child(_warning)
	_leap_warning = preload("res://scripts/effects/ground_circle.gd").new()
	_leap_warning.name = "LeapTelegraph"
	add_child(_leap_warning)
	_leap_warning.hide()
	for name in [&"CharacterArmature|Run_Arms", &"CharacterArmature|Jump", &"CharacterArmature|Jump_Idle", &"CharacterArmature|Jump_Land"]:
		if animation_player != null and animation_player.has_animation(name):
			var clip := animation_player.get_animation(name).duplicate() as Animation
			clip.loop_mode = Animation.LOOP_LINEAR if name in [&"CharacterArmature|Run_Arms", &"CharacterArmature|Jump_Idle"] else Animation.LOOP_NONE
			if "Jump" in name:
				# The body supplies the airborne arc; suppress imported body/foot lift.
				for track in clip.get_track_count():
					if clip.track_get_type(track) != Animation.TYPE_POSITION_3D: continue
					var path := clip.track_get_path(track)
					var bone_name := String(path.get_subname(0)) if path.get_subname_count() else ""
					if bone_name not in ["Body", "Foot.L"]: continue
					var bone := head_skeleton.find_bone(bone_name)
					for key in clip.track_get_key_count(track): clip.track_set_key_value(track,key,head_skeleton.get_bone_pose_position(bone))
			var library := animation_player.get_animation_library(&"")
			library.remove_animation(name)
			library.add_animation(name, clip)
	_update_eyes()
	_normal_mask = collision_mask
	var pose = preload("res://scripts/enemies/boss_pose.gd").new()
	pose.boss = self
	head_skeleton.add_child(pose)

func _play(clip: StringName, restart: bool = false) -> void:
	if animation_player == null or not animation_player.has_animation(clip): return
	if restart and animation_player.current_animation == clip: animation_player.seek(0,true)
	animation_player.play(clip,0.16)
	if clip == data.attack_animation: animation_player.speed_scale = animation_player.get_animation(clip).length/maxf(data.attack_windup,0.1)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		if _fall_on_death:
			_death_fall_speed += 20.0*delta
			position.y = maxf(_death_floor,position.y-_death_fall_speed*delta)
		super._physics_process(delta)
		return
	# Landing inside a player/enemy must not depenetrate the boss upward onto its
	# head. Keep world collision, then restore actor collision after separation.
	if _landing_ghost and charge_phase in [ChargePhase.CHASE,ChargePhase.RECOVERY]:
		var body := get_node("CollisionShape3D") as CollisionShape3D
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = body.shape
		query.transform = body.global_transform
		query.collision_mask = 10
		query.exclude = [get_rid()]
		if get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():
			_landing_ghost = false
			collision_mask = _normal_mask
			if is_instance_valid(target): remove_collision_exception_with(target)
	_charge_cooldown = maxf(0, _charge_cooldown - delta)
	_leap_cooldown = maxf(0, _leap_cooldown - delta)
	if charge_phase == ChargePhase.CHASE:
		if _prefer_leap and _can_leap(): _begin_leap()
		elif _can_charge(): _begin_charge()
		elif _can_leap(): _begin_leap()
		else:
			super._physics_process(delta)
			if state == State.ATTACK and _windup < 0 and not animation_player.is_playing():
				animation_player.speed_scale = 1.0
				_play(data.idle_animation)
			_update_eyes()
			return
	_tick_ammo_effects(delta)
	if health.is_dead: return
	_update_hitboxes()
	_update_eyes()
	_flash_time = maxf(0, _flash_time - delta)
	for mesh in _meshes: mesh.material_overlay = _status_material if not ammo_effects.is_empty() else _hit_material if _flash_time > 0 else null
	if not is_instance_valid(target) or target.health.is_dead:
		_recover()
	velocity.x = 0
	velocity.z = 0
	velocity.y = 0 if is_on_floor() else velocity.y - 20.0 * delta
	_charge_timer -= delta
	match charge_phase:
		ChargePhase.WINDUP:
			_update_countdown()
			_face(charge_direction, delta)
			visual.rotation.x = lerpf(visual.rotation.x, 0.16, minf(1, delta * 10))
			if _charge_timer <= 0:
				charge_phase = ChargePhase.CHARGING
				_charge_timer = CHARGE_TIME
				_distance_remaining = _warning_distance
				_hide_warning()
				_play(&"CharacterArmature|Run_Arms", true)
				animation_player.speed_scale = 1.6
		ChargePhase.CHARGING:
			var speed := minf(CHARGE_SPEED * ammo_speed_multiplier(), _distance_remaining / maxf(delta, 0.00001))
			velocity.x = charge_direction.x * speed
			velocity.z = charge_direction.z * speed
			if _charge_timer <= 0 or _distance_remaining <= 0.001: _recover()
		ChargePhase.RECOVERY:
			visual.rotation.x = lerpf(visual.rotation.x, 0.0, minf(1, delta * 8))
			if _charge_timer <= 0:
				charge_phase = ChargePhase.CHASE
				state = State.IDLE
				animation_player.speed_scale = 1.0
		ChargePhase.LEAP_WINDUP:
			_update_countdown()
			_face((_leap_target-global_position).normalized(),delta)
			if _charge_timer <= 0:
				charge_phase = ChargePhase.LEAPING
				_leap_start = global_position
				_leap_elapsed = 0
				_landing_started = false
				collision_mask = 1
				_landing_ghost = true
				add_collision_exception_with(target)
				_play(&"CharacterArmature|Jump_Idle",true)
				animation_player.speed_scale = 1.0
		ChargePhase.LEAPING:
			_leap_elapsed += delta
			var t := minf(1,_leap_elapsed/LEAP_FLIGHT_TIME)
			var point := _leap_start.lerp(_leap_target,t)+Vector3.UP*LEAP_HEIGHT*sin(PI*t)
			velocity = (point-global_position)/maxf(delta,0.00001)
			if t >= 0.67 and not _landing_started:
				_landing_started = true
				_play(&"CharacterArmature|Jump_Land",true)
				animation_player.speed_scale = 1.1
	var before := global_position
	move_and_slide()
	if charge_phase == ChargePhase.LEAPING and _leap_elapsed >= LEAP_FLIGHT_TIME: _land_leap()
	if charge_phase == ChargePhase.CHARGING:
		_distance_remaining -= Vector2(global_position.x - before.x, global_position.z - before.z).length()
		_damage_charge_sweep(before, global_position)
		for index in get_slide_collision_count():
			var collision := get_slide_collision(index)
			if collision.get_collider() == target:
				_recover()
				break
			elif collision.get_normal().y < 0.65:
				_recover()
				break
	_update_hitboxes()
	_update_eyes()
	_refresh_label()

func _can_charge() -> bool:
	if _charge_cooldown > 0 or not is_instance_valid(target) or target.health.is_dead: return false
	var distance := global_position.distance_to(target.global_position)
	if distance < 4.5 or distance > CHARGE_DISTANCE: return false
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 1.5, target.global_position + Vector3.UP, 1, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _begin_charge() -> void:
	charge_phase = ChargePhase.WINDUP
	_charge_timer = WINDUP_TIME
	_charge_cooldown = CHARGE_COOLDOWN
	_charge_hit = false
	_prefer_leap = true
	_windup = -1
	charge_direction = target.global_position - global_position
	charge_direction.y = 0
	charge_direction = charge_direction.normalized()
	_set_state(State.ATTACK)
	_play(data.idle_animation, true)
	animation_player.speed_scale = 0.65
	_warning_distance = CHARGE_DISTANCE
	# Trim the red range to cover; the visible corridor is never advertised through a wall.
	var side := charge_direction.cross(Vector3.UP).normalized()
	for offset in [-0.8, 0.0, 0.8]:
		var origin: Vector3 = global_position + Vector3.UP * 1.5 + side * float(offset)
		var ray := PhysicsRayQueryParameters3D.create(origin, origin + charge_direction * CHARGE_DISTANCE, 1, [get_rid()])
		var hit := get_world_3d().direct_space_state.intersect_ray(ray)
		if not hit.is_empty(): _warning_distance = minf(_warning_distance, maxf(0.1, origin.distance_to(hit.position) - 0.8))
	_warning.rebuild(global_position, charge_direction, _warning_distance, CHARGE_RADIUS)
	_last_warning_tick = -1
	_update_countdown()

func charge_seconds_remaining() -> float:
	return maxf(0, _charge_timer) if charge_phase in [ChargePhase.WINDUP,ChargePhase.LEAP_WINDUP] else 0.0

func _can_leap() -> bool:
	if _leap_cooldown > 0 or not is_instance_valid(target) or target.health.is_dead: return false
	var distance := global_position.distance_to(target.global_position)
	return distance >= 2.5 and distance <= 12.0 and _clear_melee_line()

func _begin_leap() -> void:
	charge_phase = ChargePhase.LEAP_WINDUP
	_charge_timer = LEAP_WINDUP_TIME
	_leap_cooldown = LEAP_COOLDOWN
	_prefer_leap = false
	_windup = -1
	var ray := PhysicsRayQueryParameters3D.create(target.global_position+Vector3.UP*0.8,target.global_position-Vector3.UP*6,1)
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	_leap_target = target.global_position
	if not hit.is_empty(): _leap_target.y = hit.position.y+0.02
	_leap_warning.rebuild(_leap_target,LEAP_RADIUS,WARNING_MATERIAL)
	_set_state(State.ATTACK)
	_play(&"CharacterArmature|Jump",true)
	animation_player.speed_scale = 0.07
	_last_warning_tick = -1
	_update_countdown()

func _land_leap() -> void:
	collision_mask = 1
	var at_destination := Vector2(global_position.x-_leap_target.x,global_position.z-_leap_target.z).length() < 1.0
	if at_destination and is_instance_valid(target) and not target.health.is_dead:
		var within := Vector2(target.global_position.x-_leap_target.x,target.global_position.z-_leap_target.z).length() <= LEAP_RADIUS
		if within and absf(target.global_position.y-_leap_target.y) < 2.0 and _clear_melee_line():
			target.health.take_damage(LEAP_DAMAGE*ammo_damage_multiplier())
			leap_hits += 1
			attack_landed.emit()
	var pulse = preload("res://scripts/effects/impact_ring.gd").new()
	get_parent().add_child(pulse)
	pulse.global_position = global_position
	pulse.burst(LEAP_RADIUS,Color(1,0.35,0.12,0.8))
	if is_instance_valid(target) and global_position.distance_to(target.global_position) < 18:
		target.camera_rig.impact_shake(0.6*(1-global_position.distance_to(target.global_position)/18))
		var game := target.get_parent()
		if game.get("audio") != null: game.audio.cue("bat_hit")
	_recover()
	_charge_timer = 1.6
	if not _landing_started: _play(&"CharacterArmature|Jump_Land",true)
	animation_player.speed_scale = 1.0
	visual.scale = Vector3(1.035,0.94,1.035)
	_landing_tween = create_tween()
	_landing_tween.tween_property(visual,"scale",Vector3.ONE,0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _update_countdown() -> void:
	var tick := ceili(charge_seconds_remaining() * 10)
	if tick == _last_warning_tick: return
	_last_warning_tick = tick
	charge_warning_changed.emit(float(tick) / 10.0)

func _damage_charge_sweep(start: Vector3, finish: Vector3) -> void:
	if _charge_hit or not is_instance_valid(target) or target.health.is_dead: return
	if absf(target.global_position.y - global_position.y) > 1.8: return
	var point := target.global_position
	point.y = start.y
	var closest := Geometry3D.get_closest_point_to_segment(point, start, Vector3(finish.x, start.y, finish.z))
	if closest.distance_to(point) > CHARGE_RADIUS or not _clear_melee_line(): return
	_charge_hit = true
	target.health.take_damage(CHARGE_DAMAGE*ammo_damage_multiplier())
	charge_hits += 1
	attack_landed.emit()
	_recover()

func _recover() -> void:
	if charge_phase == ChargePhase.RECOVERY: return
	charge_phase = ChargePhase.RECOVERY
	_charge_timer = RECOVERY_TIME
	velocity.x = 0
	velocity.z = 0
	collision_mask = 1 if _landing_ghost else _normal_mask
	_hide_warning()
	animation_player.speed_scale = 1.0
	_play(&"CharacterArmature|HitReact", true)

func _update_eyes() -> void:
	for index in _eyes.size():
		var pose := head_skeleton.global_transform * head_skeleton.get_bone_global_pose(_eye_bones[index])
		_eyes[index].global_position = pose.origin + visual.global_basis.z * 0.045 * data.visual_scale

func _hide_warning() -> void:
	if is_instance_valid(_warning): _warning.hide()
	if is_instance_valid(_leap_warning): _leap_warning.hide()

func _die() -> void:
	if charge_phase == ChargePhase.LEAPING:
		_fall_on_death = true
		var ray := PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*0.5,global_position-Vector3.UP*12,1)
		var hit := get_world_3d().direct_space_state.intersect_ray(ray)
		_death_floor = float(hit.position.y)+0.02 if not hit.is_empty() else RuralTerrain.height_at(global_position.x,global_position.z)+0.02
	_hide_warning()
	for eye in _eyes: eye.hide()
	if animation_player != null: animation_player.speed_scale = 1.0
	visual.rotation.x = 0
	if _landing_tween != null and _landing_tween.is_valid(): _landing_tween.kill()
	visual.scale = Vector3.ONE
	if is_instance_valid(target): remove_collision_exception_with(target)
	super._die()
