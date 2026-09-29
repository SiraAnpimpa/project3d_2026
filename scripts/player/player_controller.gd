class_name PlayerController
extends CharacterBody3D

@export var walk_speed: float = 4.0
@export var sprint_speed: float = 7.0
@export var aim_walk_speed: float = 2.8
@export var acceleration: float = 24.0
@export var braking: float = 30.0
@export var turn_speed: float = 12.0

var is_sprinting: bool = false
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))

@onready var camera_rig: ThirdPersonCamera = $CameraPivot
@onready var aim_ray: CameraAimRay = $AimRay
@onready var visual: PlayerVisual = $Visual
@onready var health: HealthComponent = $Health
@onready var stamina: StaminaComponent = $Stamina
@onready var interactor: PlayerInteractor = $Interactor


func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if health.is_dead:
		input_vector = Vector2.ZERO
	interactor.enabled = not health.is_dead
	var direction := camera_rig.global_basis * Vector3(input_vector.x, 0.0, input_vector.y)
	direction.y = 0.0
	direction = direction.normalized()
	var wants_sprint := Input.is_action_pressed("sprint") and not direction.is_zero_approx() and is_on_floor()
	is_sprinting = stamina.tick(delta, wants_sprint)
	camera_rig.set_sprinting(is_sprinting)
	var speed := sprint_speed if is_sprinting else (aim_walk_speed if camera_rig.is_aiming else walk_speed)
	var rate := acceleration if not direction.is_zero_approx() else braking
	velocity.x = move_toward(velocity.x, direction.x * speed, rate * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, rate * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	var facing := -camera_rig.global_basis.z if camera_rig.is_aiming else direction
	if not facing.is_zero_approx():
		# Matt's authored forward is +Z; rotate the visual only, not the physics root.
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(facing.x, facing.z),
			1.0 - exp(-turn_speed * delta))
	visual.set_motion(Vector2(velocity.x, velocity.z).length() > 0.15, is_sprinting, health.is_dead)
