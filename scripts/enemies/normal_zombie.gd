class_name NormalZombie
extends CharacterBody3D

signal state_changed(state: State)
signal attack_landed
signal died

enum State { IDLE, CHASE, ATTACK, DEAD }
@export var data: ZombieData
@onready var health: HealthComponent = $Health
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var visual: Node3D = $Visual
@onready var label: Label3D = $DebugLabel
var state: State = State.IDLE
var target: PlayerController
var pursue_target: bool = false # Wave enemies seek the player beyond local detection range.
var animation_player: AnimationPlayer
var attacks_landed: int = 0
var path_updates: int = 0
var _path_time := 0.0
var _cooldown := 0.0
var _windup := -1.0
var _death_time := 0.0
var _flash_time := 0.0
var _previous_hp := 0.0
var _meshes: Array[MeshInstance3D] = []
var _hit_material: StandardMaterial3D


func _ready() -> void:
	if data == null or not data.validation_errors().is_empty():
		push_error("NormalZombie requires valid ZombieData.")
		set_physics_process(false)
		return
	health.max_hp = data.max_health
	health.reset()
	_previous_hp = health.current_hp
	health.changed.connect(_on_health_changed)
	health.died.connect(_die)
	agent.target_desired_distance = data.attack_range * 0.75
	var model := data.visual_scene.instantiate() as Node3D
	visual.add_child(model)
	model.scale = Vector3.ONE * data.visual_scale
	animation_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	# Duplicate animation resources: loop settings must not mutate the imported asset.
	if animation_player != null:
		for library_name in animation_player.get_animation_library_list():
			var library := animation_player.get_animation_library(library_name).duplicate(true) as AnimationLibrary
			animation_player.remove_animation_library(library_name)
			animation_player.add_animation_library(library_name, library)
		for clip in [data.idle_animation, data.walk_animation]:
			if animation_player.has_animation(clip):
				animation_player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		for clip in [data.attack_animation, data.death_animation]:
			if animation_player.has_animation(clip):
				animation_player.get_animation(clip).loop_mode = Animation.LOOP_NONE
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		_meshes.append(mesh)
	_hit_material = StandardMaterial3D.new()
	_hit_material.albedo_color = Color(1, 0.3, 0.12)
	_play(data.idle_animation)
	label.hide()
	_refresh_label()


func bind(player: PlayerController) -> void:
	target = player
	_path_time = 0


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		_death_time -= delta
		if _death_time <= 0: queue_free()
		return
	_cooldown = maxf(0, _cooldown - delta)
	_flash_time = maxf(0, _flash_time - delta)
	for mesh in _meshes:
		mesh.material_overlay = _hit_material if _flash_time > 0 else null
	velocity.x = 0
	velocity.z = 0
	if not is_on_floor(): velocity.y -= 20.0 * delta
	else: velocity.y = 0
	if not is_instance_valid(target) or target.health.is_dead:
		_windup = -1
		_set_state(State.IDLE)
		move_and_slide()
		return
	var distance := global_position.distance_to(target.global_position)
	if distance > data.detection_range and not pursue_target:
		_windup = -1
		_set_state(State.IDLE)
	elif distance <= data.attack_range and _clear_melee_line():
		_set_state(State.ATTACK)
		_face(target.global_position - global_position, delta)
		if _windup >= 0:
			_windup -= delta
			if _windup <= 0:
				_windup = -1
				# Revalidate at the hit, not at the start of the animation.
				if not target.health.is_dead and global_position.distance_to(target.global_position) <= data.attack_range and _clear_melee_line():
					target.health.take_damage(data.damage)
					attacks_landed += 1
					attack_landed.emit()
		elif _cooldown <= 0:
			_cooldown = data.attack_interval
			_windup = data.attack_windup
			_play(data.attack_animation, true)
	else:
		_windup = -1
		_set_state(State.CHASE)
		_chase(delta)
	move_and_slide()
	_refresh_label()


func _chase(delta: float) -> void:
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0: return
	_path_time -= delta
	if _path_time <= 0:
		_path_time = data.navigation_interval
		agent.target_position = target.global_position
		path_updates += 1
	var next := agent.get_next_path_position()
	if agent.is_navigation_finished(): return
	var direction := next - global_position
	direction.y = 0
	if direction.length_squared() < 0.001: return
	direction = direction.normalized()
	velocity.x = direction.x * data.move_speed
	velocity.z = direction.z * data.move_speed
	_face(direction, delta)


func _face(direction: Vector3, delta: float) -> void:
	if Vector2(direction.x, direction.z).length_squared() > 0.001:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(direction.x, direction.z), 1.0 - exp(-data.rotation_speed * delta))


func _clear_melee_line() -> bool:
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, target.global_position + Vector3.UP, 1, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _set_state(value: State) -> void:
	if value == state: return
	state = value
	if state == State.IDLE: _play(data.idle_animation)
	elif state == State.CHASE:
		_path_time = 0
		_play(data.walk_animation)
	state_changed.emit(state)


func _play(clip: StringName, restart: bool = false) -> void:
	if animation_player != null and animation_player.has_animation(clip):
		if restart: animation_player.stop()
		animation_player.play(clip, 0.1)


func _on_health_changed(value: float, _maximum: float) -> void:
	if value < _previous_hp: _flash_time = 0.15
	_previous_hp = value
	_refresh_label()


func _refresh_label() -> void:
	label.text = "%s\n%s  %.0f / %.0f HP" % [data.display_name, State.keys()[state], health.current_hp, health.max_hp]


func _die() -> void:
	if state == State.DEAD: return
	_set_state(State.DEAD)
	_windup = -1
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	$CollisionShape3D.set_deferred("disabled", true)
	_death_time = data.death_delay
	_play(data.death_animation)
	for mesh in _meshes: mesh.material_overlay = null
	_refresh_label()
	died.emit()


func despawn() -> void:
	# Administrative cleanup is not a combat death and grants no kill credit.
	set_physics_process(false)
	_windup = -1
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	queue_free()
