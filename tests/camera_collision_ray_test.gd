extends SceneTree

var failures := 0


func _initialize() -> void: call_deferred("run")


func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func frames(count: int) -> void:
	for _i in count: await physics_frame


func box(parent: Node, at: Vector3, size: Vector3, layer: int = 1) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = layer
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	body.global_position = at
	return body


func camera_clear(rig: ThirdPersonCamera) -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = rig.collision_radius - 0.005
	query.shape = sphere
	query.collision_mask = 1
	query.transform.origin = rig.camera.global_position
	return rig.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(10)
	var player: PlayerController = game.get_node("Player")
	var rig := player.camera_rig
	var ray := player.aim_ray
	player.position = Vector3(12, 0.05, -12)
	await frames(30)
	check(camera_clear(rig) and absf(rig.current_distance - rig.normal_distance) < 0.01, "unobstructed boom reaches normal distance")
	var wall := box(game, Vector3(12, 2.5, -10), Vector3(8, 5, 0.2))
	await frames(5)
	check(rig.current_distance < 2 and rig.collision_limited and camera_clear(rig), "rear wall retracts the camera without clipping its collision volume")
	var fixed := rig.camera.global_position
	var jitter := 0.0
	for _i in 90:
		await physics_frame
		jitter = maxf(jitter, rig.camera.global_position.distance_to(fixed))
	check(jitter < 0.001, "stationary wall contact has less than 1mm camera variation")
	wall.queue_free()
	await frames(3)
	check(rig.current_distance > 1.5 and rig.current_distance < rig.normal_distance - 0.1, "clearing an obstruction eases boom outward")
	await frames(90)
	check(absf(rig.current_distance - rig.normal_distance) < 0.01, "boom fully restores after wall clearance")
	var side := box(game, Vector3(12.5, 2.5, -12), Vector3(0.2, 5, 12))
	await frames(5)
	check(rig.shoulder_pivot.position.x < 0.2 and camera_clear(rig), "side wall clamps the shoulder offset before sweeping backward")
	wall = box(game, Vector3(12, 2.5, -10), Vector3(8, 5, 0.2))
	await frames(5)
	var corner_clear := true
	for index in 60:
		rig.orbit(0.015 if index < 30 else -0.015, 0)
		corner_clear = corner_clear and camera_clear(rig)
		await frames(1)
		corner_clear = corner_clear and camera_clear(rig)
	check(corner_clear, "orbiting along an inside corner clears both walls immediately and after physics")
	side.queue_free()
	wall.queue_free()
	await frames(3)
	rig.orbit(0, 100)
	await frames(5)
	check(camera_clear(rig) and rig.camera.global_position.y >= rig.collision_radius, "upward look prevents camera boom passing through ground")
	rig.rotation.y = 0
	rig.pitch_pivot.rotation.x = 0
	await frames(90)
	ray.aim_collision_mask = 8
	for distance in [3.0, 9.0, 25.0, 80.0]:
		ray.update_aim()
		var target := box(game, ray.aim_origin + ray.aim_direction * distance, Vector3.ONE, 8)
		await frames(3)
		check(ray.has_hit and ray.hit_collider == target and absf(ray.aim_origin.distance_to(ray.aim_point) - (distance - 0.5)) < 0.03, "center ray hits correct target face at " + str(distance) + "m")
		var projected := rig.camera.unproject_position(ray.aim_point)
		check(projected.distance_to(Vector2(640, 360)) < 0.05, "aim target projects to exact crosshair center at " + str(distance) + "m")
		target.queue_free()
		await frames(2)
	ray.update_aim()
	check(not ray.has_hit and is_equal_approx(ray.aim_origin.distance_to(ray.aim_point), ray.aim_max_distance), "ray miss returns origin plus forward times max distance")
	rig.normal_shoulder_offset = 0
	rig.aim_shoulder_offset = 0
	await frames(90)
	ray.aim_collision_mask = 2
	await frames(2)
	check(not ray.has_hit, "aim ray excludes player's own collider")
	root.size = Vector2i(1600, 900)
	ray.aim_collision_mask = 8
	ray.update_aim()
	var resized_center := rig.camera.unproject_position(ray.aim_point)
	var viewport_center := rig.camera.get_viewport().get_visible_rect().size * 0.5
	check(resized_center.distance_to(viewport_center) < 0.05, "aim ray follows viewport center after resize")
	print("CAMERA_COLLISION_RAY_RESULT jitter_m=", jitter, " failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
