extends "res://tests/refinement_map_test.gd"
## Baseline/final survey: real player movement, actual shoulder camera and matched overview.

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
		if NavigationServer3D.map_get_path(map,player.position,world.get_node("Bed").position+Vector3(1,0,1.5),true).size() >= 2: break
		await frames(1)
	var house: Vector3 = world.get_node("Bed").global_position + Vector3(0.8,-0.17,8.0)
	var farm: Vector3 = world.get_node("FarmArea").get_child(0).global_position + Vector3(0,0,1.1)
	var bench: Vector3 = world.get_node("Workbench").global_position + Vector3(0,0,2.0)
	var rescue: Vector3 = world.get_node("RescueArea").global_position + Vector3(-5,0,-4)
	var survey: Array = [["house",house],["farm",farm],["workshop",bench],["rescue",rescue]]
	for marker in world.get_node("WaveSpawnPoints").get_children(): survey.append(["entry_"+str(marker.name),marker.global_position])
	for item in survey:
		var path := NavigationServer3D.map_get_path(map,player.position,item[1],true)
		for point in path: await walk_to(point)
		check(Vector2(player.position.x-item[1].x,player.position.z-item[1].z).length() < 0.8,"survey walks to "+item[0])
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
		["overview",Vector3(55,65,74),Vector3(0,0,0)],
		["top",Vector3(0,115,0.01),Vector3.ZERO],
		["farmstead",Vector3(24,17,26),Vector3(-8,0,-1)],
		["rescue",Vector3(51,14,55),Vector3(26,0.6,41)],
		["boundaries",Vector3(87,98,107),Vector3.ZERO]
	]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(6)
		await capture(view[0])
	game.clock.seek(1,18,0)
	game.clock.paused = true
	camera.position = Vector3(21,8,20)
	camera.look_at(Vector3(-6,1,-5))
	await frames(8)
	await capture("night_farmstead")
	print("BEAUTIFICATION_SURVEY_RESULT failures=",failures)
	quit(1 if failures else 0)
