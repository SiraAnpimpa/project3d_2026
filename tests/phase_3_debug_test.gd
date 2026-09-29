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
	await physics_frame
	var debug: DebugControls = game.get_node("DebugControls")
	var inventory: Inventory = game.get_node("Player/Inventory")
	var player: PlayerController = game.get_node("Player")
	var plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
	var ui: InventoryUI = game.get_node("InventoryUI")
	var clock: GameClock = game.get_node("TimeController")
	clock.set_process(false)
	inventory.select_seed(&"seed_lead")
	plot.interact(player)
	ui.set_open(true)
	check(paused and ui.get_node("Screen/Panel/Rows/DebugActions").visible, "debug menu available inside paused inventory")
	debug.execute(&"debug_grow_all")
	check(plot.state == FarmPlot.State.READY and clock.get_elapsed_minutes() >= 36, "instant grow advances clock through shared growth path")
	var before := clock.get_elapsed_minutes()
	debug.execute(&"debug_advance_growth")
	check(is_equal_approx(clock.get_elapsed_minutes() - before, 60), "advance growth changes game time by one hour")
	debug.execute(&"debug_fill_inventory")
	var full := inventory.get_slots().size() == inventory.capacity
	for slot in inventory.get_slots(): full = full and slot.quantity == slot.item.max_stack
	check(full, "fill inventory fills all slots and existing stacks")
	debug.execute(&"debug_give_seeds")
	check(ui.debug_message.text.contains("Nothing added"), "failed starter grant reports capacity without partial items")
	debug.execute(&"debug_clear_inventory")
	check(inventory.get_slots().is_empty() and inventory.selected_seed_id == &"", "clear inventory resets counts and selection")
	debug.execute(&"debug_give_seeds")
	check(inventory.get_item_amount(&"seed_lead") == 3 and inventory.get_slots().size() == 5, "give seeds uses configurable loadout")
	debug.execute(&"debug_clear_farm")
	check(plot.state == FarmPlot.State.EMPTY and plot.plant_visual == null, "clear farm resets plot and visual")
	inventory.select_seed(&"seed_lead")
	plot.interact(player)
	before = clock.get_elapsed_minutes()
	debug.set_active(false)
	for action in DebugControls.FARMING_ACTIONS: debug.execute(action)
	check(plot.state == FarmPlot.State.PLANTED and clock.get_elapsed_minutes() == before and inventory.get_item_amount(&"seed_lead") == 2, "all farming debug actions are gated when disabled")
	check(not ui.get_node("Screen/Panel/Rows/DebugActions").visible and paused, "disabling tools hides debug UI without releasing menu pause")
	debug.debug_enabled = false
	debug.set_active(true)
	debug.execute(&"debug_clear_inventory")
	check(not debug.active and inventory.get_item_amount(&"seed_lead") == 2, "Inspector gate prevents farming tools from reactivating")
	player.health.die()
	check(not ui.is_open and not paused, "death closes inventory and restores world processing")
	print("PHASE_3_DEBUG_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
