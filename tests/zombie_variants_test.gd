extends "res://tests/phase_7_lifecycle_test.gd"
## Verify authored mesh/rig variants through the production spawn and AI paths.

func model_bounds(enemy: NormalZombie) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in enemy._meshes:
		var bounds := enemy.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		result = bounds if first else result.merge(bounds)
		first = false
	return result

func animation_bindings_valid(enemy: NormalZombie, clip: StringName) -> bool:
	var player := enemy.animation_player
	if player == null or not player.has_animation(clip): return false
	var animation := player.get_animation(clip)
	if animation.length <= 0 or animation.get_track_count() == 0: return false
	var origin := player.get_node(player.root_node)
	for track in animation.get_track_count():
		var path := animation.track_get_path(track)
		var node := origin.get_node_or_null(NodePath(path.get_concatenated_names()))
		if node == null: return false
		if node is Skeleton3D and path.get_subname_count() > 0:
			if node.find_bone(String(path.get_subname(0))) < 0: return false
	return true

func run() -> void:
	root.size = Vector2i(1280,720)
	await fresh()
	game.waves.enabled = false
	game.clock.set_process(false)
	player.health.damage_enabled = false
	var spawn_points: Array[Node] = game.get_node("MainWorld/WaveSpawnPoints").get_children()
	var normal: ZombieData = load("res://resources/enemies/normal_zombie.tres")
	check(normal.visual_scene.resource_path.ends_with("/Zombie.glb"), "normal zombie keeps original chubby model")
	var heights := {}
	for row in [["RunnerZombie","Zombie-VlXjG0N8Eg.glb",100,10,4.5], ["TankZombie","Big arm.glb",400,30,1.5]]:
		var scene: PackedScene = load("res://scenes/enemies/%s.tscn" % row[0])
		var enemy: NormalZombie
		for point in spawn_points:
			enemy = ZombieSpawnFactory.spawn(game,scene,player,point.global_position,8)
			if enemy != null: break
		check(enemy != null, "production factory spawns variant on current navigation map: " + row[0])
		if enemy == null: continue
		check(enemy.data.visual_scene.resource_path.ends_with("/"+row[1]) and enemy._meshes.size() > 0, "correct authored mesh loads: " + row[1])
		check(enemy.health.max_hp == row[2] and enemy.data.damage == row[3] and enemy.data.move_speed == row[4], "HP, damage and speed preserved: " + row[0])
		var collider := enemy.get_node("CollisionShape3D") as CollisionShape3D
		var bounds := model_bounds(enemy)
		heights[row[0]] = bounds.size.y
		check(is_equal_approx(collider.position.y,collider.shape.height/2.0) and is_equal_approx(collider.shape.radius,enemy.agent.radius), "grounded body capsule matches navigation clearance: " + row[0])
		check(absf(bounds.size.y-collider.shape.height) < .15 and absf(bounds.position.y) < .03, "collision height fits actual model and feet stay at ground origin: " + row[0])
		for clip in [enemy.data.idle_animation,enemy.data.walk_animation,enemy.data.attack_animation,enemy.data.death_animation]:
			check(animation_bindings_valid(enemy,clip), "clip tracks bind to actual model rig: %s / %s" % [row[0],clip])
		check(enemy.animation_player.get_animation(enemy.data.walk_animation).loop_mode == Animation.LOOP_LINEAR and enemy.animation_player.get_animation(enemy.data.attack_animation).loop_mode == Animation.LOOP_NONE, "locomotion loops and attacks remain one-shot: " + row[0])
		var before := enemy.global_position
		enemy.pursue_target = true
		await frames(45)
		check(enemy.global_position.distance_to(before) > .2 and enemy.animation_player.current_animation == enemy.data.walk_animation, "AI chases with the intended Run/Walk clip: " + row[0])
		if row[0] == "TankZombie":
			check(enemy._meshes[0].name == "Zombie_Arm", "Tank uses the Big Arm mesh, rather than a scaled normal zombie")
			var material := enemy._meshes[0].get_active_material(0) as StandardMaterial3D
			check(material != null and material.albedo_color.r > material.albedo_color.g*2, "Big Arm keeps the red Tank tint")
		# Exercise the existing windup and health receiver with the new rig in place.
		player.set_physics_process(false)
		player.health.damage_enabled = true
		player.health.reset()
		enemy.position = player.position + Vector3(0,0,1.0)
		enemy.velocity = Vector3.ZERO
		enemy._windup = -1
		enemy._cooldown = 0
		for _tick in 60:
			await frames(1)
			if enemy.attacks_landed > 0: break
		check(enemy.attacks_landed == 1 and player.health.current_hp == 100-row[3] and enemy.animation_player.current_animation == enemy.data.attack_animation, "new rig attacks through original windup and damage logic: " + row[0])
		enemy.health.take_damage(enemy.health.max_hp)
		check(enemy.state == NormalZombie.State.DEAD and enemy.collision_layer == 0 and enemy.animation_player.current_animation == enemy.data.death_animation, "new rig plays Death and disables collision: " + row[0])
		await frames(80)
		check(not is_instance_valid(enemy), "death cleanup releases new model/rig instance: " + row[0])
		player.set_physics_process(true)
		player.health.damage_enabled = false
		player.health.reset()
	check(heights.get("RunnerZombie",99) < 1.5 and heights.get("TankZombie",0) > 2.5, "small Runner and large Big Arm Tank have distinct silhouettes")
	# Real mixed waves must instantiate the new assets via the same resource links.
	game.waves.enabled = true
	waves.debug_set_day(7)
	game.progression.choose_daily_seed(7,&"seed_fire_pepper")
	game.clock.skip_to_night()
	var observed := {}
	var expected := {}
	for scene in waves.data.spawn_queue(): expected[scene.resource_path] = int(expected.get(scene.resource_path,0))+1
	for _tick in 100:
		waves._spawn_wait = 0
		await frames(2)
		for enemy: NormalZombie in waves.alive.values():
			observed[enemy.scene_file_path] = int(observed.get(enemy.scene_file_path,0))+1
			if enemy.data.zombie_id == &"runner_zombie": check(enemy._meshes.any(func(mesh: MeshInstance3D) -> bool: return mesh.name == "Zombie"), "mixed wave Runner uses small green zombie")
			if enemy.data.zombie_id == &"tank_zombie": check(enemy._meshes[0].name == "Zombie_Arm" and enemy.health.max_hp == 400, "mixed wave Tank uses Big Arm and 400 HP")
			enemy.health.take_damage(enemy.health.max_hp)
		if waves.state == NightWaveManager.State.CLEARED: break
	check(observed == expected and waves.state == NightWaveManager.State.CLEARED, "mixed wave composition/spawn/death accounting remains intact")
	print("ZOMBIE_VARIANTS_RESULT failures=",failures)
	quit(1 if failures else 0)
