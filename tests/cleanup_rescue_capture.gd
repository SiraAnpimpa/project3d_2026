extends "res://tests/phase_3_integration_test.gd"

func run() -> void:
	root.size = Vector2i(1600,900)
	set_meta("normal_play",true)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	game.clock.paused = true
	game.debug_controls.set_active(false)
	game.hud.hide()
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.far = 300
	camera.fov = 54
	for view in [
		["rescue_layout",Vector3(50,16,57),Vector3(26,0.65,42)],
		["rescue_reveal",Vector3(18,4,31),Vector3(29,1,43)],
		["rescue_from_farm",Vector3(-4,2.2,12),Vector3(29,0.7,43)]
	]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(7)
		await capture(view[0])
	game.clock.seek(1,18,0)
	game.clock.paused = true
	camera.position = Vector3(50,16,57)
	camera.look_at(Vector3(26,0.65,42))
	await frames(10)
	await capture("rescue_night")
	# Spatial integration fixture: actual existing sequence; no new ending behavior.
	game.waves.debug_kill_active()
	game.clock.seek(11,6,0)
	game.presentation.start_ending()
	await frames(310)
	check(game.presentation.rescue_vehicle.position.distance_to(Vector3(29,0.85,43)) < 0.05,"helicopter lands at relocated map anchor")
	check(game.player.position.distance_to(Vector3(25,0.68,45)) < 0.1,"ending actor shares relocated plateau")
	await capture("rescue_landed")
	await frames(190)
	check(game.presentation.ending_finished,"existing ending sequence completes")
	print("CLEANUP_RESCUE_RESULT failures=",failures)
	quit(1 if failures else 0)
