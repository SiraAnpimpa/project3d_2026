extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func run() -> void:
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for _i in 5: await physics_frame
	var player: PlayerController = game.get_node("Player")
	var inventory: Inventory = player.get_node("Inventory")
	var clock: GameClock = game.get_node("TimeController")
	var plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
	var catalog: ItemCatalog = game.catalog
	clock.set_process(false)
	clock.seek(1, 6)
	check(game.get_node("MainWorld/FarmArea").get_child_count() == 12, "12 reusable farm plot instances exist")
	inventory.selected_seed_id = &"" # Exercise invalid/no selection explicitly; startup now auto-selects.
	check(plot.get_interaction_text(player, "E").contains("[Tab]"), "empty plot guides seed selection")
	plot.interact(player)
	check(plot.state == FarmPlot.State.EMPTY and inventory.get_item_amount(&"seed_lead") == 3, "no selection cannot consume seed")
	inventory.select_seed(&"seed_lead")
	check(plot.get_interaction_text(player, "E").contains("[E] Plant Lead Seed"), "selected seed appears in empty prompt")
	var recursive_messages: Array[String] = []
	var reenter := func() -> void: recursive_messages.append(plot.interact(player))
	inventory.inventory_changed.connect(reenter)
	plot.interact(player)
	inventory.inventory_changed.disconnect(reenter)
	check(plot.state == FarmPlot.State.PLANTED and inventory.get_item_amount(&"seed_lead") == 2, "planting consumes exactly one seed")
	check(recursive_messages == ["Plot unavailable."], "synchronous inventory callbacks cannot reenter planting transaction")
	check(plot.plant_visual != null and plot.growth_stage == 0 and plot.planted_time == 0, "plant scene and planted timestamp initialize at seed stage")
	for _i in 25: plot.interact(player)
	check(inventory.get_item_amount(&"seed_lead") == 2, "interaction spam cannot plant twice")
	clock.advance_game_minutes(9)
	check(plot.growth_stage == 1 and is_equal_approx(plot.growth_progress, 0.25), "sprout at 25 percent")
	clock.advance_game_minutes(14.4)
	check(plot.growth_stage == 2 and plot.plant_visual.stage == 2, "growth stage and visual advance together")
	var before_pause := plot.growth_progress
	clock.paused = true
	clock.advance(10)
	check(plot.growth_progress == before_pause, "paused clock freezes crop growth")
	clock.paused = false
	clock.time_scale = 2
	clock.advance(5.25)
	check(plot.state == FarmPlot.State.READY and plot.growth_stage == 3, "time scale advances crop to ready")
	check(plot.get_interaction_text(player, "E").contains("[E] Harvest Lead x2"), "ready crop displays yield prompt")
	inventory.clear()
	inventory.capacity = 1
	inventory.add_item(catalog.get_item(&"paper"), 99)
	check(plot.interact(player).contains("Inventory full") and plot.state == FarmPlot.State.READY and inventory.get_item_amount(&"lead") == 0, "full inventory preserves ready crop and all produce")
	inventory.clear()
	inventory.add_item(catalog.get_item(&"lead"), 98)
	plot.interact(player)
	check(plot.state == FarmPlot.State.READY and inventory.get_item_amount(&"lead") == 98, "partial stack space cannot partially harvest")
	inventory.remove_item(&"lead", 1)
	inventory.inventory_changed.connect(reenter)
	plot.interact(player)
	inventory.inventory_changed.disconnect(reenter)
	check(inventory.get_item_amount(&"lead") == 99 and plot.state == FarmPlot.State.EMPTY and plot.plant_visual == null, "successful harvest adds exact yield and empties plot")
	check(recursive_messages.size() == 2 and recursive_messages[-1] == "Plot unavailable.", "harvest transaction rejects reentrant harvest")
	for _i in 25: plot.interact(player)
	check(inventory.get_item_amount(&"lead") == 99, "harvest spam cannot duplicate produce")
	inventory.clear()
	inventory.capacity = 24
	inventory.add_item(catalog.get_item(&"seed_lead"), 1)
	inventory.select_seed(&"seed_lead")
	inventory.remove_item(&"seed_lead")
	plot.interact(player)
	check(plot.state == FarmPlot.State.EMPTY, "zero seeds cannot plant")
	var invalid_seed := ItemData.new()
	invalid_seed.id = &"seed_missing"
	invalid_seed.display_name = "Missing Plant Seed"
	invalid_seed.item_type = ItemData.ItemType.SEED
	invalid_seed.plantable = true
	invalid_seed.plant_id = &"missing"
	game.progression.unlocked_seed_ids[invalid_seed.id] = true # Exercise malformed mapping after the unlock gate.
	inventory.add_item(invalid_seed, 2)
	inventory.select_seed(invalid_seed.id)
	check(plot.interact(player).contains("invalid plant data") and inventory.get_item_amount(invalid_seed.id) == 2, "invalid seed mapping fails without consumption")
	inventory.clear()
	game.starter_loadout.give_to(inventory)
	var basic_plants: Array[PlantData] = catalog.plants.filter(func(data: PlantData) -> bool: return data.seed_item.tier == 1)
	clock.seek(1, 17, 30)
	for index in basic_plants.size():
		var other: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(index)
		inventory.select_seed(basic_plants[index].seed_item.id)
		other.interact(player)
	clock.advance_game_minutes(24)
	var progress_before_rewind := plot.growth_progress
	clock.advance_game_minutes(-10)
	check(plot.growth_progress == progress_before_rewind, "debug rewind never reverses growth stages")
	clock.advance_game_minutes(34)
	var all_yields := true
	for index in basic_plants.size():
		var other: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(index)
		var data := basic_plants[index]
		all_yields = all_yields and other.state == FarmPlot.State.READY
		other.interact(player)
		all_yields = all_yields and inventory.get_item_amount(data.harvest_item.id) == data.harvest_amount
	check(all_yields and clock.is_nighttime, "all five plant types grow across dusk and harvest their own data-defined yields")
	inventory.select_seed(&"seed_lead")
	plot.interact(player)
	check(plot.state == FarmPlot.State.PLANTED and inventory.get_item_amount(&"seed_lead") == 1, "harvested plot can be replanted")
	player.position = Vector3(15, 0.1, 15)
	clock.advance_game_minutes(36)
	check(plot.state == FarmPlot.State.READY, "crop persists and grows while player is far away")
	player.health.die()
	var prior := inventory.get_item_amount(&"lead")
	plot.interact(player)
	check(inventory.get_item_amount(&"lead") == prior and plot.state == FarmPlot.State.READY, "dead player cannot harvest")
	print("PHASE_3_FARMING_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
