extends "res://tests/refinement_map_test.gd"

func run() -> void:
	root.size = Vector2i(1400,900)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	game.clock.paused = true
	game.hud.hide()
	player.health.damage_enabled = false
	var world: Node3D = game.get_node("MainWorld")
	var map := world.get_world_3d().navigation_map
	var goal: Vector3 = world.get_node("Bed").position+Vector3(1.0,0.02,1.5)
	print("CABIN_NEAREST ",NavigationServer3D.map_get_closest_point(map,goal)," desired=",goal)
	var path := NavigationServer3D.map_get_path(map,player.position,goal,true)
	print("CABIN_PATH ",path)
	for point in path:
		await walk_to(point)
		print("CABIN_WALK desired=",point," actual=",player.position," on_floor=",player.is_on_floor())
		var ray := PhysicsRayQueryParameters3D.create(player.position+Vector3.UP,goal+Vector3.UP,1,[player.get_rid()])
		print("CABIN_RAY ",world.get_world_3d().direct_space_state.intersect_ray(ray))
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.position = Vector3(-13.5,2.5,-1.8)
	camera.look_at(Vector3(-13.5,1.2,-9.0))
	await frames(8)
	await capture("cabin_entry_probe")
	var anchor := world.get_node("RuralEnvironment/Cabin")
	for part in anchor.find_children("*","MeshInstance3D",true,false):
		if part.get_aabb().position.y > 0.29: part.hide()
	camera.position = Vector3(-13,12,-7)
	camera.look_at(Vector3(-12,0,-10))
	await frames(8)
	await capture("cabin_cut_probe")
	print("CABIN_PROBE_RESULT failures=",failures)
	quit()
