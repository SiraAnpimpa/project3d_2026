extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = down
		root.push_input(event)


func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for _i in 12: await physics_frame
	var ui: InventoryUI = game.get_node("InventoryUI")
	var player: PlayerController = game.get_node("Player")
	var inventory: Inventory = player.get_node("Inventory")
	var clock: GameClock = game.get_node("TimeController")
	check(inventory.get_slots().size() == 6 and inventory.get_item_amount(&"seed_lead") == 3 and inventory.has_item(&"basic_rifle"), "starter seeds and Phase 5 rifle appear once in game")
	key(KEY_TAB)
	check(ui.is_open and paused and ui.screen.visible, "Tab opens inventory and pauses world")
	check(ui.slot_buttons.size() == 24 and ui.slot_buttons[0].text.contains("x3") and ui.slot_buttons[0].icon != null, "UI displays capacity, quantity and icon")
	ui.slot_buttons[1].grab_focus()
	key(KEY_ENTER)
	check(inventory.selected_seed_id == &"seed_paper" and ui.selection_label.text.contains("Paper Seed"), "keyboard selects seed and updates feedback")
	var time_before := clock.get_elapsed_minutes()
	var position_before := player.position
	var yaw_before := player.camera_rig.rotation.y
	Input.action_press("move_forward")
	Input.action_press("sprint")
	Input.action_press("camera_right")
	for _i in 30: await process_frame
	Input.action_release("move_forward")
	Input.action_release("sprint")
	Input.action_release("camera_right")
	check(clock.get_elapsed_minutes() == time_before and player.position == position_before and player.stamina.current_stamina == 100 and player.camera_rig.rotation.y == yaw_before, "inventory pauses time, movement, stamina and camera")
	key(KEY_F2)
	check(player.health.current_hp == 100, "gameplay debug keys do not leak through menu")
	key(KEY_ESCAPE)
	check(not ui.is_open and not paused, "Escape closes and resumes world")
	key(KEY_TAB)
	key(KEY_TAB)
	check(not ui.is_open and not paused, "Tab toggles closed")
	clock.paused = true
	key(KEY_TAB)
	ui.get_node("Screen/Panel/Rows/Header/Close").pressed.emit()
	check(not paused and clock.paused, "close preserves an existing debug clock pause")
	inventory.add_item(load("res://resources/items/seed_lead.tres"), 2)
	check(ui.slot_buttons[0].text.contains("x5"), "inventory signal updates displayed stack")
	player.health.die()
	key(KEY_TAB)
	check(not ui.is_open, "inventory cannot open while dead")
	print("PHASE_3_UI_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
