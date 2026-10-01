extends "res://tests/phase_3_integration_test.gd"

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	game.debug_controls.set_active(false)
	game.clock.paused = true
	game.hud.hide()
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.far = 160
	camera.position = Vector3(36, 45, 42)
	camera.look_at(Vector3(0, 0, 0))
	camera.current = true
	camera.fov = 55
	await frames(5)
	await capture("map_overview")
	camera.position = Vector3(2, 10, 18)
	camera.look_at(Vector3(-7, 0.8, -1))
	await frames(5)
	await capture("map_base")
	camera.position = Vector3(19, 7, 19)
	camera.look_at(Vector3(2, 0.5, -6))
	await frames(5)
	await capture("map_combat")
	game.clock.seek(1, 18, 0)
	game.clock.paused = true
	camera.position = Vector3(2, 9, 15)
	camera.look_at(Vector3(-7, 1, -1))
	await frames(5)
	await capture("map_night")
	print("REFINEMENT_MAP_CAPTURE_RESULT failures=", failures)
	quit(1 if failures else 0)
