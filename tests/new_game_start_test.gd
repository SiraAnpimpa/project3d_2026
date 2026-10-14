extends "res://tests/phase_3_integration_test.gd"

func run() -> void:
	root.size = Vector2i(1280, 720)
	var checkpoint := root.get_node("DayCheckpoint")
	checkpoint.begin_new()
	check(not checkpoint.has_checkpoint(), "isolated profile starts without a saved game")
	await _check_new_game_primary("no save", "main_no_save")
	set_meta("normal_play", true)
	var game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	game.clock.paused = true
	game.waves.enabled = false
	game.seed_rewards.process_mode = Node.PROCESS_MODE_DISABLED
	game.waves.debug_set_day(10)
	for id in [&"heavy_armor", &"sword", &"iron", &"basic_ammo"]:
		game.inventory.add_item(game.catalog.get_item(id), 1)
	game.inventory.select_seed(&"seed_lead")
	game.get_node("MainWorld/FarmArea/Plot01").interact(game.player)
	game.player.health._set_hp(35)
	check(checkpoint.capture_morning(10), "fixture saves Day 10 with late resources, armor, crop and health")
	game.queue_free()
	await frames(4)
	var menu = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(12)
	check(menu.continue_button.get_index() < menu.play_button.get_index() and menu.continue_button.has_focus() and menu.continue_button.theme_type_variation == &"PrimaryButton", "Continue is first, primary and focused only with a valid latest save")
	check(menu.play_button.theme_type_variation == &"HarvestMenuButton", "New game is secondary when Continue is available")
	check(menu.continue_button.visible and menu.continue_button.text.contains("Day 10"), "Continue remains an explicit separate choice")
	await capture("main_continue_primary")
	menu.play_button.pressed.emit()
	check(menu.new_game_panel.visible and checkpoint.saved_day() == 10, "New game confirms before replacing local progress")
	menu._cancel_new_game()
	check(checkpoint.saved_day() == 10, "cancelling New game preserves the existing save")
	check(checkpoint.request_continue(), "an explicit Continue can still request Day 10")
	var probe := GameClock.new()
	root.add_child(probe)
	probe.paused = true
	checkpoint.prepare_clock(probe)
	check(probe.current_day == 10 and probe.current_hour == 6, "Continue selects the player's saved morning")
	probe.queue_free()
	menu.play_button.pressed.emit()
	menu._confirm_new.pressed.emit()
	await wait_for_gameplay()
	game = current_scene
	game.clock.paused = true
	game.waves.enabled = false
	await frames(3)
	check(game.clock.current_day == 1 and game.clock.current_hour == 6 and game.clock.current_minute == 0, "confirmed New game overrides a pending Continue and starts Day 1 at 06:00")
	check(checkpoint.saved_day() == 1 and checkpoint._pending.is_empty(), "New game replaces the saved checkpoint with its fresh morning")
	check(game.inventory.get_item_amount(&"seed_lead") == 4 and not game.inventory.has_item(&"sword") and not game.inventory.has_item(&"iron") and not game.inventory.has_item(&"basic_ammo") and not game.inventory.has_item(&"heavy_armor"), "late inventory does not leak into New game")
	check(game.equipment.armor_item == null and game.player.health.incoming_damage_multiplier == 1 and game.player.health.current_hp == 100, "New game restores unarmored full starting health")
	check(not game.progression.is_seed_unlocked(&"seed_ice_plant") and not game.progression.is_seed_unlocked(&"seed_large_herb") and game.get_node("MainWorld/FarmArea/Plot01").state == FarmPlot.State.EMPTY, "New game resets late unlocks and planted crops")
	checkpoint.begin_new()
	probe = GameClock.new()
	probe.starting_day = 9
	probe.starting_hour = 23
	root.add_child(probe)
	probe.paused = true
	checkpoint.prepare_clock(probe)
	check(probe.current_day == 1 and probe.current_hour == 6 and probe.current_minute == 0, "editor playtest clock values cannot become a new game's starting day")
	probe.queue_free()
	game.queue_free()
	await frames(4)
	check(checkpoint._write({"complete": true}), "completed run writes a final journal record")
	await _check_new_game_primary("completed run")
	for path in checkpoint.FILES:
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string("{interrupted")
		file.close()
	await _check_new_game_primary("all saves invalid")
	print("NEW_GAME_START_RESULT failures=", failures)
	quit(1 if failures else 0)

func _check_new_game_primary(reason: String, capture_name: String = "") -> void:
	var menu = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(8)
	check(not menu.continue_button.visible and menu.play_button.has_focus() and menu.play_button.theme_type_variation == &"PrimaryButton", "New game is primary and Continue is hidden: " + reason)
	if not capture_name.is_empty(): await capture(capture_name)
	menu.queue_free()
	await frames(3)
