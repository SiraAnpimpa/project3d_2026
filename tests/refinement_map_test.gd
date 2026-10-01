extends "res://tests/phase_6_zombie_test.gd"

func run() -> void:
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
	var routes: Array = []
	# Each real enemy controller must navigate each entry both into open combat and the base.
	for target in [Vector3(3,0.05,5), Vector3(-9,0.05,-6)]:
		await place_player(target)
		for kind in ["Normal", "Runner", "Tank"]:
			for marker in world.get_node("WaveSpawnPoints").get_children():
				var enemy := ZombieSpawnFactory.spawn(world, load("res://scenes/enemies/%sZombie.tscn" % kind), player, marker.global_position, 12)
				check(enemy != null, "%s %s validates nav, collision and 12m clearance" % [kind, marker.name])
				if enemy == null: continue
				enemy.pursue_target = true
				var started := Engine.get_physics_frames()
				await wait_for_attack(enemy, 2400)
				check(enemy.state == NormalZombie.State.ATTACK, "%s %s reaches %s" % [kind, marker.name, target])
				var route := {"variant":kind,"entry":str(marker.name),"target":[target.x,target.y,target.z],"simulated_seconds":float(Engine.get_physics_frames()-started)/60.0,"reached":enemy.state == NormalZombie.State.ATTACK}
				routes.append(route)
				print("MAP_ROUTE ",JSON.stringify(route))
				enemy.despawn()
				await frames(3)
	# Walk the player along baked paths using production movement; no position teleports per waypoint.
	await place_player(Vector3(0,0.05,6))
	var goals: Array[Vector3] = []
	for plot in world.get_node("FarmArea").get_children(): goals.append(plot.position + Vector3(0,0,0.8))
	goals.append(world.get_node("Workbench").position + Vector3(0,0,1.2))
	goals.append(Vector3(-9,0,-6))
	goals.append(Vector3(13,0,10))
	for goal in goals:
		var path := NavigationServer3D.map_get_path(map, player.position, goal, true)
		check(path.size() >= 2, "navigation reaches interactive/landing point %s" % goal)
		for point in path: await walk_to(point)
		check(Vector2(player.position.x-goal.x,player.position.z-goal.z).length() < 0.7, "actual player can walk to %s" % goal)
		# Rotate both shoulder cameras at each route destination and check solid clearance.
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
				check(world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty(), "camera has solid clearance")
	var route_file := FileAccess.open("user://map_routes.json",FileAccess.WRITE)
	route_file.store_string(JSON.stringify(routes,"  "))
	print("REFINEMENT_MAP_RESULT failures=", failures)
	quit(1 if failures else 0)

func walk_to(point: Vector3) -> void:
	player.camera_rig.rotation.y = 0
	for tick in 900:
		var offset := Vector2(point.x-player.position.x, point.z-player.position.z)
		if offset.length() < 0.2: break
		var direction := offset.normalized()
		Input.action_press("move_right", maxf(0,direction.x))
		Input.action_press("move_left", maxf(0,-direction.x))
		Input.action_press("move_backward", maxf(0,direction.y))
		Input.action_press("move_forward", maxf(0,-direction.y))
		await frames(1)
	for action in ["move_right","move_left","move_backward","move_forward"]: Input.action_release(action)
	await frames(8)
