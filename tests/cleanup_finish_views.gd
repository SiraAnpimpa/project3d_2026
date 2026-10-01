extends "res://tests/cleanup_survey.gd"
## Refresh only workshop-related views after the last decorative tool placement.

func run() -> void:
	root.size = Vector2i(1600,900)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	game.clock.paused = true
	game.debug_controls.set_active(false)
	player.health.damage_enabled = false
	game.hud.hide()
	var world: Node3D = game.get_node("MainWorld")
	var map := world.get_world_3d().navigation_map
	for tick in 600:
		if NavigationServer3D.map_get_path(map,player.position,Vector3(-13.5,0.135,-4),true).size() >= 2: break
		await frames(1)
	for item in [
		["cabin_front",Vector3(-13.5,0.135,-4)],
		["cabin_east",Vector3(-5.8,0.135,-10)],
		["workbench",Vector3(3,0.05,-6)],
		["workshop_stock",Vector3(4,0.05,-15.5)]
	]:
		await survey_walk(world,map,item[0],item[1])
		for angle in [0.0,PI*0.5,PI,PI*1.5]:
			player.camera_rig.rotation.y = angle
			player.camera_rig.pitch_pivot.rotation.x = -0.16
			await frames(8)
			await capture("player_"+item[0]+"_"+str(int(rad_to_deg(angle))))
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.far = 300
	camera.fov = 54
	for view in [
		["overview",Vector3(55,65,74),Vector3.ZERO],
		["top",Vector3(0,115,0.01),Vector3.ZERO],
		["farmstead",Vector3(24,17,26),Vector3(-8,0,-1)],
		["cabin_front_detail",Vector3(-18,2.0,-1.5),Vector3(-12,1.2,-9)],
		["workshop_detail",Vector3(9,2.2,-4),Vector3(3,1.5,-10.2)],
		["workshop_back_detail",Vector3(-0.5,2,-17),Vector3(3,1.4,-12)]
	]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(6)
		await capture(view[0])
	game.waves.enabled = false
	game.clock.seek(1,18,0)
	game.clock.paused = true
	camera.current = false
	player.camera_rig.camera.current = true
	await survey_walk(world,map,"night_workbench",Vector3(3,0.05,-6))
	player.camera_rig.rotation.y = 0.0
	player.camera_rig.pitch_pivot.rotation.x = -0.16
	await frames(10)
	await capture("night_player_workbench")
	camera.current = true
	camera.position = Vector3(21,8,20)
	camera.look_at(Vector3(-6,1,-5))
	await frames(8)
	await capture("night_farmstead")
	var file := FileAccess.open("user://cleanup_finish_views.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(survey_rows,"  "))
	print("CLEANUP_FINISH_VIEWS_RESULT failures=",failures," walks=",survey_rows.size())
	quit(1 if failures else 0)
