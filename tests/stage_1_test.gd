extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func frames(count: int) -> void:
	for _index in count:
		await physics_frame


func run() -> void:
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	await frames(50)
	var player := game.get_node("Player") as PlayerController
	check(player.is_on_floor() and absf(player.position.y) < 0.1, "spawn settles on ground")
	check(player.visual.animation_player != null, "Matt animation player loads")
	check(root.get_camera_3d() != null, "third-person camera is current")
	var start := player.position
	Input.action_press("move_right")
	await frames(60)
	Input.action_release("move_right")
	check(player.position.x - start.x > 3.0, "input-driven movement advances player")
	Input.action_press("move_right")
	Input.action_press("sprint")
	start = player.position
	await frames(60)
	Input.action_release("move_right")
	Input.action_release("sprint")
	check(player.position.x - start.x > 5.5, "sprint is faster than walking")
	player.position = Vector3(21, 0.1, 0)
	player.velocity = Vector3.ZERO
	Input.action_press("move_right")
	await frames(100)
	Input.action_release("move_right")
	check(player.position.x < 23.7, "boundary collision blocks player")
	player.camera_rig.orbit(0.5, -100.0)
	check(is_equal_approx(player.camera_rig.rotation.y, 0.5), "camera yaw changes")
	check(player.camera_rig.pitch_pivot.rotation.x >= deg_to_rad(-65.1), "camera pitch clamps")
	print("STAGE_1_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
