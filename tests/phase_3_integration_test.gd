extends SceneTree

var failures := 0
var capture_directory := ""
var realtime := false


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var index := args.find("--capture-dir")
	if index >= 0 and index + 1 < args.size(): capture_directory = args[index + 1]
	realtime = "--realtime" in args
	call_deferred("run")


func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func frames(count: int) -> void:
	for _i in count: await physics_frame


func key_event(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	root.push_input(event)


func key(code: Key) -> void:
	key_event(code, true)
	key_event(code, false)


func click_button(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = down
		root.push_input(event)


func capture(name: String) -> void:
	if capture_directory.is_empty() or DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(picture.save_png(capture_directory.path_join(name + ".png")) == OK, "saved rendered image: " + name)


func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	var player: PlayerController = game.get_node("Player")
	var inventory: Inventory = player.get_node("Inventory")
	var ui: InventoryUI = game.get_node("InventoryUI")
	var clock: GameClock = game.get_node("TimeController")
	var hud: PrototypeHUD = game.get_node("HUD")
	var debug: DebugControls = game.get_node("DebugControls")
	key(KEY_F1)
	check(not debug.active and clock.time_scale == 1, "normal farming loop runs with debug disabled and default time scale")
	key(KEY_TAB)
	await frames(2)
	click_button(ui.slot_buttons[0])
	check(inventory.selected_seed_id == &"seed_lead" and paused, "mouse selects starter Lead Seed in paused inventory")
	key(KEY_TAB)
	var spawn := player.position
	Input.action_press("move_left")
	await frames(60)
	Input.action_release("move_left")
	Input.action_press("move_forward")
	await frames(45)
	Input.action_release("move_forward")
	await frames(12)
	check(player.position.distance_to(spawn) > 4, "movement actions walk from spawn to farm through the player controller")
	var plot := player.interactor.target as FarmPlot
	check(plot != null and hud.prompt_label.text.contains("[E] Plant Lead Seed"), "existing interactor reaches a farm plot and HUD shows live seed prompt")
	if plot == null:
		print("PHASE_3_INTEGRATION_RESULT failures=", failures)
		game.queue_free()
		await process_frame
		quit(failures)
		return
	key(KEY_E)
	check(plot.state == FarmPlot.State.PLANTED and inventory.get_item_amount(&"seed_lead") == 2, "physical E plants and removes a seed")
	check(hud.prompt_label.text.contains("Seed 0%") and not hud.prompt_label.text.contains("[E]"), "same target changes from plant action to growth feedback immediately")
	key(KEY_TAB)
	var paused_time := clock.get_elapsed_minutes()
	var paused_growth := plot.growth_progress
	await frames(60)
	check(clock.get_elapsed_minutes() == paused_time and plot.growth_progress == paused_growth, "opening inventory freezes both crop and clock")
	key(KEY_TAB)
	var started_ms := Time.get_ticks_msec()
	var stages: Array[int] = [plot.growth_stage]
	var ticks := 0
	while plot.state != FarmPlot.State.READY and ticks < 2100:
		await physics_frame
		if plot.growth_stage not in stages: stages.append(plot.growth_stage)
		ticks += 1
	var wall_seconds := float(Time.get_ticks_msec() - started_ms) / 1000.0
	print("GROWTH_RUNTIME wall_seconds=", wall_seconds, " physics_ticks=", ticks, " realtime=", realtime)
	check(plot.state == FarmPlot.State.READY and stages == [0, 1, 2, 3], "normal clock grows planted seed through all four stages without debug skips")
	if realtime: check(wall_seconds >= 28 and wall_seconds <= 36, "default Lead growth completes in approximately 30 real seconds")
	check(hud.prompt_label.text.contains("[E] Harvest Lead x2"), "ready state refreshes existing HUD prompt")
	await capture("phase3_ready")
	key(KEY_E)
	check(inventory.get_item_amount(&"lead") == 2 and plot.state == FarmPlot.State.EMPTY, "physical E harvests exact yield into inventory and clears plot")
	check(hud.toast_label.text == "Harvested Lead x2.", "harvest reports the item and amount")
	key(KEY_TAB)
	await frames(2)
	var yield_visible := false
	for button in ui.slot_buttons:
		if button.text == "Lead\nx2": yield_visible = true
	check(yield_visible, "harvested material and quantity appear in inventory UI")
	await capture("phase3_inventory")
	key(KEY_ESCAPE)
	key(KEY_E)
	check(plot.state == FarmPlot.State.PLANTED and inventory.get_item_amount(&"seed_lead") == 1, "the same plot is reusable with another physical E press")
	key(KEY_F1)
	key(KEY_F10)
	await frames(110)
	check(plot.state == FarmPlot.State.READY, "accelerated clock grows crops through existing F10 control")
	key(KEY_F10)
	# Additional crop types placed through the normal plot API for the farm overview.
	for index in game.catalog.plants.size():
		var other: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(index + 4)
		if other.state == FarmPlot.State.EMPTY:
			inventory.select_seed(game.catalog.plants[index].seed_item.id)
			other.interact(player)
	debug.execute(&"debug_grow_all")
	key(KEY_F1)
	player.position = Vector3(-1.0, 0.05, 8.8)
	player.velocity = Vector3.ZERO
	player.camera_rig.rotation.y = 0.95
	player.camera_rig.pitch_pivot.rotation.x = -0.52
	await frames(8)
	await capture("phase3_farm")
	clock.seek(1, 20, 30)
	await frames(5)
	await capture("phase3_night")
	check(hud.day_label.text.contains("NIGHTTIME"), "farming and day-night HUD remain integrated")
	key(KEY_F1)
	key(KEY_TAB)
	await frames(2)
	check(ui.get_node("Screen/Panel/Rows/DebugActions").visible, "farming debug controls are visible only when enabled")
	await capture("phase3_debug_inventory")
	key(KEY_TAB)
	player.health.die()
	key(KEY_R)
	await frames(15)
	game = current_scene as Node3D
	inventory = game.get_node("Player/Inventory")
	check(inventory.get_item_amount(&"seed_lead") == 3 and inventory.get_item_amount(&"lead") == 0 and not paused, "restart creates fresh inventory and resets menu pause")
	var empty := true
	for child in game.get_node("MainWorld/FarmArea").get_children(): empty = empty and child.state == FarmPlot.State.EMPTY
	check(empty, "restart clears runtime plants without a save system")
	print("PHASE_3_INTEGRATION_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
