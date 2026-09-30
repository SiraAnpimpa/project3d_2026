extends "res://tests/phase_5_weapon_test.gd"

func run() -> void:
	root.size = Vector2i(1280,720)
	for scenario in ["day", "night", "aim", "reload", "inventory", "crafting", "pause", "near_dawn", "night10"]:
		var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
		root.add_child(game)
		current_scene = game
		await frames(10)
		game.debug_controls.set_active(false)
		game.clock.set_process(false)
		if scenario in ["night", "aim", "reload", "near_dawn"]: game.clock.skip_to_night()
		if scenario == "night10":
			game.waves.debug_set_day(10)
			game.clock.skip_to_night()
		if scenario == "near_dawn": game.clock.seek(1,5,59)
		if scenario in ["aim", "reload"]:
			key(KEY_Q)
			mouse(MOUSE_BUTTON_RIGHT,true)
			if scenario == "reload":
				game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),10)
				key(KEY_R)
		if scenario == "inventory": key(KEY_TAB)
		if scenario == "crafting": game.crafting_ui.set_open(true)
		if scenario == "pause": key(KEY_ESCAPE)
		await frames(3)
		# Controlled lethal event, including while tree is paused; not balance evidence.
		game.player.health.take_damage(100)
		await frames(3)
		check(game.waves.state == NightWaveManager.State.GAME_OVER and not paused and game.hud.death_panel.visible, "death closes UI and enters GameOver: " + scenario)
		check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not game.weapons.current.is_reloading and not game.player.camera_rig.is_aiming, "death releases mouse/cancels weapon: " + scenario)
		game.clock.seek(11,6)
		await frames(3)
		check(not game.presentation.ending_started, "dead player cannot trigger rescue: " + scenario)
		key(KEY_R)
		await frames(15)
		game = current_scene
		check(game.clock.current_day == 1 and game.player.health.current_hp == 100 and game.weapons.reserve_ammo() == 0 and game.waves.tracked.is_empty(), "R restart resets campaign: " + scenario)
		game.queue_free()
		await frames(5)
	print("PHASE_10_DEATH_MATRIX_RESULT failures=", failures)
	quit(1 if failures else 0)
