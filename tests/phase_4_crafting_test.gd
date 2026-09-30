extends "res://tests/phase_3_integration_test.gd"


func entry(item: ItemData, quantity: int) -> RecipeEntry:
	var result := RecipeEntry.new()
	result.item = item
	result.quantity = quantity
	return result


func mouse(button: MouseButton, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = down
	root.push_input(event)


func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	var player: PlayerController = game.get_node("Player")
	var inventory: Inventory = game.get_node("Player/Inventory")
	var catalog: ItemCatalog = game.catalog
	var clock: GameClock = game.get_node("TimeController")
	var system: CraftingSystem = game.get_node("CraftingSystem")
	var ui: CraftingUI = game.get_node("CraftingUI")
	var bag: InventoryUI = game.get_node("InventoryUI")
	var pause_menu: PauseMenu = game.get_node("PauseMenu")
	var mode: GameplayModeController = game.get_node("Player/GameplayMode")
	var plots: Node3D = game.get_node("MainWorld/FarmArea")
	var ammo: CraftRecipe = game.recipe_book.get_recipe(&"basic_ammo")
	var medicine: CraftRecipe = game.recipe_book.get_recipe(&"basic_medicine")
	var metal: CraftRecipe = game.recipe_book.get_recipe(&"metal_component")
	check(game.recipe_book.validation_errors(catalog).is_empty() and system.get_recipes().size() == 6, "six catalog-backed recipes load and validate")
	check(ui._buttons.size() == 6 and ui._buttons.has(ammo) and ui._buttons.has(medicine) and ui._buttons.has(metal), "recipe list comes from recipe resources")
	clock.set_process(false)
	# Each material comes from the existing seed -> plot -> growth -> harvest path.
	var plant_ids := [&"seed_lead", &"seed_paper", &"seed_copper", &"seed_iron", &"seed_small_herb", &"seed_small_herb"]
	for index in plant_ids.size():
		var plot: FarmPlot = plots.get_child(index)
		inventory.select_seed(plant_ids[index])
		player.position = plot.position + Vector3(0, 0.05, 1.1)
		player.velocity = Vector3.ZERO
		await frames(8)
		check(player.interactor.target == plot, "interactor targets plot %d" % index)
		key(KEY_E)
		check(plot.state == FarmPlot.State.PLANTED, "E plants crop %d" % index)
	clock.advance_game_minutes(60)
	for index in plant_ids.size():
		var plot: FarmPlot = plots.get_child(index)
		player.position = plot.position + Vector3(0, 0.05, 1.1)
		player.velocity = Vector3.ZERO
		await frames(8)
		check(plot.state == FarmPlot.State.READY and player.interactor.target == plot, "crop %d grows and becomes interactable" % index)
		key(KEY_E)
		check(plot.state == FarmPlot.State.EMPTY, "E harvests crop %d" % index)
	check(inventory.get_item_amount(&"lead") == 2 and inventory.get_item_amount(&"paper") == 3 and inventory.get_item_amount(&"copper") == 2 and inventory.get_item_amount(&"iron") == 2 and inventory.get_item_amount(&"small_herb") == 2, "harvested material quantities enter existing inventory")
	player.position = Vector3(-2, 0.05, 0.7)
	player.velocity = Vector3.ZERO
	await frames(10)
	check(player.interactor.target is Workbench and game.get_node("HUD").prompt_label.text.contains("[E]  Use Workbench"), "existing interactor displays workbench prompt")
	key(KEY_E)
	check(ui.is_open and paused and not bag.is_open and not pause_menu.is_open and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "E opens workbench modal, pauses world and releases cursor")
	var paused_time := clock.get_elapsed_minutes()
	var remembered_mode := mode.current_mode
	key(KEY_TAB)
	key(KEY_Q)
	await frames(15)
	check(ui.is_open and not bag.is_open and clock.get_elapsed_minutes() == paused_time and mode.current_mode == remembered_mode, "crafting modal blocks bag, clock and mode input")
	check(ui.feedback.text.contains("Ready to craft") and not ui.craft_button.disabled, "sufficient materials enable craft button")
	await capture("phase4_workbench")
	click_button(ui.craft_button)
	check(inventory.get_item_amount(&"basic_ammo") == 10 and inventory.get_item_amount(&"lead") == 1 and inventory.get_item_amount(&"paper") == 2 and inventory.get_item_amount(&"copper") == 1, "Basic Ammo craft consumes each material once and grants ten ammo")
	check(ui.feedback.text.contains("Crafted Basic Ammo x10"), "craft success appears in UI")
	click_button(ui._buttons[medicine])
	check(ui.selected_recipe == medicine and not ui.craft_button.disabled, "Medicine selection reads same inventory")
	click_button(ui.craft_button)
	check(inventory.get_item_amount(&"basic_medicine") == 1 and inventory.get_item_amount(&"small_herb") == 0, "Basic Medicine consumes two herbs and enters inventory")
	click_button(ui._buttons[metal])
	click_button(ui.craft_button)
	check(inventory.get_item_amount(&"metal_component") == 1 and inventory.get_item_amount(&"iron") == 0 and inventory.get_item_amount(&"copper") == 0, "Metal Component consumes iron and copper")
	await capture("phase4_crafted")
	key(KEY_ESCAPE)
	check(not ui.is_open and not paused and not pause_menu.is_open and mode.current_mode == remembered_mode and player.camera_rig.can_control(), "Esc closes crafting only and restores prior gameplay mode")
	key(KEY_Q)
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(10)
	check(player.camera_rig.is_aiming, "Combat can aim before workbench interaction")
	key(KEY_E)
	check(ui.is_open and mode.current_mode == GameplayModeController.Mode.COMBAT and not player.camera_rig.is_aiming, "workbench cancels aim without changing Combat mode")
	key(KEY_ESCAPE)
	mouse(MOUSE_BUTTON_RIGHT, false)
	check(not ui.is_open and mode.current_mode == GameplayModeController.Mode.COMBAT and not player.camera_rig.is_aiming, "closing workbench restores Combat without stale aim")
	key(KEY_Q)
	key(KEY_TAB)
	check(bag.is_open and bag.slot_buttons.any(func(button: Button) -> bool: return button.text.contains("Basic Ammo")), "Tab bag shows crafted stack")
	key(KEY_TAB)
	# Capacity simulation must include ingredient removal before checking outputs.
	inventory.clear()
	inventory.capacity = 1
	inventory.add_item(catalog.get_item(&"small_herb"), 3)
	check(system.failure_reason(medicine) == "Inventory Full" and not inventory.can_exchange_items({catalog.get_item(&"small_herb"): 2}, {catalog.get_item(&"basic_medicine"): 1}), "full bag rejects output when consumed stack remains occupied")
	check(system.craft(medicine) == "Inventory Full" and inventory.get_item_amount(&"small_herb") == 3 and inventory.get_item_amount(&"basic_medicine") == 0, "failed craft preserves all resources")
	ui._select_recipe(medicine)
	check(ui.craft_button.disabled and ui.feedback.text == "Inventory Full", "craft button and feedback reflect full inventory")
	inventory.clear()
	inventory.add_item(catalog.get_item(&"small_herb"), 2)
	check(system.craft(medicine).contains("Crafted") and inventory.get_item_amount(&"basic_medicine") == 1, "consuming an entire stack frees its slot for output")
	# One committed signal and reentrant craft attempts cannot duplicate output.
	inventory.capacity = 24
	inventory.clear()
	for id in [&"lead", &"paper", &"copper"]:
		inventory.add_item(catalog.get_item(id), 3)
	var reentrant: Array[String] = []
	var retry := func() -> void: reentrant.append(system.craft(ammo))
	inventory.inventory_changed.connect(retry)
	check(system.craft(ammo).contains("Crafted"), "first spam craft succeeds")
	inventory.inventory_changed.disconnect(retry)
	check(reentrant == ["Craft already in progress"] and inventory.get_item_amount(&"basic_ammo") == 10 and inventory.get_item_amount(&"lead") == 2, "synchronous callback cannot reenter crafting")
	for _i in 2:
		system.craft(ammo)
	check(inventory.get_item_amount(&"basic_ammo") == 30 and inventory.get_item_amount(&"lead") == 0 and inventory.get_slots().filter(func(slot: InventorySlot) -> bool: return slot.item.id == &"basic_ammo").size() == 1, "repeat craft stacks output without free crafts")
	check(system.craft(ammo) == "Not enough Lead" and inventory.get_item_amount(&"basic_ammo") == 30, "fourth spam press fails without duplicate output")
	# A temporary recipe and two outputs exercise the data path without changing core scripts.
	var test_item := ItemData.new()
	test_item.id = &"test_resource_pack"
	test_item.display_name = "Test Resource Pack"
	catalog.items.append(test_item)
	var extra := CraftRecipe.new()
	extra.recipe_id = &"test_resource_pack"
	extra.display_name = "Test Resource Pack"
	extra.category = CraftRecipe.Category.MATERIAL
	extra.ingredients = [entry(catalog.get_item(&"lead"), 1), entry(catalog.get_item(&"iron"), 1)]
	extra.outputs = [entry(test_item, 1), entry(catalog.get_item(&"paper"), 2)]
	extra.unlock_day = 2
	game.recipe_book.recipes.append(extra)
	game.progression.data.get_day(2).recipe_unlocks.append(extra.recipe_id)
	ui._build_recipe_list()
	ui.refresh()
	check(game.recipe_book.validation_errors(catalog).is_empty() and ui._buttons.has(extra), "new resource-only recipe appears in UI and validates")
	check(system.failure_reason(extra).contains("Recipe Locked") and ui._buttons[extra].text.contains("LOCKED"), "future-day recipe is visible but locked on Day 1")
	clock.seek(2, 6)
	ui.refresh()
	inventory.add_item(catalog.get_item(&"lead"), 1)
	inventory.add_item(catalog.get_item(&"iron"), 1)
	check(system.craft(extra).contains("Test Resource Pack x1") and inventory.get_item_amount(test_item.id) == 1 and inventory.get_item_amount(&"paper") == 2, "new recipe crafts both outputs without changing crafting code")
	var duplicate := CraftRecipe.new()
	duplicate.recipe_id = ammo.recipe_id
	duplicate.display_name = "Duplicate"
	duplicate.ingredients = [entry(catalog.get_item(&"lead"), 1)]
	duplicate.outputs = [entry(test_item, 1)]
	game.recipe_book.recipes.append(duplicate)
	check("Duplicate recipe id: 'basic_ammo'." in game.recipe_book.validation_errors(catalog), "duplicate recipe IDs are rejected")
	var invalid := CraftRecipe.new()
	invalid.ingredients = [entry(catalog.get_item(&"lead"), 1)]
	invalid.outputs = [entry(test_item, 0)]
	check(not invalid.validation_errors().is_empty(), "missing recipe ID and nonpositive output quantity are diagnosed")
	print("PHASE_4_CRAFTING_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
