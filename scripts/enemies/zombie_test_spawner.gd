class_name ZombieTestSpawner
extends Node3D

@export var zombie_scene: PackedScene = preload("res://scenes/enemies/NormalZombie.tscn")
@export var maximum_alive: int = 5
var player: PlayerController
var debug: DebugControls
var zombies: Array[NormalZombie] = []
var _next_point := 0


func bind(target: PlayerController, controls: DebugControls) -> void:
	player = target
	debug = controls
	debug.status_changed.connect(func(active: bool, _summary: String) -> void:
		for zombie in zombies:
			if is_instance_valid(zombie): zombie.label.visible = active)


func spawn_test_zombies(count: int) -> int:
	if debug == null or not debug.active or not debug.debug_enabled or not OS.is_debug_build(): return 0
	if not is_instance_valid(player) or player.health.is_dead: return 0
	var spawned := 0
	for _index in mini(count, maximum_alive):
		if zombies.size() >= maximum_alive: break
		var point := get_child(_next_point % get_child_count()) as Marker3D
		_next_point += 1
		if point == null: continue
		if spawn_at(point.global_position) != null: spawned += 1
	return spawned


func spawn_at(point: Vector3) -> NormalZombie:
	# Explicit factory for test fixtures and a future wave caller. No clock coupling.
	if not is_instance_valid(player) or zombies.size() >= maximum_alive: return null
	var map := get_world_3d().navigation_map
	if NavigationServer3D.map_get_iteration_id(map) == 0: return null
	var location := NavigationServer3D.map_get_closest_point(map, point)
	if location.distance_to(point) > 1.0: return null
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform.origin = location + Vector3(0, 0.95, 0)
	query.collision_mask = 11
	if not get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty(): return null
	var zombie := zombie_scene.instantiate() as NormalZombie
	get_parent().add_child(zombie)
	zombie.global_position = Vector3(location.x, 0.05, location.z)
	zombie.bind(player)
	zombie.label.visible = debug != null and debug.active
	zombies.append(zombie)
	zombie.tree_exiting.connect(func() -> void: zombies.erase(zombie))
	return zombie


func clear_zombies() -> void:
	for zombie in zombies.duplicate():
		if is_instance_valid(zombie): zombie.queue_free()
