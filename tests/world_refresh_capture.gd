extends "res://tests/cleanup_survey.gd"
## Matched visual survey: same cameras and clock fixtures before/after scenery edits.

func run() -> void:
	root.size = Vector2i(1600,900)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	player = game.player
	game.clock.paused = true
	game.clock.set_process(false)
	game.waves.enabled = false
	game.debug_controls.set_active(false)
	player.health.damage_enabled = false
	game.hud.hide()
	var world: Node3D = game.get_node("MainWorld")
	var map := world.get_world_3d().navigation_map
	for tick in 600:
		if NavigationServer3D.map_get_path(map,player.position,Vector3(-13.5,0.135,-4),true).size() >= 2: break
		await frames(1)
	for item in [
		["home",Vector3(-13.5,0.135,-4),0.0],
		["farm",Vector3(-13.4,0.05,8.5),PI],
		["forest",Vector3(-30,2.6,22),PI*0.5],
		["depot",Vector3(28,1.85,-12),0.0],
		["rescue",Vector3(24,0.65,39),PI]
	]:
		await survey_walk(world,map,item[0],item[1])
		player.camera_rig.rotation.y = item[2]
		player.camera_rig.pitch_pivot.rotation.x = -0.16
		await frames(10)
		await capture("player_"+item[0])
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.far = 350
	camera.fov = 54
	for view in [
		["overview",Vector3(55,65,74),Vector3.ZERO],
		["farmstead",Vector3(24,17,26),Vector3(-8,0,-1)],
		["home",Vector3(-18,2,-1.5),Vector3(-12,1.2,-9)],
		["forest",Vector3(-22,8,31),Vector3(-34,3,18)],
		["depot",Vector3(18,9,-2),Vector3(34,3,-22)],
		["rescue",Vector3(51,14,55),Vector3(26,0.6,41)],
		["road",Vector3(18,4,23),Vector3(17,2,38)]
	]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(8)
		await capture(view[0])
	for time in [[6,0,"dawn"],[17,30,"dusk"],[18,0,"night"]]:
		game.clock.seek(1,time[0],time[1])
		game.clock.paused = true
		camera.position = Vector3(21,8,20)
		camera.look_at(Vector3(-6,1,-5))
		await frames(10)
		await capture(time[2]+"_farmstead")
	game.clock.seek(10,18,0)
	await frames(10)
	await capture("final_night")
	print("WORLD_REFRESH_CAPTURE_RESULT failures=",failures," walks=",survey_rows.size())
	quit(1 if failures else 0)
