extends "res://tests/cleanup_survey.gd"
## Matched composition views. Routes/interactions are verified by separate input fixtures.

func run() -> void:
	root.size = Vector2i(1600,900)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	game.clock.set_process(false)
	game.clock.paused = true
	game.waves.enabled = false
	game.debug_controls.set_active(false)
	game.player.health.damage_enabled = false
	game.hud.hide()
	game.clock.seek(1,9,0)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.far = 350
	camera.fov = 54
	for view in [
		["farmstead",Vector3(24,17,26),Vector3(-8,0,-1)],
		["home_front",Vector3(-18,2.1,-1.5),Vector3(-12,1.2,-9)],
		["home_back",Vector3(-6,2,-22),Vector3(-12,1,-10)],
		["home_cache",Vector3(-12.3,1.8,-10),Vector3(-10.2,0.7,-12.3)],
		["workshop",Vector3(9,2.2,-4),Vector3(3,1.1,-10.2)],
		["workshop_stock",Vector3(9.5,2.5,-17),Vector3(2.5,0.8,-12)],
		["tower_base",Vector3(-26,1.7,-13),Vector3(-21,1,-18)],
		["farm_border",Vector3(-29,2.4,17),Vector3(-20,0.5,8)],
		["open_apron",Vector3(8,2.4,13),Vector3(3,0.6,3)],
		["forest",Vector3(-22,8,31),Vector3(-34,3,18)],
		["forest_ground",Vector3(-29,3.7,25),Vector3(-34,3.0,20)],
		["forest_stand",Vector3(-29,5.5,-1),Vector3(-43,2.8,1)],
		["forest_north",Vector3(-25,5,-27),Vector3(-38,3,-30)],
		["ridge",Vector3(4,5,-19),Vector3(-5,3,-32)],
		["eastern_rocks",Vector3(32,2,22),Vector3(41,1.7,13)],
		["depot",Vector3(18,9,-2),Vector3(34,3,-22)],
		["depot_props",Vector3(25,3.2,-8),Vector3(32,2.4,-16)],
		["depot_verge",Vector3(46,3.5,-35),Vector3(39,2.4,-27)],
		["road",Vector3(18,4,23),Vector3(17,2,38)],
		["rescue",Vector3(51,14,55),Vector3(26,0.6,41)],
		["rescue_cache",Vector3(22,2.1,35),Vector3(18.7,1.1,40)],
		["drainage",Vector3(23,2.4,27),Vector3(28,0.7,18)],
		["overview",Vector3(55,65,74),Vector3.ZERO]
	]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(6)
		await capture(view[0])
	game.clock.seek(1,18,0)
	camera.position = Vector3(24,17,26)
	camera.look_at(Vector3(-8,0,-1))
	await frames(8)
	await capture("night_farmstead")
	print("SCENERY_CAPTURE_RESULT failures=",failures," views=24")
	quit(1 if failures else 0)
