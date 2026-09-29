class_name ZombieSpawnFactory
extends RefCounted


static func spawn(parent: Node3D, scene: PackedScene, player: PlayerController, point: Vector3, minimum_distance: float = 0.0) -> NormalZombie:
	if not is_instance_valid(player) or scene == null: return null
	if point.distance_to(player.global_position) < minimum_distance: return null
	var world := parent.get_world_3d()
	if NavigationServer3D.map_get_iteration_id(world.navigation_map) == 0: return null
	var location := NavigationServer3D.map_get_closest_point(world.navigation_map, point)
	if location.distance_to(point) > 1.0 or location.distance_to(player.global_position) < minimum_distance: return null
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform.origin = location + Vector3(0, 0.95, 0)
	query.collision_mask = 11
	if not world.direct_space_state.intersect_shape(query, 1).is_empty(): return null
	var zombie := scene.instantiate() as NormalZombie
	parent.add_child(zombie)
	zombie.global_position = location + Vector3.UP * 0.02
	zombie.bind(player)
	return zombie
