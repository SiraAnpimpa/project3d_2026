class_name RiflePose
extends SkeletonModifier3D
## Small two-arm pose adjustment applied after Matt's existing movement clips.
## No rest bone, imported animation, physics-root transform or shot timing is changed.

var weapons: WeaponController
var actor: PlayerController
var right_error := 0.0
var left_error := 0.0
var aim_weight := 0.0
var recoil := 0.0
var aim_pitch := 0.0
var aim_yaw := 0.0
var leg_yaw := 0.0
var reload_weight := 0.0
var hold_weight := 0.0
var reload_hand_weight := 0.0
var reload_progress := 0.0
var visual_recoil := 0.0
var _recoil_velocity := 0.0
var _impact := 0.0
var _clock := 0.0
var _lean := Vector2.ZERO
var _previous_velocity := Vector3.ZERO
var _previous_yaw := 0.0
var _presentation_weapon: Node3D
var _presentation_parts: Dictionary = {}
var _bones: Dictionary = {}
var _grip_rotations: Dictionary = {}

func setup(controller: WeaponController, player: PlayerController) -> void:
	weapons = controller
	actor = player
	_previous_yaw = actor.visual.rotation.y
	weapons.melee_hit.connect(func() -> void: _impact = minf(_impact+0.6,1.0))
	for bone in ["Body","Torso","Foot.L","Foot.R","UpperArm.R","LowerArm.R","Middle1.R","UpperArm.L","LowerArm.L","Middle1.L"]:
		_bones[bone] = get_skeleton().find_bone(bone)
	# Slash's free left hand is open. Reuse the existing Gun grip rotations for
	# the bat fingers; only presentation poses change, never imported/rest data.
	var grip:=player.visual.animation_player.get_animation("CharacterArmature|Idle_Gun")
	for track in grip.get_track_count():
		var path:=grip.track_get_path(track)
		if path.get_subname_count()==0 or grip.track_get_type(track)!=Animation.TYPE_ROTATION_3D: continue
		var bone:=String(path.get_subname(0))
		if not (bone.begins_with("Pinky") or bone.begins_with("Middle") or bone.begins_with("Index") or bone.begins_with("Thumb")): continue
		var index:=get_skeleton().find_bone(bone)
		if index>=0: _grip_rotations[index]=grip.rotation_track_interpolate(track,0.0)

func tick(delta: float) -> void:
	_clock += delta
	# Critically damped angular spring, independent of the original gameplay recoil field.
	var spring := _recoil_velocity+28.0*visual_recoil
	var decay := exp(-28.0*delta)
	visual_recoil = (visual_recoil+spring*delta)*decay
	_recoil_velocity = (_recoil_velocity-28.0*spring*delta)*decay
	_impact *= exp(-22.0*delta)
	hold_weight = move_toward(hold_weight,1.0 if actor.visual.combat_ready else 0.0,delta*8.0)
	var local_velocity := actor.visual.global_basis.orthonormalized().inverse()*actor.velocity
	var acceleration := actor.visual.global_basis.orthonormalized().inverse()*(actor.velocity-_previous_velocity)/maxf(delta,0.0001)
	var turn_rate := wrapf(actor.visual.rotation.y-_previous_yaw,-PI,PI)/maxf(delta,0.0001)
	var goal_lean := Vector2(clampf(local_velocity.z*0.006+acceleration.z*0.001,-0.055,0.055),clampf(-turn_rate*0.018-local_velocity.x*0.008,-0.065,0.065))
	_lean = _lean.lerp(goal_lean,1.0-exp(-9.0*delta))
	_previous_velocity = actor.velocity
	_previous_yaw = actor.visual.rotation.y
	var hand_goal := 0.0
	reload_progress = 0
	var melee := weapons.current != null and weapons.current.data.is_melee()
	aim_weight = move_toward(aim_weight, 1.0 if actor.camera_rig.is_aiming and not melee else 0.0, delta * 12)
	if not actor.visual.combat_ready:
		aim_pitch = lerpf(aim_pitch,0.0,1.0-exp(-18.0*delta))
		aim_yaw = lerpf(aim_yaw,0.0,1.0-exp(-18.0*delta))
	recoil = maxf(0,recoil-delta*9)
	reload_weight = 0
	if weapons.current != null and weapons.current.is_reloading:
		var progress := 1.0-weapons.current.reload_remaining/weapons.current.data.reload_time
		reload_weight = sin(clampf(progress,0,1)*PI)
		reload_progress = clampf(progress,0,1)
		hand_goal = smoothstep(0.06,0.24,progress)*(1.0-smoothstep(0.66,0.90,progress))
	reload_hand_weight = move_toward(reload_hand_weight,hand_goal,delta*10.0)
	var velocity := actor.visual.global_basis.inverse() * actor.velocity
	var goal := 0.0
	if actor.camera_rig.is_aiming and Vector2(velocity.x,velocity.z).length() > 0.2:
		goal = atan2(velocity.x,velocity.z)
		if absf(goal) > PI/2: goal -= signf(goal)*PI
		goal = clampf(goal,-deg_to_rad(70),deg_to_rad(70))
	leg_yaw = lerpf(leg_yaw,goal,1.0-exp(-14*delta))

func kick() -> void:
	recoil = 1.0
	_recoil_velocity = minf(_recoil_velocity+3.6,5.0)

func update_socket() -> void:
	if actor == null or weapons.visual == null or weapons.current == null: return
	var skeleton := get_skeleton()
	var torso := actor.visual.to_local(skeleton.global_transform * skeleton.get_bone_global_pose(_bones["Torso"]).origin)
	var data := weapons.current.data
	if data.is_melee():
		_update_melee_socket(data,torso)
		return
	var offset := data.ready_hold_offset.lerp(data.aim_hold_offset, aim_weight)
	var point := actor.visual.to_global(torso + offset)
	var target := actor.aim_ray.aim_point
	var direction := target-point
	# Very near/behind-barrel targets keep a forward hold instead of folding into the body.
	if direction.length() < 1.2 or direction.normalized().dot(actor.aim_ray.aim_direction) < 0.15:
		direction = actor.aim_ray.aim_direction
	var local := actor.visual.global_basis.orthonormalized().inverse() * direction.normalized()
	aim_yaw = clampf(atan2(local.x,local.z),-deg_to_rad(70),deg_to_rad(70))*aim_weight
	aim_pitch = clampf(-atan2(local.y,Vector2(local.x,local.z).length()),-deg_to_rad(45),deg_to_rad(60))*aim_weight
	var pitch := deg_to_rad(data.ready_pitch_degrees)*(1.0-aim_weight) + aim_pitch + reload_weight*deg_to_rad(30) - recoil*deg_to_rad(2.5)
	var basis := actor.visual.global_basis.orthonormalized() * Basis(Vector3.UP,aim_yaw-reload_weight*0.1) * Basis(Vector3.RIGHT,pitch) * Basis(Vector3.FORWARD,reload_weight*0.18)
	# Barrel is above the socket; converge its visible axis on ordinary-distance targets.
	if aim_weight > 0.99 and reload_weight == 0 and recoil == 0 and point.distance_to(target) > 1.2 and absf(atan2(local.x,local.z)) < deg_to_rad(65) and absf(aim_pitch) < deg_to_rad(44):
		for iteration in 3:
			var muzzle_point := point+basis*weapons.muzzle.position
			basis = Basis.looking_at((target-muzzle_point).normalized(),Vector3.UP,true)
	point -= basis.z*recoil*0.035
	weapons.get_socket().global_transform = Transform3D(basis,point)

func _update_melee_socket(data: WeaponData, torso: Vector3) -> void:
	aim_yaw = 0
	aim_pitch = 0
	var pitch := deg_to_rad(data.ready_pitch_degrees)
	var yaw := deg_to_rad(-15)
	var state := weapons.current
	if state.is_swinging:
		var elapsed := state.swing_elapsed
		if elapsed <= data.melee_hit_delay:
			var progress := clampf(elapsed/data.melee_hit_delay,0,1)
			yaw = lerpf(deg_to_rad(-85),0,progress)
			pitch = lerpf(deg_to_rad(-35),0,progress)
		else:
			var progress := clampf((elapsed-data.melee_hit_delay)/(data.melee_swing_duration-data.melee_hit_delay),0,1)
			if progress < 0.5:
				yaw = lerpf(0,deg_to_rad(70),progress*2)
				pitch = lerpf(0,deg_to_rad(12),progress*2)
			else:
				var settle := smoothstep(0.5,1.0,progress)
				yaw = lerpf(deg_to_rad(70),deg_to_rad(-15),settle)
				pitch = lerpf(deg_to_rad(12),deg_to_rad(data.ready_pitch_degrees),settle)
	var basis := actor.visual.global_basis.orthonormalized()*Basis(Vector3.UP,yaw)*Basis(Vector3.RIGHT,pitch)
	weapons.get_socket().global_transform = Transform3D(basis,actor.visual.to_global(torso+data.ready_hold_offset))

func _process_modification_with_delta(_delta: float) -> void:
	if actor == null or actor.health.is_dead: return
	_pose_body()
	if not is_instance_valid(weapons.visual): return
	_cache_presentation_parts()
	_restore_presentation_parts()
	if hold_weight <= 0.001: return
	update_socket()
	_apply_presentation()
	if weapons.current.data.is_melee():
		for bone in _grip_rotations:
			if not weapons.current.data.two_handed and get_skeleton().get_bone_name(bone).ends_with(".L"): continue
			get_skeleton().set_bone_pose_rotation(bone,_grip_rotations[bone])
	var primary := weapons.visual.get_node_or_null("PrimaryGrip") as Node3D
	var support := weapons.visual.get_node_or_null("SecondaryGrip") as Node3D
	if support == null: support = weapons.visual.get_node_or_null("SupportGrip") as Node3D
	if primary == null: return
	_solve_arm("R", primary.global_position, actor.visual.to_global(Vector3(-0.5,0.6,-0.08)))
	right_error = _point("Middle1.R").distance_to(primary.global_position)
	if not weapons.current.data.two_handed or support == null:
		left_error = 0.0
		return
	var support_target := support.global_position
	var magazine := weapons.visual.get_node_or_null("MagazineGrip") as Node3D
	if magazine != null:
		support_target = support_target.lerp(magazine.global_position,reload_hand_weight)
		var withdraw := sin(smoothstep(0.25,0.60,reload_progress)*PI)*reload_hand_weight
		support_target += actor.visual.global_basis.orthonormalized()*Vector3(0,-0.075,0.025)*withdraw
	_solve_arm("L", support_target, actor.visual.to_global(Vector3(0.5,0.6,0.04)))
	right_error = _point("Middle1.R").distance_to(primary.global_position)
	left_error = _point("Middle1.L").distance_to(support_target)

func _pose_body() -> void:
	var skeleton := get_skeleton()
	var inverse := skeleton.global_transform.affine_inverse()
	var torso := skeleton.global_transform * skeleton.get_bone_global_pose(_bones["Torso"])
	var pivot := _point("Body")
	# Foot controllers are Root siblings of Body in this particular imported rig.
	# Rotate all three together, then restore the torso to keep upper/lower body coherent.
	var turn := Basis(Vector3.UP,leg_yaw)
	for bone in ["Body","Foot.L","Foot.R"]:
		var pose := skeleton.global_transform * skeleton.get_bone_global_pose(_bones[bone])
		pose.origin = pivot+turn*(pose.origin-pivot)
		pose.basis = turn*pose.basis
		skeleton.set_bone_global_pose(_bones[bone],inverse*pose)
	var right := actor.visual.global_basis.x.normalized()
	var pitch := clampf(aim_pitch*0.5,-0.35,0.45)-recoil*0.025+_lean.x-visual_recoil*0.40
	var hurt := actor.visual.hurt_weight
	pitch += hurt*0.10
	var twist := 0.0
	if weapons.current != null and weapons.current.data.is_melee() and weapons.current.is_swinging:
		var t := weapons.current.swing_elapsed*0.48/weapons.current.data.melee_swing_duration
		if t < 0.08: twist = lerpf(0.0,-0.13,smoothstep(0.0,0.08,t))
		elif t < 0.18: twist = lerpf(-0.13,0.16,smoothstep(0.08,0.18,t))
		elif t < 0.30: twist = lerpf(0.16,0.23,smoothstep(0.18,0.30,t))
		else: twist = lerpf(0.23,0.0,smoothstep(0.30,0.48,t))
	var roll_axis := actor.visual.global_basis.z.normalized()
	torso.basis = Basis(roll_axis,_lean.y+hurt*0.055)*Basis(Vector3.UP,twist)*torso.basis
	torso.basis = Basis(Vector3.UP,aim_yaw*0.55)*Basis(right,pitch)*torso.basis
	skeleton.set_bone_global_pose(_bones["Torso"],inverse*torso)

func _point(bone: String) -> Vector3:
	var skeleton := get_skeleton()
	return skeleton.global_transform * skeleton.get_bone_global_pose(_bones[bone]).origin

func _solve_arm(side: String, target: Vector3, pole: Vector3) -> void:
	var upper := "UpperArm." + side
	var lower := "LowerArm." + side
	var wrist := "Middle1." + side
	var shoulder := _point(upper)
	var elbow := _point(lower)
	var hand := _point(wrist)
	var a := shoulder.distance_to(elbow)
	var b := elbow.distance_to(hand)
	var distance := clampf(shoulder.distance_to(target), absf(a-b)+0.001, a+b-0.002)
	var direction := (target-shoulder).normalized()
	var bend := (pole-shoulder).slide(direction).normalized()
	var along := (a*a-b*b+distance*distance)/(2*distance)
	var height := sqrt(maxf(0,a*a-along*along))
	var elbow_target := shoulder + direction*along + bend*height
	_rotate_joint(upper, elbow-shoulder, elbow_target-shoulder)
	elbow = _point(lower)
	hand = _point(wrist)
	_rotate_joint(lower, hand-elbow, (shoulder+direction*distance)-elbow)

func _rotate_joint(bone: String, from: Vector3, to: Vector3) -> void:
	if from.is_zero_approx() or to.is_zero_approx(): return
	var skeleton := get_skeleton()
	var inverse := skeleton.global_transform.affine_inverse()
	var index: int = _bones[bone]
	var pose := skeleton.global_transform * skeleton.get_bone_global_pose(index)
	pose.basis = Basis(Quaternion.IDENTITY.slerp(Quaternion(from.normalized(),to.normalized()),hold_weight)) * pose.basis
	skeleton.set_bone_global_pose(index, inverse * pose)


func _cache_presentation_parts() -> void:
	if _presentation_weapon == weapons.visual: return
	_presentation_weapon = weapons.visual
	_presentation_parts.clear()
	for child in weapons.visual.get_children():
		# Muzzle/Flash remain on the unchanged canonical shot transform.
		if child is Node3D and child.name != &"Muzzle": _presentation_parts[child] = child.transform

func _restore_presentation_parts() -> void:
	for part: Node3D in _presentation_parts:
		if is_instance_valid(part): part.transform = _presentation_parts[part]

func _apply_presentation() -> void:
	var cosmetic := Transform3D.IDENTITY
	if weapons.current.data.is_melee():
		var data := weapons.current.data
		var yaw := deg_to_rad(-15.0)
		var pitch := deg_to_rad(data.ready_pitch_degrees)
		var reach := Vector3.ZERO
		if weapons.current.is_swinging:
			var t := weapons.current.swing_elapsed
			var contact := data.melee_hit_delay
			var anticipation := contact*0.44
			var follow := contact+(data.melee_swing_duration-contact)*0.40
			if t < anticipation:
				var u := smoothstep(0.0,anticipation,t)
				yaw = lerpf(yaw,deg_to_rad(-72.0),u)
				pitch = lerpf(pitch,deg_to_rad(-38.0),u)
			elif t < contact:
				var u := clampf((t-anticipation)/(contact-anticipation),0,1)
				yaw = _swing_arc(deg_to_rad(-72.0),0.0,contact-anticipation,u,0.0,deg_to_rad(600.0))
				pitch = _swing_arc(deg_to_rad(-38.0),0.0,contact-anticipation,u,0.0,deg_to_rad(220.0))
			elif t < follow:
				var u := clampf((t-contact)/(follow-contact),0,1)
				yaw = _swing_arc(0.0,deg_to_rad(64.0),follow-contact,u,deg_to_rad(600.0),0.0)
				pitch = _swing_arc(0.0,deg_to_rad(12.0),follow-contact,u,deg_to_rad(220.0),0.0)
			else:
				var u := smoothstep(follow,data.melee_swing_duration,t)
				yaw = lerpf(deg_to_rad(64.0),yaw,u)
				pitch = lerpf(deg_to_rad(12.0),pitch,u)
			var extend := sin(clampf(t/data.melee_swing_duration,0,1)*PI)
			reach = Vector3(-0.025,0.015,0.045)*extend
		var skeleton := get_skeleton()
		var torso := actor.visual.to_local(skeleton.global_transform*skeleton.get_bone_global_pose(_bones["Torso"]).origin)
		var desired := Transform3D(actor.visual.global_basis.orthonormalized()*Basis(Vector3.UP,yaw-_impact*0.055)*Basis(Vector3.RIGHT,pitch),actor.visual.to_global(torso+data.ready_hold_offset+reach))
		cosmetic = weapons.get_socket().global_transform.affine_inverse()*desired
	else:
		var idle_sway := sin(_clock*1.8)*0.003*(1.0-aim_weight)
		var reload_turn := reload_hand_weight*0.11
		var settle := sin(reload_progress*PI*2.0)*0.018*reload_hand_weight
		cosmetic.basis = Basis(Vector3.RIGHT,-visual_recoil+settle)*Basis(Vector3.FORWARD,idle_sway+reload_turn)
		cosmetic.origin = Vector3(0,-reload_hand_weight*0.012,-visual_recoil*0.36)
	for part: Node3D in _presentation_parts:
		part.transform = cosmetic*_presentation_parts[part]

func _swing_arc(a: float, b: float, duration: float, t: float, start_speed: float, end_speed: float) -> float:
	# Hermite tangents carry momentum through contact instead of easing to a stop there.
	var t2 := t*t
	var t3 := t2*t
	return (2*t3-3*t2+1)*a+(t3-2*t2+t)*duration*start_speed+(-2*t3+3*t2)*b+(t3-t2)*duration*end_speed
