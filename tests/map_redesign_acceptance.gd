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
	var farm_eye := Vector3(-8,1.7,4.6)
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
	var goals := [Vector3(-9,0,-6),Vector3(-4.5,0,0.1),Vector3(12,0,4),
		RuralTerrain.ground_point(-36,11),RuralTerrain.ground_point(-47,29),
		RuralTerrain.ground_point(-10,-40),RuralTerrain.ground_point(4,-26),
		RuralTerrain.ground_point(31,-12),RuralTerrain.ground_point(45,-16),
		RuralTerrain.ground_point(28,16),RuralTerrain.ground_point(18,39),
		RuralTerrain.ground_point(22,52),Vector3(13,0,10),Vector3(-8,0,4.6)]
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
	print("MAP_REDESIGN_ACCEPTANCE_RESULT failures=",failures)
	quit(1 if failures else 0)
