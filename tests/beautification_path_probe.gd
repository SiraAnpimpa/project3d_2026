extends "res://tests/phase_6_zombie_test.gd"
## Diagnostic: identify geometric waypoint/collision disagreements without changing AI.

func run() -> void:
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
	var marker: Node3D = world.get_node("WaveSpawnPoints/South")
	for tick in 600:
		if NavigationServer3D.map_get_path(map,marker.global_position,player.position,true).size() >= 2: break
		await frames(1)
	await place_player(world.get_node("Bed").position+Vector3(1,0.02,1.5))
	var enemy := ZombieSpawnFactory.spawn(world,load("res://scenes/enemies/NormalZombie.tscn"),player,marker.global_position,12)
	check(enemy != null,"probe spawns through production factory")
	if enemy != null:
		enemy.pursue_target = true
		await wait_for_attack(enemy,3600)
		var path := enemy.agent.get_current_navigation_path()
		var index := enemy.agent.get_current_navigation_path_index()
		print("PATH_PROBE state=",enemy.state," actual=",enemy.position," index=",index," path=",path)
		if index < path.size(): print("PATH_PROBE next=",path[index]," delta=",path[index]-enemy.position," floor=",enemy.is_on_floor()," velocity=",enemy.velocity)
		for hit_index in enemy.get_slide_collision_count():
			var hit := enemy.get_slide_collision(hit_index)
			print("PATH_PROBE collider=",hit.get_collider().get_path()," point=",hit.get_position()," normal=",hit.get_normal())
	print("BEAUTIFICATION_PATH_PROBE_RESULT failures=",failures)
	quit(1 if failures else 0)
