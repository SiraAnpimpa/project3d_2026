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
	var original: ItemCatalog = load("res://resources/catalog.tres")
	var catalog := ItemCatalog.new()
	catalog.items = original.items.duplicate()
	catalog.plants = original.plants.duplicate()
	var data: PlantData = load("res://tests/fixtures/test_plant.tres")
	catalog.items.append(data.seed_item)
	catalog.items.append(data.harvest_item)
	catalog.plants.append(data)
	check(catalog.validation_errors().is_empty() and catalog.plants.size() == 6, "sixth plant added by resources and catalog registration only")
	check(original.plants.size() == 5 and original.items.size() == 10, "demo catalog remains unchanged")
	var world := Node3D.new()
	root.add_child(world)
	var actor := Node3D.new()
	world.add_child(actor)
	var inventory := Inventory.new()
	inventory.name = "Inventory"
	actor.add_child(inventory)
	var clock := GameClock.new()
	world.add_child(clock)
	clock.set_process(false)
	var plot: FarmPlot = load("res://scenes/farming/FarmPlot.tscn").instantiate()
	world.add_child(plot)
	plot.bind(clock, catalog, inventory)
	inventory.add_item(data.seed_item, 2)
	inventory.select_seed(data.seed_item.id)
	plot.interact(actor)
	check(plot.plant_data == data and inventory.get_item_amount(data.seed_item.id) == 1, "generic FarmPlot plants the new seed")
	clock.advance_game_minutes(4)
	check(plot.growth_stage == 1, "new thresholds are read from data")
	clock.advance_game_minutes(14)
	check(plot.state == FarmPlot.State.READY and plot.plant_visual.stage == 3, "new duration reaches ready using common plant scene")
	plot.interact(actor)
	check(inventory.get_item_amount(data.harvest_item.id) == 4 and plot.state == FarmPlot.State.EMPTY, "new yield harvested without plant-specific code")
	plot.interact(actor)
	check(plot.state == FarmPlot.State.PLANTED and inventory.get_item_amount(data.seed_item.id) == 0, "new plant supports plot reuse")
	world.queue_free()
	await process_frame
	print("PHASE_3_EXTENSION_RESULT failures=", failures)
	quit(failures)
