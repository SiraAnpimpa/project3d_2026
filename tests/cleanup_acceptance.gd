extends "res://tests/refinement_map_test.gd"
## Real controller/input on the new terrain. Resource/damage fixtures isolate map checks.

func run() -> void:
	root.size = Vector2i(1280,720)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	game.clock.paused = true
	game.debug_controls.set_active(false)
	player.health.damage_enabled = false
	var world: Node3D = game.get_node("MainWorld")
	var map := world.get_world_3d().navigation_map
	var farm_eye := Vector3(-13.4,1.7,8.5)
	for marker: Node3D in world.get_node("WaveSpawnPoints").get_children():
		var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(farm_eye,marker.global_position+Vector3.UP*1.0,1,[player.get_rid()]))
		check(not hit.is_empty(),"%s entry is screened from farm centre by terrain/landmark" % marker.name)
		print("SPAWN_ENTRY ",marker.name," point=",marker.global_position," distance=",marker.global_position.distance_to(player.global_position)," screened=",not hit.is_empty())
	# Every plot receives actual E planting/harvesting, not direct plot method calls.
	game.inventory.add_item(game.catalog.get_item(&"seed_lead"),12)
	game.inventory.select_seed(&"seed_lead")
	for plot: FarmPlot in world.get_node("FarmArea").get_children():
		await walk_to(plot.position+Vector3(0,0,0.9))
		key(KEY_E)
		check(plot.state == FarmPlot.State.PLANTED,"actual E planting remains easy at %s" % plot.name)
	game.clock.advance_game_minutes(40)
	for plot: FarmPlot in world.get_node("FarmArea").get_children():
		await walk_to(plot.position+Vector3(0,0,0.9))
		key(KEY_E)
		check(plot.state == FarmPlot.State.EMPTY,"actual E harvest remains easy at %s" % plot.name)
	# Walk through all eight zones, uphill/downhill and across the shallow drainage.
	var goals := [world.get_node("Bed").position+Vector3(1.0,0.02,1.5),world.get_node("Workbench").position+Vector3(0,0,1.1),Vector3(12,0,4),
		RuralTerrain.ground_point(-36,11),RuralTerrain.ground_point(-47,29),
		RuralTerrain.ground_point(-10,-40),RuralTerrain.ground_point(4,-26),
		RuralTerrain.ground_point(31,-12),RuralTerrain.ground_point(45,-16),
		RuralTerrain.ground_point(28,16),RuralTerrain.ground_point(18,39),
		RuralTerrain.ground_point(22,52),world.get_node("RescueArea").position,Vector3(-13.4,0,8.5)]
	for marker: Node3D in world.get_node("WaveSpawnPoints").get_children():
		goals.append(RuralTerrain.ground_point(marker.position.x,marker.position.z))
	for edge in [Vector2(0,-54),Vector2(54,36),Vector2(20,54),Vector2(-54,0)]:
		goals.append(RuralTerrain.ground_point(edge.x,edge.y))
	for goal: Vector3 in goals:
		var path := NavigationServer3D.map_get_path(map,player.position,goal,true)
		check(path.size() >= 2,"navigation connects zone destination %s" % goal)
		for point: Vector3 in path: await walk_to(point)
		check(Vector2(player.position.x-goal.x,player.position.z-goal.z).length() < 1.3,"actual player reaches zone destination %s" % goal)
		if maxf(absf(goal.x),absf(goal.z)) >= 54:
			var action := "move_right" if goal.x >= 54 else "move_left" if goal.x <= -54 else "move_backward" if goal.z >= 54 else "move_forward"
			Input.action_press(action)
			await frames(120)
			Input.action_release(action)
			await frames(8)
			var extent := maxf(absf(player.position.x),absf(player.position.z))
			check(extent > 55 and extent < 55.5,"real character reaches outer safety collision and cannot leave terrain")
		check(absf(player.position.y-RuralTerrain.height_at(player.position.x,player.position.z)) < 0.18,"player is grounded without floating/sliding through terrain")
		for side in [-1,1]:
			player.camera_rig.shoulder_side = side
			for yaw in [0,PI/2,PI,PI*1.5]:
				player.camera_rig.rotation.y = yaw
				player.camera_rig.update_pose(0)
				var query := PhysicsShapeQueryParameters3D.new()
				var sphere := SphereShape3D.new()
				sphere.radius = 0.075
				query.shape = sphere
				query.transform.origin = player.camera_rig.camera.global_position
				query.collision_mask = 1
				check(world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty(),"shoulder camera clears slope/trees/zone collision")
	# Walk the marked road at the existing 4 m/s speed and record real controller travel.
	var porch := Vector3(-13.5,0,-3)
	for point in NavigationServer3D.map_get_path(map,player.position,porch,true): await walk_to(point)
	var travel_start := Engine.get_physics_frames()
	var previous := player.position
	var travelled := 0.0
	for waypoint in [Vector2(-3,-1),Vector2(0,7),Vector2(7,16),Vector2(9,25),Vector2(14,33),Vector2(21,35),Vector2(25,39),Vector2(29,43)]:
		await walk_to(RuralTerrain.ground_point(waypoint.x,waypoint.y))
		travelled += previous.distance_to(player.position)
		previous = player.position
	var seconds := float(Engine.get_physics_frames()-travel_start)/60.0
	check(player.position.distance_to(world.get_node("RescueArea").position) < 0.8,"player follows the visible road into the evacuation clearing")
	check(seconds > 12 and seconds < 32,"relocated rescue has useful separation at production walk speed")
	var occlusion_samples: Array = []
	for eye in [Vector3(-13.5,1.9,-3),Vector3(-13.4,1.9,8.5),Vector3(-19.8,1.9,12.5),Vector3(-7,1.9,4.5)]:
		var hidden := 0
		for offset in [Vector3.ZERO,Vector3(-2,0,-2),Vector3(2,0,-2),Vector3(-2,0,2),Vector3(2,0,2)]:
			var endpoint: Vector3 = world.get_node("RescueArea").position+offset
			var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(eye,endpoint,1,[player.get_rid()]))
			if not hit.is_empty() and hit.position.distance_to(endpoint) > 0.2: hidden += 1
		occlusion_samples.append({"eye":[eye.x,eye.y,eye.z],"hidden_pad_samples":hidden})
		check(hidden >= 3,"landing surface is gradually revealed beyond the farm / roadside shoulder")
	var distance_file := FileAccess.open("user://cleanup_rescue_distance.json",FileAccess.WRITE)
	distance_file.store_string(JSON.stringify({"walk_seconds":seconds,"walked_waypoint_distance_m":travelled,"house_to_landing_m":Vector3(-12,0,-10).distance_to(world.get_node("RescueArea").position),"occlusion":occlusion_samples},"  "))
	print("RESCUE_WALK seconds=",seconds," distance=",travelled)
	# Shoot each real variant from every actual approach after it navigates into sight.
	await walk_to(Vector3(10,0,10))
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),200)
	key(KEY_Q)
	key(KEY_R)
	await frames(95)
	game.waves.enabled = false
	game.clock.seek(1,18,0)
	game.clock.paused = true
	for kind in ["Normal","Runner","Tank"]:
		for marker: Node3D in world.get_node("WaveSpawnPoints").get_children():
			var enemy := ZombieSpawnFactory.spawn(world,load("res://scenes/enemies/%sZombie.tscn" % kind),player,marker.global_position,12)
			check(enemy != null,"combat fixture safely spawns %s at %s" % [kind,marker.name])
			if enemy == null: continue
			enemy.pursue_target = true
			mouse(MOUSE_BUTTON_RIGHT,true)
			var saved := false
			for tick in 6000:
				if not is_instance_valid(enemy) or enemy.health.is_dead: break
				aim_at(player,enemy.global_position+Vector3.UP)
				if player.aim_ray.hit_collider == enemy:
					if not saved:
						await capture("combat_%s_%s" % [kind,marker.name])
						saved = true
					if game.weapons.current.current_magazine == 0: key(KEY_R)
					else:
						mouse(MOUSE_BUTTON_LEFT,true)
						mouse(MOUSE_BUTTON_LEFT,false)
				await frames(1)
			check(is_instance_valid(enemy) and enemy.health.is_dead,"actual rifle combat kills %s from %s across terrain/LOS" % [kind,marker.name])
			if is_instance_valid(enemy): enemy.despawn()
			mouse(MOUSE_BUTTON_RIGHT,false)
			await frames(3)
	# Ordinary six-enemy Day 1 wave through clock events/cadence, without direct spawn calls.
	game.waves.enabled = true
	game.clock.seek(1,17,50)
	game.clock.seek(1,18,0)
	var observed: Dictionary = {}
	var entries: Dictionary = {}
	var enemies_by_entry: Dictionary = {}
	var grounded := true
	for tick in 720:
		await frames(1)
		for id in game.waves.tracked:
			if observed.has(id): continue
			observed[id] = true
			var enemy: NormalZombie = game.waves.tracked[id]
			grounded = grounded and absf(enemy.position.y-RuralTerrain.height_at(enemy.position.x,enemy.position.z)) < 0.3
			for marker: Node3D in world.get_node("WaveSpawnPoints").get_children():
				if enemy.position.distance_to(marker.position) < 0.8:
					entries[marker.name] = true
					enemies_by_entry[marker.name] = enemy
	check(observed.size() == 6 and game.waves.pending.is_empty(),"ordinary night cadence safely spawns all six Day 1 enemies")
	check(entries.size() == 4,"ordinary night wave uses all four real environment approaches")
	check(grounded,"every observed ordinary-wave spawn starts on the terrain rather than midair")
	for entry in enemies_by_entry:
		mouse(MOUSE_BUTTON_RIGHT,true)
		aim_at(player,(enemies_by_entry[entry] as NormalZombie).position+Vector3.UP)
		await frames(3)
		await capture("wave_"+str(entry))
		mouse(MOUSE_BUTTON_RIGHT,false)
	print("CLEANUP_ACCEPTANCE_RESULT failures=",failures)
	quit(1 if failures else 0)
