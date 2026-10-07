extends "res://tests/cleanup_survey.gd"
## Environment transitions, route margins and player-level visibility at midday/night.

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
	var world: Node3D = game.get_node("MainWorld")
	var scenery: RuralEnvironment = world.get_node("RuralEnvironment")
	var env: Environment = world.get_node("WorldEnvironment").environment
	check(env.background_mode == Environment.BG_SKY,"runtime uses a procedural horizon")
	check(env.fog_enabled and env.fog_depth_begin >= 42.0,"near combat and interaction distances have no depth fog")
	check(not env.volumetric_fog_enabled,"environment supports the existing Compatibility renderer")
	for point in scenery.wayfinding_points:
		check(RuralTerrain.trail_distance(point) >= 2.7,"roadside stake clears the walking lane")
		check(point.distance_to(RuralTerrain.RESCUE) >= 10,"roadside stake clears helicopter landing")
	var sky_material := env.sky.sky_material as ProceduralSkyMaterial
	check(sky_material != null,"sky is a native ProceduralSkyMaterial")
	for hour in [6,12,17,18,0]:
		game.clock.seek(1,hour,0)
		check(sky_material.sky_horizon_color == sky_material.ground_horizon_color,"horizon color joins at %02d:00" % hour)
		check(sky_material.sky_energy_multiplier == sky_material.ground_energy_multiplier,"horizon energy joins at %02d:00" % hour)
		check(is_equal_approx(world.get_node("Sun").light_energy,1.2 if game.clock.is_daytime else 0.22),"combat light energy remains consistent at %02d:00" % hour)
	game.clock.seek(1,12,0)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 54
	camera.far = 350
	camera.position = Vector3(24,17,26)
	camera.look_at(Vector3(-8,0,-1))
	game.hud.hide()
	await frames(10)
	await capture("midday_farmstead")
	var map := world.get_world_3d().navigation_map
	for tick in 600:
		if NavigationServer3D.map_get_path(map,player.position,Vector3(3,0.05,-6),true).size() >= 2: break
		await frames(1)
	camera.current = false
	player.camera_rig.camera.current = true
	game.hud.show()
	await survey_walk(world,map,"workbench",Vector3(3,0.05,-6))
	player.camera_rig.rotation.y = 0
	player.camera_rig.pitch_pivot.rotation.x = -0.16
	await frames(10)
	await capture("midday_gameplay")
	key(KEY_E)
	await frames(5)
	check(game.crafting_ui.is_open and game.crafting_ui.screen.visible,"actual E reaches the workshop crafting interface")
	game.crafting_ui.set_open(false)
	game.clock.seek(1,18,0)
	await frames(10)
	await capture("night_gameplay")
	var ordinary_night := sky_material.sky_top_color
	game.clock.seek(10,18,0)
	check(ordinary_night != sky_material.sky_top_color,"final night retains its distinct visual warning")
	print("WORLD_REFRESH_RESULT failures=",failures," roadside_stakes=",scenery.wayfinding_points.size())
	quit(1 if failures else 0)
