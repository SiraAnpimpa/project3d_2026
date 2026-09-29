extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func measure(hz: int) -> float:
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
	var catalog: ItemCatalog = load("res://resources/catalog.tres")
	var plot: FarmPlot = load("res://scenes/farming/FarmPlot.tscn").instantiate()
	world.add_child(plot)
	plot.bind(clock, catalog, inventory)
	inventory.add_item(catalog.get_item(&"seed_lead"), 1)
	inventory.select_seed(&"seed_lead")
	plot.interact(actor)
	for _i in hz * 20: clock.advance(1.0 / hz)
	var progress := plot.growth_progress
	for _i in hz * 10: clock.advance(1.0 / hz)
	if plot.state != FarmPlot.State.READY:
		push_error("FAIL: growth did not finish at 30 seconds, hz=" + str(hz))
		failures += 1
	world.queue_free()
	return progress


func run() -> void:
	var low := measure(30)
	var high := measure(120)
	var consistent := absf(low - high) < 0.00001 and absf(low - 2.0 / 3.0) < 0.00001
	if not consistent:
		push_error("FAIL: growth varies with frame rate")
		failures += 1
	await process_frame
	print("PHASE_3_GROWTH_RATE_RESULT 30Hz=", low, " 120Hz=", high, " failures=", failures)
	quit(failures)
