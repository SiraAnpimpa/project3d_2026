extends "res://tests/cleanup_acceptance.gd"
## Render the unchanged acceptance night section separately from its lengthy map-wide walk.

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
	for tick in 600:
		if NavigationServer3D.map_get_path(map,player.position,Vector3(10,0,10),true).size() >= 2: break
		await frames(1)
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
	print("CLEANUP_NIGHT_RESULT failures=",failures)
	quit(1 if failures else 0)
