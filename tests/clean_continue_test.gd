extends "res://tests/phase_3_integration_test.gd"
## Two processes verify on-disk persistence; read stage uses the real Continue UI/loading.

var checkpoint: Node
var game: Node3D

func run() -> void:
	root.size = Vector2i(1280, 720)
	checkpoint = root.get_node("DayCheckpoint")
	if "--write-stage" in OS.get_cmdline_user_args():
		await write_stage()
	else:
		await read_stage()
	print("CLEAN_CONTINUE_RESULT failures=", failures)
	quit(1 if failures else 0)

func write_stage() -> void:
	for path in checkpoint.FILES:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var menu = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(12)
	check(not menu.continue_button.visible, "fresh profile shows New game without Continue")
	await capture("main_new")
	menu.queue_free()
	await frames(2)
	set_meta("normal_play", true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	game.clock.paused = true
	check(checkpoint.saved_day() == 1, "new run creates its Day 1 morning checkpoint")
	var starter: Dictionary = checkpoint.read_checkpoint()
	game.inventory.add_item(game.catalog.get_item(&"copper"), 5)
	game.clock.advance_game_minutes(120)
	check(checkpoint.read_checkpoint() == starter, "midday resources and clock changes never replace the morning")
	game.clock.paused = false
	game.clock.skip_to_night()
	game.clock.skip_to_day()
	game.clock.paused = true
	await frames(4)
	check(checkpoint.saved_day() == 2 and game.inventory.get_item_amount(&"seed_lead") == 6, "natural dawn saves after daily seed delivery exactly once")
	# Build a representative morning: late unlocks, queued choices, loaded ammo and crops.
	game.waves.debug_set_day(5)
	await frames(3)
	if game.seed_rewards.is_open: game.seed_rewards._close()
	game.inventory.add_item(game.catalog.get_item(&"iron"), 20)
	game.inventory.add_item(game.catalog.get_item(&"paper"), 20)
	game.inventory.add_item(game.catalog.get_item(&"copper"), 15)
	var sword: CraftRecipe = game.recipe_book.get_recipe(&"sword")
	for entry: RecipeEntry in sword.ingredients: game.inventory.add_item(entry.item, entry.quantity)
	check(game.crafting_system.craft(sword).begins_with("Crafted"), "fixture crafts a persistent weapon")
	game.equipment.equip_weapon(2, game.catalog.get_item(&"sword"))
	game.equipment.selected_weapon_slot = 0
	game.equipment.equipment_changed.emit()
	var pistol: WeaponRuntime = game.weapons.current
	pistol.current_magazine = 7
	pistol.selected_ammo_type = game.catalog.get_item(&"fire_ammo")
	pistol.magazine_ammo_type = game.catalog.get_item(&"fire_ammo")
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 37)
	game.player.health._set_hp(75)
	game.player.stamina._set_stamina(85)
	var plots := game.get_node("MainWorld/FarmArea").get_children().filter(func(node: Node) -> bool: return node is FarmPlot)
	plots[0].restore_checkpoint({"plant":"lead", "age":36.0})
	plots[1].restore_checkpoint({"plant":"iron", "age":24.0})
	check(checkpoint.capture_morning(5), "checkpoint serializes inventory, magazines, equipment, crop growth and progression")
	var morning: Dictionary = checkpoint.read_checkpoint()
	var saved_text := JSON.stringify(morning)
	var expectation := FileAccess.open("user://continue_test_expected.json", FileAccess.WRITE)
	expectation.store_string(saved_text)
	expectation.close()
	game.inventory.remove_item(&"copper", 3)
	game.inventory.add_item(game.catalog.get_item(&"basic_medicine"), 2)
	game.player.health.take_damage(15)
	plots[0].clear_plot()
	game.progression.choose_daily_seed(5, &"seed_ice_plant")
	game.clock.advance_game_minutes(600)
	check(checkpoint.read_checkpoint() == morning, "crafts, harvests, health damage and seed choices during the day are rolled back")
	game.pause_menu.set_open(true)
	check(not game.pause_menu.has_node("Screen/Panel/Rows/Cheats"), "Esc menu exposes no cheat entry")
	await frames(12)
	await capture("pause_clean")
	game.pause_menu._open_settings()
	game.pause_menu.settings.tabs.current_tab = 1
	await frames(12)
	var labels: Array[Node] = game.pause_menu.settings.find_children("*", "Label", true, false)
	check(not labels.any(func(label: Label) -> bool: return label.text.to_lower().contains("grass") or label.text.contains("Changes apply")), "Graphics has no grass descriptions or persistent explanatory footer")
	await capture("settings_clean")
	game.pause_menu.settings.close()
	game.pause_menu.set_open(false)
	key(KEY_T)
	check(game.cheats_menu.is_open, "T still opens the secret cheat window")
	key(KEY_ESCAPE)
	game.queue_free()
	await frames(4)

func read_stage() -> void:
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("user://continue_test_expected.json"))
	check(checkpoint.saved_day() == 5 and checkpoint.read_checkpoint() == expected, "a fresh process finds the complete Day 5 checkpoint on disk")
	var menu = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(12)
	check(menu.continue_button.visible and menu.continue_button.text.contains("Day 5"), "title menu offers Continue with the saved day")
	await capture("main_continue")
	await click(menu.play_button)
	check(menu.new_game_panel.visible and checkpoint.saved_day() == 5, "New game confirmation protects existing progress")
	key(KEY_ESCAPE)
	check(not menu.new_game_panel.visible and checkpoint.saved_day() == 5, "cancelling New game keeps the checkpoint")
	await click(menu.continue_button)
	await wait_for_gameplay()
	game = current_scene
	game.clock.paused = true
	await frames(8)
	check(game.clock.current_day == 5 and game.clock.current_hour == 6 and game.clock.current_minute == 0, "real Continue/loading returns to Day 5 at 06:00")
	check(game.inventory.get_item_amount(&"basic_ammo") == 37 and not game.inventory.has_item(&"basic_medicine"), "start-of-day resources return and later crafted items disappear")
	check(game.player.health.current_hp == 75, "start-of-day health is restored without free healing")
	check(game.equipment.get_equipped_weapon(2).id == &"sword" and game.weapons.current.current_magazine == 7 and game.weapons.current.magazine_ammo_type.id == &"fire_ammo", "loadout and loaded elemental rounds survive restart")
	check(game.crafting_system.crafted_weapon_ids.has(&"sword") and not game.crafting_ui._buttons[game.recipe_book.get_recipe(&"sword")].visible, "crafted weapon history stays hidden from duplicate crafting")
	var plots := game.get_node("MainWorld/FarmArea").get_children().filter(func(node: Node) -> bool: return node is FarmPlot)
	check(plots[0].state == FarmPlot.State.READY and plots[1].state == FarmPlot.State.PLANTED and is_equal_approx(plots[1].growth_progress, 0.5), "ready and partly grown crops return to their morning state")
	check(game.progression.seed_reward_amount(5) == 5 and not game.progression.daily_seed_receipts.has(5), "morning choice is offered again without duplicated receipt or seed grant")
	if not game.seed_rewards.is_open: game.seed_rewards.request_open()
	await frames(12)
	await capture("seeds_clean")
	game.seed_rewards.confirm_selection()
	check(game.progression.daily_seed_receipts.has(5) and not game.progression.choose_daily_seed(5, &"seed_fire_pepper"), "resumed daily reward can still be claimed only once")
	game.inventory_ui.set_open(true)
	await frames(12)
	await capture("inventory_clean")
	game.inventory_ui.set_open(false)
	game.crafting_ui.set_open(true)
	game.crafting_ui._select_recipe(game.recipe_book.get_recipe(&"basic_ammo"))
	await frames(12)
	await capture("crafting_clean")
	game.crafting_ui.set_open(false)
	game.pause_menu.set_open(true)
	game.pause_menu._toggle_guide()
	await frames(12)
	check(game.pause_menu.guide.find_children("*", "Label", true, false).any(func(label: Label) -> bool: return label.text == "Cheat commands"), "How to play documents T without adding a cheat button")
	await capture("guide_clean")
	root.size = Vector2i(960, 540)
	await frames(12)
	check(root.get_visible_rect().encloses(game.pause_menu.get_node("Screen/Panel").get_global_rect()), "clean guide fits a smaller display")
	game.pause_menu._toggle_guide()
	game.pause_menu.set_open(false)
	# Keep valid checksums but invalid state out of the restore path.
	var bad := expected.duplicate(true)
	bad.bag[0].quantity = -1
	check(not checkpoint._valid_snapshot(bad), "invalid inventory quantities cannot load")
	bad = expected.duplicate(true)
	bad.magazines[0].rounds = 999
	check(not checkpoint._valid_snapshot(bad), "invalid magazine sizes cannot load")
	var latest: Dictionary = checkpoint._latest()
	var slot: String = checkpoint.FILES[int(latest.sequence) % 2]
	var original := FileAccess.get_file_as_string(slot)
	var broken := FileAccess.open(slot, FileAccess.WRITE)
	broken.store_string("{interrupted")
	broken.close()
	check(checkpoint.has_checkpoint() and checkpoint.saved_day() <= 5, "interrupted latest write recovers the preceding valid checkpoint")
	var repair := FileAccess.open(slot, FileAccess.WRITE)
	repair.store_string(original)
	repair.close()
	game.cheats.execute(&"ending")
	check(not checkpoint.has_checkpoint(), "completed run does not offer Continue")
	game.queue_free()
	await frames(4)

func click(button: Button) -> void:
	var point := root.get_final_transform() * button.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.pressed = down
		root.push_input(event)
	await frames(2)
