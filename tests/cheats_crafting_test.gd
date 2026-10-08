extends "res://tests/phase_3_integration_test.gd"

var game: Node3D

func run() -> void:
	root.size = Vector2i(1280, 720)
	set_meta("normal_play", true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	await frames(12)
	game.clock.paused = true
	var ui: CraftingUI = game.crafting_ui
	var system: CraftingSystem = game.crafting_system
	var pistol: CraftRecipe = game.recipe_book.get_recipe(&"pistol")
	var bat: CraftRecipe = game.recipe_book.get_recipe(&"wooden_bat")
	var knife: CraftRecipe = game.recipe_book.get_recipe(&"knife")
	var ammo: CraftRecipe = game.recipe_book.get_recipe(&"basic_ammo")
	check(not ui._buttons[pistol].visible and not ui._buttons[bat].visible, "starter Pistol and Bat are hidden from crafting")
	check(system.get_recipes().size() == game.recipe_book.recipes.size() and ui._buttons[knife].visible, "canonical recipes remain intact and missing weapons remain available")
	for entry: RecipeEntry in knife.ingredients: game.inventory.add_item(entry.item, entry.quantity * 3)
	ui.set_open(true)
	ui._select_recipe(knife)
	await frames(12)
	check(not ui.craft_button.disabled, "missing weapon remains craftable with sufficient materials")
	await capture("craft_weapon_ready")
	await click(ui.craft_button)
	check(game.inventory.has_item(&"knife") and not ui._buttons[knife].visible and system.crafted_weapon_ids.has(&"knife"), "real craft immediately hides newly owned weapon and records craft")
	check(ui.selected_recipe == null and ui.craft_button.disabled and ui.detail_title.text == "Choose a recipe", "removed recipe clears selection and disables Craft instead of crafting a different item")
	var before := snapshot()
	check(system.craft(knife).contains("already") and snapshot() == before, "stale or repeated weapon craft cannot consume any ingredients")
	game.inventory.remove_item(&"knife")
	check(not ui._buttons[knife].visible and system.craft(knife).contains("already"), "previously crafted weapon remains hidden even if removed from bag")
	check(ui._buttons[ammo].visible and not system.weapon_already_obtained(ammo), "ammunition remains a repeatable recipe")
	for entry: RecipeEntry in ammo.ingredients: game.inventory.add_item(entry.item, entry.quantity * 3)
	check(system.craft(ammo).begins_with("Crafted") and system.craft(ammo).begins_with("Crafted"), "non-weapon recipes can still be crafted repeatedly")
	ui.set_open(false)
	key(KEY_T)
	await frames(12)
	var cheats: CheatMenu = game.cheats_menu
	check(cheats.is_open and paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not game.player.camera_rig.can_control(), "T opens cheat modal, pauses world and releases camera")
	key(KEY_QUOTELEFT)
	check(not cheats.is_open and not paused, "alternate backquote shortcut closes cheats without opening Pause")
	key(KEY_T)
	await frames(10)
	check(cheats.panel.get_global_rect().end.y <= root.get_visible_rect().size.y, "all cheat controls and close button fit 720p")
	await capture("cheats_time")
	var remembered_day: int = game.clock.current_day
	key(KEY_TAB)
	key(KEY_Q)
	await frames(3)
	check(cheats.is_open and not game.inventory_ui.is_open and not game.pause_menu.is_open and game.gameplay_mode.is_farming(), "cheat modal blocks bag and gameplay input")
	await click(cheats.buttons[&"unlock_all"])
	check(game.progression.is_seed_unlocked(&"seed_poison_plant") and game.crafting_system.is_unlocked(game.recipe_book.get_recipe(&"poison_ammo")), "unlock command unlocks late seeds and recipes without changing day")
	check(game.clock.current_day == remembered_day, "unlock command preserves current day")
	cheats.tabs.current_tab = 1
	await frames(4)
	var pistol_index := 0
	for index in cheats._items.size():
		if cheats._items[index].id == &"pistol": pistol_index = index
	cheats.item_option.select(pistol_index)
	cheats.item_option.item_selected.emit(pistol_index)
	check(not cheats.amount_spin.editable and cheats.amount_spin.value == 1, "weapon grants limit quantity to one")
	before = snapshot()
	await click(cheats.buttons[&"give_item"])
	check(snapshot() == before and cheats.status.text.contains("Already owned"), "cheat grant cannot duplicate owned weapon")
	await click(cheats.buttons[&"weapons"])
	var weapons_owned := 0
	for definition: WeaponData in game.weapons.definitions:
		if game.inventory.has_item(definition.weapon_id): weapons_owned += 1
	check(weapons_owned == 7 and not ui._category_headings[CraftRecipe.Category.WEAPON].visible, "give all weapons grants only missing weapons and hides empty weapon category")
	var capacity_before: int = game.inventory.capacity
	game.inventory.capacity = game.inventory.get_slots().size()
	before = snapshot()
	check(not game.cheats.give_item(game.catalog.get_item(&"basic_medicine"), 1) and before == snapshot() and cheats.status.text.contains("Bag full"), "full-bag item grants reject atomically with clear feedback")
	game.inventory.capacity = capacity_before
	await capture("cheats_items")
	cheats.tabs.current_tab = 2
	await frames(4)
	for kind in 3:
		cheats.zombie_option.select(kind)
		await click(cheats.buttons[&"spawn"])
		check(game.cheats.spawned.size() == kind + 1, "zombie menu spawns variant %d on safe navigation" % kind)
		if game.cheats.spawned.size() > kind:
			var zombie: NormalZombie = game.cheats.spawned[-1]
			check(zombie.health.max_hp == [150, 100, 400][kind] and zombie.pursue_target, "spawned variant retains real health and chase: " + str(kind))
	check(game.waves.total_zombies == 0 and game.waves.alive.is_empty(), "cheat zombies do not alter campaign wave counters")
	await capture("cheats_zombies")
	game.cheats.spawn_zombies(0, 99)
	check(game.cheats.spawned.size() <= CheatCommands.MAX_ZOMBIES and game.cheats.spawn_zombies(0, 99) == 0, "large/repeated spawn requests respect the 12-zombie limit")
	await click(cheats.buttons[&"clear_zombies"])
	await frames(3)
	check(game.cheats.spawned.is_empty(), "clear zombies removes manually spawned enemies")
	cheats.tabs.current_tab = 0
	await frames(3)
	cheats.day_spin.value = 4
	await click(cheats.buttons[&"day"])
	check(game.clock.current_day == 4 and game.clock.current_hour == 6 and game.waves.state == NightWaveManager.State.DAY, "day selector jumps to correct dawn and resets current wave")
	await click(cheats.buttons[&"next_day"])
	check(game.clock.current_day == 5 and cheats.is_open and not game.seed_rewards.is_open, "next day preserves cheat modal and defers morning reward until close")
	await click(cheats.buttons[&"final_day"])
	check(game.clock.current_day == 10 and game.clock.is_daytime, "final day command reaches Day 10 morning")
	await click(cheats.buttons[&"final_night"])
	check(game.clock.current_day == 10 and game.clock.current_hour == 18 and game.waves.state == NightWaveManager.State.ACTIVE and game.waves.total_zombies > 0, "final night starts the original final wave")
	game.waves._physics_process(0.1)
	check(not game.waves.alive.is_empty(), "real final-wave factory spawns a live enemy before cleanup test")
	cheats.tabs.current_tab = 2
	await frames(3)
	await click(cheats.buttons[&"clear_zombies"])
	check(game.waves.state == NightWaveManager.State.CLEARED and game.waves.remaining_zombies == 0 and game.waves.tracked.is_empty(), "clear command despawns live enemies and cancels pending wave enemies")
	game.cheats.execute(&"final_night")
	await click(cheats.buttons[&"clear_zombies"])
	check(game.waves.state == NightWaveManager.State.CLEARED and game.waves.remaining_zombies == 0, "clear command also handles a wave with only pending enemies")
	# Supply choices are real rewards; resolve before testing other menu transitions.
	for day: int in game.progression.daily_seed_choices.keys():
		game.progression.choose_daily_seed(day, game.progression.seed_reward_options(day)[0])
	key(KEY_ESCAPE)
	await frames(3)
	check(not cheats.is_open and not paused and not game.pause_menu.is_open, "Esc closes only cheat menu and restores gameplay")
	key(KEY_ESCAPE)
	await frames(3)
	check(not game.pause_menu.has_node("Screen/Panel/Rows/Cheats"), "Pause contains no cheat button")
	key(KEY_T)
	check(cheats.is_open and not game.pause_menu.is_open and paused, "secret T shortcut transfers modal ownership without stacking windows")
	root.size = Vector2i(960, 540)
	await frames(10)
	check(cheats.panel.get_global_rect().end.x <= root.get_visible_rect().size.x and cheats.panel.get_global_rect().end.y <= root.get_visible_rect().size.y, "cheat menu fits smaller display")
	await capture("cheats_small")
	root.size = Vector2i(1280, 720)
	cheats.tabs.current_tab = 0
	await frames(8)
	await click(cheats.buttons[&"ending"])
	check(game.waves.state == NightWaveManager.State.GAME_COMPLETED and game.clock.current_day == 11 and game.presentation.ending_started, "Show ending uses real Day 11 completion and rescue sequence")
	check(not cheats.is_open and not paused and game.waves.tracked.is_empty() and game.cheats.spawned.is_empty(), "ending closes cheat modal and cleans enemies without freezing cinematic")
	await frames(510)
	check(game.presentation.ending_finished, "rescue cinematic reaches the actual end screen")
	await capture("cheat_ending")
	game.queue_free()
	await frames(4)
	print("CHEATS_CRAFTING_RESULT failures=", failures)
	quit(1 if failures else 0)

func snapshot() -> Dictionary:
	var result := {}
	for slot: InventorySlot in game.inventory.get_slots(): result[slot.item.id] = game.inventory.get_item_amount(slot.item.id)
	return result

func click(button: Control) -> void:
	var point := root.get_final_transform() * button.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = down
		root.push_input(event)
	await frames(2)
