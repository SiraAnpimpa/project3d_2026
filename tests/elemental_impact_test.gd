extends "res://tests/phase_6_zombie_test.gd"

func run() -> void:
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	player = game.player
	game.debug_controls.set_active(false)
	game.clock.paused = true
	game.waves.enabled = false
	await place_player(RuralTerrain.ground_point(14,6) + Vector3.UP * 0.03)
	key(KEY_Q)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 10)
	key(KEY_R)
	await frames(95)
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(15)
	for kind in ["Normal", "Runner", "Tank"]:
		mouse(MOUSE_BUTTON_RIGHT, false)
		mouse(MOUSE_BUTTON_RIGHT, true)
		await frames(15)
		var enemy := ZombieSpawnFactory.spawn(game.get_node("MainWorld"), load("res://scenes/enemies/%sZombie.tscn" % kind), player, RuralTerrain.ground_point(14,2))
		enemy.set_physics_process(false)
		await frames(3)
		aim_at(player, enemy.global_position + Vector3.UP)
		var hp := enemy.health.current_hp
		check(game.weapons.try_fire(), kind + " real shot accepted")
		check(enemy.health.current_hp == hp - 20, kind + " unchanged damage")
		var impact := game.get_node_or_null("Impact") as GPUParticles3D
		check(impact != null and impact.global_position.is_equal_approx(game.weapons.last_shot_end), kind + " VFX at real hit position")
		if impact != null:
			paused = true
			await create_timer(0.8, true).timeout
			check(is_instance_valid(impact), "pause retains transient until gameplay resumes")
			paused = false
			enemy.health.take_damage(1000)
			await frames(100)
			check(not is_instance_valid(impact), "impact expires after target death and resume")
		enemy.despawn()
		await frames(3)
	game.queue_free()
	await frames(3)
	print("ELEMENTAL IMPACT failures: ", failures)
	quit(1 if failures else 0)
