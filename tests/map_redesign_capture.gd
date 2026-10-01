extends "res://tests/phase_3_integration_test.gd"

func run() -> void:
	root.size = Vector2i(1600,900)
	set_meta("normal_play",true)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	game.debug_controls.set_active(false)
	game.clock.paused = true
	game.hud.hide()
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.far = 300
	camera.current = true
	camera.fov = 54
	for view in [
		["map_overview",Vector3(87,98,107),Vector3(0,0,0)],
		["playable_overview",Vector3(55,65,74),Vector3(0,0,0)],
		["house_water_tower",Vector3(-3,7,15),Vector3(-17,6,-17)],
		["farmstead",Vector3(24,12,25),Vector3(-8,1,-4)],
		["north_ridge",Vector3(3,4,8),Vector3(-8,3,-38)],
		["forest",Vector3(-16,5,20),Vector3(-43,4,2)],
		["abandoned",Vector3(11,5,8),Vector3(33,2,-18)],
		["rescue_road",Vector3(2,6,9),Vector3(17,0.5,39)]
	]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(5)
		await capture(view[0])
	game.clock.seek(1,18,0)
	game.clock.paused = true
	camera.position = Vector3(21,8,20)
	camera.look_at(Vector3(-6,1,-5))
	await frames(8)
	await capture("night_farmstead")
	print("MAP_REDESIGN_CAPTURE_RESULT failures=",failures)
	quit(1 if failures else 0)
