class_name ThirdPersonCamera
extends Node3D

signal aim_changed(aiming: bool)
signal controls_changed(enabled: bool)
signal pose_updated

@export_group("Look")
@export_range(0.0001, 0.02, 0.0001) var mouse_sensitivity: float = 0.003
@export var keyboard_turn_speed: float = 1.8
@export_range(-85.0, 0.0) var minimum_pitch_degrees: float = -65.0
@export_range(0.0, 80.0) var maximum_pitch_degrees: float = 45.0
@export_group("Shoulder framing")
@export var camera_height: float = 1.65
@export_range(0.5, 10.0) var normal_distance: float = 4.2
@export_range(0.5, 10.0) var aim_distance: float = 2.6
@export_range(-2.0, 2.0) var normal_shoulder_offset: float = 0.7
@export_range(-2.0, 2.0) var aim_shoulder_offset: float = 0.85
@export_range(30.0, 100.0) var normal_fov: float = 70.0
@export_range(30.0, 100.0) var aim_fov: float = 55.0
@export_range(1.0, 30.0) var aim_transition_speed: float = 10.0
@export_group("Collision")
@export_flags_3d_physics var collision_mask: int = 1
@export_range(0.1, 0.5) var collision_radius: float = 0.22
@export_range(0.005, 0.2) var camera_collision_margin: float = 0.04
@export_range(1.0, 30.0) var collision_return_speed: float = 8.0

var is_aiming := false
var shoulder_side: float = 1.0
var current_distance: float = 4.2
var desired_distance: float = 4.2
var current_shoulder: float = 0.7
var collision_limited := false
var _aim_held := false
var _combat_enabled := false
var _sprinting := false
var _menu_open := false
var _player_alive := true
var _cursor_released := false
var _window_focused := true
var _query := PhysicsShapeQueryParameters3D.new()
var _shape := SphereShape3D.new()

@onready var pitch_pivot: Node3D = $Pitch
@onready var shoulder_pivot: Node3D = $Pitch/ShoulderOffset
@onready var boom: Node3D = $Pitch/ShoulderOffset/CameraBoom
@onready var camera: Camera3D = $Pitch/ShoulderOffset/CameraBoom/Camera3D


func _ready() -> void:
	_query.shape = _shape
	var body := get_parent() as CollisionObject3D
	if body != null:
		_query.exclude = [body.get_rid()]
	position.y = camera_height
	desired_distance = normal_distance
	current_distance = normal_distance
	current_shoulder = normal_shoulder_offset
	shoulder_pivot.position.x = current_shoulder
	boom.position.z = current_distance
	camera.fov = normal_fov
	call_deferred("capture_mouse")


func can_control() -> bool:
	return _player_alive and not _menu_open and not _cursor_released and _window_focused and not get_tree().paused


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("capture_mouse") and _cursor_released:
		capture_mouse()
		get_viewport().set_input_as_handled()
		return
	if not can_control():
		return
	if event.is_action("aim"):
		_aim_held = event.is_action_pressed("aim") and _combat_enabled
		_refresh_aim()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("switch_shoulder"):
		shoulder_side *= -1.0
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		# Raw relative motion is already a displacement: never multiply it by delta.
		orbit(-event.screen_relative.x * mouse_sensitivity, -event.screen_relative.y * mouse_sensitivity)


func _physics_process(delta: float) -> void:
	if can_control():
		orbit(-Input.get_axis("camera_left", "camera_right") * keyboard_turn_speed * delta,
			-Input.get_axis("camera_up", "camera_down") * keyboard_turn_speed * delta)
	_refresh_aim()
	update_pose(delta)
	pose_updated.emit()


func orbit(yaw_delta: float, pitch_delta: float) -> void:
	if is_zero_approx(yaw_delta) and is_zero_approx(pitch_delta):
		return
	rotation = Vector3(0.0, wrapf(rotation.y + yaw_delta, -PI, PI), 0.0)
	pitch_pivot.rotation = Vector3(clampf(pitch_pivot.rotation.x + pitch_delta,
		deg_to_rad(minimum_pitch_degrees), deg_to_rad(maximum_pitch_degrees)), 0.0, 0.0)
	# Mouse events can arrive between physics ticks. Resolve the new camera pose
	# immediately so a rendered frame cannot use the old collision clearance.
	update_pose(0.0)
	pose_updated.emit()


func is_combat_enabled() -> bool:
	return _combat_enabled


func set_combat_enabled(value: bool) -> void:
	_combat_enabled = value
	_aim_held = false
	_refresh_aim()
	controls_changed.emit(can_control())


func set_sprinting(value: bool) -> void:
	_sprinting = value
	_refresh_aim()


func set_menu_open(value: bool) -> void:
	_menu_open = value
	_aim_held = false
	_refresh_aim()
	if value:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		capture_mouse()
	controls_changed.emit(can_control())


func set_player_alive(value: bool) -> void:
	if value == _player_alive:
		return
	_player_alive = value
	_aim_held = false
	_refresh_aim()
	if value: capture_mouse()
	else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	controls_changed.emit(can_control())


func capture_mouse() -> void:
	_cursor_released = false
	if can_control():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	controls_changed.emit(can_control())


func release_mouse() -> void:
	_cursor_released = true
	_aim_held = false
	_refresh_aim()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	controls_changed.emit(false)


func _refresh_aim() -> void:
	var value := _aim_held and _combat_enabled and not _sprinting and can_control()
	if value != is_aiming:
		is_aiming = value
		aim_changed.emit(value)


func update_pose(delta: float) -> void:
	position.y = camera_height
	var weight := 1.0 - exp(-aim_transition_speed * delta)
	desired_distance = lerpf(desired_distance, aim_distance if is_aiming else normal_distance, weight)
	current_shoulder = lerpf(current_shoulder, (aim_shoulder_offset if is_aiming else normal_shoulder_offset) * shoulder_side, weight)
	camera.fov = lerpf(camera.fov, aim_fov if is_aiming else normal_fov, weight)
	_shape.radius = collision_radius
	_query.collision_mask = collision_mask
	# Sweep laterally before the rear boom. An offset AFTER a central spring arm
	# can otherwise put the camera through a side wall.
	var lateral := pitch_pivot.global_basis.x * current_shoulder
	var lateral_fraction := _safe_fraction(pitch_pivot.global_position, lateral)
	shoulder_pivot.position.x = current_shoulder * lateral_fraction
	var rear := pitch_pivot.global_basis.z * desired_distance
	var safe_distance := desired_distance * _safe_fraction(shoulder_pivot.global_position, rear)
	collision_limited = safe_distance < desired_distance - 0.001 or lateral_fraction < 0.999
	# Pull in immediately for safety; ease outward after an obstruction clears.
	current_distance = minf(safe_distance, lerpf(current_distance, safe_distance, 1.0 - exp(-collision_return_speed * delta)))
	boom.position.z = current_distance


func _safe_fraction(origin: Vector3, motion: Vector3) -> float:
	if motion.length() < 0.00001:
		return 1.0
	_query.transform = Transform3D(Basis.IDENTITY, origin)
	_query.motion = Vector3.ZERO
	var space := get_world_3d().direct_space_state
	if not space.intersect_shape(_query, 1).is_empty():
		return 0.0
	_query.motion = motion
	var result := space.cast_motion(_query)
	if result[0] >= 1.0:
		return 1.0
	return maxf(0.0, result[0] - camera_collision_margin / motion.length())


func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_PAUSED:
		if what == NOTIFICATION_APPLICATION_FOCUS_OUT: _window_focused = false
		_aim_held = false
		_refresh_aim()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		controls_changed.emit(false)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_UNPAUSED:
		if what == NOTIFICATION_APPLICATION_FOCUS_IN: _window_focused = true
		if can_control(): Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		controls_changed.emit(can_control())


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
