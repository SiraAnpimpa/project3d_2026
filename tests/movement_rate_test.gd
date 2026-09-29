extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func frames(count: int) -> void:
	for _index in count:
		await physics_frame


func measure(player: PlayerController, rate: int) -> float:
	Engine.physics_ticks_per_second = rate
	player.position = Vector3(10, 0.05, 10)
	player.velocity = Vector3.ZERO
	await frames(10)
	var start := player.position
	Input.action_press("move_left")
	await frames(rate)
	Input.action_release("move_left")
	return player.position.distance_to(start)


func run() -> void:
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	var player := game.get_node("Player") as PlayerController
	var at_30 := await measure(player, 30)
	var at_120 := await measure(player, 120)
	Engine.physics_ticks_per_second = 60
	var passed := absf(at_30 - at_120) < 0.15 and at_30 > 3.2 and at_120 > 3.2
	print("MOVEMENT_RATE_RESULT 30Hz=", at_30, "m 120Hz=", at_120, "m pass=", passed)
	game.queue_free()
	await process_frame
	quit(0 if passed else 1)
