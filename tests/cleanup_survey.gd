extends "res://tests/refinement_map_test.gd"
## Matched cleanup survey: production player input; geometry fixture pauses time/damage.

var survey_rows: Array = []

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
	var survey: Array = [
		["cabin_front",Vector3(-13.5,0.135,-4)],
		["cabin_west",Vector3(-18.4,0.135,-10)],
		["cabin_back",Vector3(-12,0.135,-16.5)],
		["cabin_east",Vector3(-5.8,0.135,-10)],
		["farm",Vector3(-13.4,0.05,8.5)],
		["farm_fence",Vector3(-22.3,0.05,9)],
		["workbench",Vector3(3,0.05,-6)],
		["workshop_stock",Vector3(4,0.05,-15.5)],
		["depot",Vector3(28,1.85,-12)],
		["tower",Vector3(-21,0.35,-11)],
		["forest_camp",Vector3(-30,2.6,22)],
		["open_field",Vector3(5,0.05,9)],
		["drainage",Vector3(24,0,18)],
		["rescue",Vector3(24,0.65,39)],
		["rescue_edge",Vector3(29,0.65,50)]
	]
	for marker in world.get_node("WaveSpawnPoints").get_children(): survey.append(["entry_"+str(marker.name),marker.global_position])
	for item in survey:
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
		["cabin_side_detail",Vector3(-20,2.0,-16),Vector3(-12,1,-10)],
		["cabin_back_detail",Vector3(-5,2,-21),Vector3(-12,1.4,-10)],
		["workshop_detail",Vector3(9,2.2,-4),Vector3(3,1.5,-10.2)],
		["workshop_back_detail",Vector3(-0.5,2,-17),Vector3(3,1.4,-12)],
		["depot_structure",Vector3(22,3.8,-7),Vector3(29,3.3,-17)],
		["farm_fence_detail",Vector3(-28,1.8,17),Vector3(-24,0.8,8)],
		["rescue",Vector3(51,14,55),Vector3(26,0.6,41)],
		["rescue_detail",Vector3(24,2.1,34),Vector3(25,1,44)],
		["drainage_detail",Vector3(23,2.4,27),Vector3(28,0.7,18)],
		["boundaries",Vector3(87,98,107),Vector3.ZERO]
	]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(6)
		await capture(view[0])
	# This fixture evaluates scenery/movement. Live night pursuit is tested separately;
	# keeping the capture walk free of enemy-body crowding makes its viewpoints repeatable.
	game.waves.enabled = false
	game.clock.seek(1,18,0)
	game.clock.paused = true
	camera.current = false
	player.camera_rig.camera.current = true
	# Actual walking again under night lighting, covering every zone.
	for item in [survey[0],survey[4],survey[6],survey[8],survey[10],survey[11],survey[13],survey[16]]:
		await survey_walk(world,map,"night_"+item[0],item[1])
		player.camera_rig.rotation.y = PI if item[0] == "forest_camp" else 0.0
		player.camera_rig.pitch_pivot.rotation.x = -0.16
		await frames(10)
		await capture("night_player_"+item[0])
	camera.current = true
	camera.position = Vector3(21,8,20)
	camera.look_at(Vector3(-6,1,-5))
	await frames(8)
	await capture("night_farmstead")
	var file := FileAccess.open("user://cleanup_survey.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(survey_rows,"  "))
	print("CLEANUP_SURVEY_RESULT failures=",failures," walks=",survey_rows.size())
	quit(1 if failures else 0)

func survey_walk(world: Node3D,map: RID,label: String,goal: Vector3) -> void:
	var path := NavigationServer3D.map_get_path(map,player.position,goal,true)
	check(path.size() >= 2,"path to "+label)
	for point in path: await walk_to(point)
	var error := Vector2(player.position.x-goal.x,player.position.z-goal.z).length()
	check(error < 0.8,"production player walks to "+label)
	survey_rows.append({"view":label,"goal":[goal.x,goal.y,goal.z],"actual":[player.position.x,player.position.y,player.position.z],"xz_error":error,"path_points":path.size()})
