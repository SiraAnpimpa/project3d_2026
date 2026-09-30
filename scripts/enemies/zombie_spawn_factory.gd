class_name ZombieSpawnFactory
extends RefCounted


static func spawn(parent: Node3D, scene: PackedScene, player: PlayerController, point: Vector3, minimum_distance: float = 0.0) -> NormalZombie:
	if not is_instance_valid(player) or scene == null: return null
	if point.distance_to(player.global_position) < minimum_distance: return null
	var world := parent.get_world_3d()
	if NavigationServer3D.map_get_iteration_id(world.navigation_map) == 0: return null
	var location := NavigationServer3D.map_get_closest_point(world.navigation_map, point)
	if location.distance_to(point) > 1.0 or location.distance_to(player.global_position) < minimum_distance: return null
	var instance := scene.instantiate()
	var zombie := instance as NormalZombie
	if zombie == null:
		instance.free()
		return null
	var collider := zombie.get_node("CollisionShape3D") as CollisionShape3D
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = collider.shape
	query.transform.origin = location + collider.position + Vector3.UP * 0.05
	query.collision_mask = 11
	if not world.direct_space_state.intersect_shape(query, 1).is_empty():
		zombie.free()
		return null
	parent.add_child(zombie)
	zombie.global_position = location + Vector3.UP * 0.02
	zombie.bind(player)
	return zombie
