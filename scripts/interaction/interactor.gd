class_name PlayerInteractor
extends Node3D

signal target_changed(target: Interactable)
signal interaction_completed(message: String)

@export var interaction_distance: float = 2.8
var enabled: bool = true
var target: Interactable
var query := PhysicsShapeQueryParameters3D.new()

@onready var actor: CharacterBody3D = get_parent() as CharacterBody3D


func _ready() -> void:
	var sphere := SphereShape3D.new()
	sphere.radius = interaction_distance
	query.shape = sphere
	query.collision_mask = 4


func _physics_process(_delta: float) -> void:
	refresh_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()


func refresh_target() -> void:
	var nearest: Interactable = null
	var nearest_distance: float = INF
	if enabled:
		query.transform = global_transform
		for hit in get_world_3d().direct_space_state.intersect_shape(query, 32):
			var candidate := hit.get("collider") as Interactable
			if candidate == null or not _can_reach(candidate):
				continue
			var distance := global_position.distance_squared_to(candidate.get_interaction_point())
			if distance < nearest_distance:
				nearest = candidate
				nearest_distance = distance
	if target != nearest:
		target = nearest
		target_changed.emit(target)


func _can_reach(candidate: Interactable) -> bool:
	if not is_instance_valid(candidate) or not candidate.is_available(actor):
		return false
	var point := candidate.get_interaction_point()
	if global_position.distance_to(point) > interaction_distance:
		return false
	var ray := PhysicsRayQueryParameters3D.create(global_position, point, 1, [actor.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or hit.get("collider") == candidate


func try_interact() -> void:
	# Recheck at the moment of activation, including objects freed since the last frame.
	if not enabled or not is_instance_valid(target) or not _can_reach(target):
		return
	var message := target.interact(actor)
	interaction_completed.emit(message)
	if OS.is_debug_build(): print(message)
