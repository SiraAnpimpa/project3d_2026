extends "res://tests/phase_8_variants_test.gd"

func run() -> void:
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	player.health.damage_enabled = false
	game.clock.paused = true
	game.debug_controls.set_active(false)
	await place_player(Vector3(-9,0.05,-6))
	var tank := spawn_variant("Tank",Vector3(-9,0.05,-11))
	for tick in 12:
		await frames(100)
		print("MAP_TANK ",tank.position," state=",tank.state," path=",tank.get_node("NavigationAgent3D").get_current_navigation_path())
	check(tank.state == NormalZombie.State.ATTACK,"Tank navigates shelter rear to front")
	print("REFINEMENT_SHELTER_RESULT failures=",failures)
	quit(failures)
