extends SceneTree


func _initialize() -> void: call_deferred("run")


func measure(player: PlayerController, rate: int) -> Vector4:
	var rig := player.camera_rig
	rig.set_physics_process(false)
	player.set_physics_process(false)
	rig.camera.fov = rig.normal_fov
	rig.desired_distance = rig.normal_distance
	rig.current_distance = rig.normal_distance
	rig.current_shoulder = rig.normal_shoulder_offset
	rig.is_aiming = true
	for _i in int(rate * 0.5):
		rig.update_pose(1.0 / rate)
	return Vector4(rig.camera.fov, rig.desired_distance, rig.current_shoulder, rig.current_distance)


func run() -> void:
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	await physics_frame
	var player: PlayerController = game.get_node("Player")
	player.position = Vector3(12, 0.05, -12)
	await physics_frame
	var at_30 := measure(player, 30)
	var at_120 := measure(player, 120)
	var pass_aim := at_30.distance_to(at_120) < 0.0001 and at_30.x < 56 and at_30.w < 2.7
	print("CAMERA_RATE_RESULT 30Hz=", at_30, " 120Hz=", at_120, " pass=", pass_aim)
	game.queue_free()
	await process_frame
	quit(0 if pass_aim else 1)
