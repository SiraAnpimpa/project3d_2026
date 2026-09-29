extends "res://tests/phase_3_integration_test.gd"

func mouse(button: MouseButton, down: bool = true) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = down
	root.push_input(event)
	# A wheel notch has both edges. Leaving a synthetic button held can retain
	# GUI mouse focus on the modal shade and prevent a later click reaching Resume.
	if down and button in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		mouse(button, false)

func motion(offset: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.screen_relative = offset
	root.push_input(event)

func weapon(id: String, title: String) -> ItemData:
	var result := ItemData.new()
	result.id = StringName(id)
	result.display_name = title
	result.item_type = ItemData.ItemType.WEAPON
	result.max_stack = 1
	return result

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	var player: PlayerController = game.get_node("Player")
	var inventory: Inventory = game.get_node("Player/Inventory")
	var mode: GameplayModeController = game.get_node("Player/GameplayMode")
	var equipment: EquipmentLoadout = game.get_node("Player/EquipmentLoadout")
	var ui: InventoryUI = game.get_node("InventoryUI")
	var pause_menu: PauseMenu = game.get_node("PauseMenu")
	var hud: PrototypeHUD = game.get_node("HUD")
	var crosshair: AimCrosshair = game.get_node("HUD/Root/Crosshair")
	var rig := player.camera_rig
	key(KEY_F1)
	game.clock.seek(1, 9, 0)
	check(mode.is_farming() and inventory.selected_seed_id == &"seed_lead" and not crosshair.visible, "startup is Farming with first seed selected and shooting crosshair hidden")
	mouse(MOUSE_BUTTON_RIGHT)
	check(not rig.is_aiming, "RMB cannot aim in Farming")
	var yaw := rig.rotation.y
	motion(Vector2(20, 0))
	check(rig.rotation.y != yaw, "mouse look still works in Farming without RMB aim")
	rig.rotation.y = 0
	await capture("input_farming")
	key(KEY_I)
	check(not ui.is_open, "old I key no longer toggles inventory")
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	check(inventory.selected_seed_id == &"seed_paper" and equipment.selected_weapon_slot == -1, "one wheel-down in Farming changes seed only once")
	mouse(MOUSE_BUTTON_WHEEL_UP)
	check(inventory.selected_seed_id == &"seed_lead", "wheel-up reverses seed selection")
	var chosen_seed := inventory.selected_seed_id
	key(KEY_TAB)
	check(ui.is_open and paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Tab opens bag, pauses gameplay and releases mouse")
	yaw = rig.rotation.y
	motion(Vector2(200, 100))
	key(KEY_Q)
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	mouse(MOUSE_BUTTON_RIGHT)
	await frames(5)
	check(mode.is_farming() and rig.rotation.y == yaw and not rig.is_aiming and inventory.selected_seed_id == chosen_seed, "bag blocks camera, aim, mode switching and gameplay wheel")
	key(KEY_TAB)
	check(not ui.is_open and not paused and rig.can_control(), "Tab closes bag and restores gameplay")
	if DisplayServer.get_name() != "headless": check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "closing bag captures mouse in actual renderer")
	var rifle := weapon("test_rifle", "Rifle (test)")
	var shotgun := weapon("test_shotgun", "Shotgun (test)")
	var smg := weapon("test_smg", "SMG (test)")
	var crossbow := weapon("test_crossbow", "Crossbow (test)")
	var special := weapon("test_special", "Special Gun (test)")
	for data in [rifle, shotgun, smg, crossbow, special]: inventory.add_item(data)
	key(KEY_TAB)
	await frames(2)
	click_button(ui.slot_buttons[5])
	click_button(ui.equipment_buttons[0])
	click_button(ui.slot_buttons[6])
	click_button(ui.equipment_buttons[1])
	click_button(ui.slot_buttons[9])
	click_button(ui.equipment_buttons[2])
	check(equipment.get_equipped_weapon(0) == rifle and equipment.get_equipped_weapon(1) == shotgun and equipment.get_equipped_weapon(2) == special, "bag clicks equip three weapons from five owned items into exact slots")
	check(inventory.get_item_amount(smg.id) == 1 and inventory.get_item_amount(crossbow.id) == 1, "unequipped weapons remain owned in bag")
	await capture("input_equipment_bag")
	key(KEY_ESCAPE)
	check(not ui.is_open and not pause_menu.is_open and not paused, "Esc closes bag without also opening Pause")
	player.stamina.current_stamina = 65
	var stamina_before := player.stamina.current_stamina
	var position_before := player.position
	yaw = rig.rotation.y
	var shoulder := rig.shoulder_side
	key(KEY_Q)
	check(not mode.is_farming() and rig.rotation.y == yaw and rig.shoulder_side == shoulder and player.position == position_before and player.stamina.current_stamina == stamina_before, "Q enters Combat without resetting camera, position, shoulder or stamina")
	check(crosshair.visible and hud.seed_label.text.contains("COMBAT") and hud.seed_label.text.contains("[1 / 3] Rifle"), "Combat HUD shows selected equipped weapon and slot with crosshair")
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	check(equipment.get_selected_weapon() == shotgun and inventory.selected_seed_id == chosen_seed, "Combat wheel changes equipped weapon only")
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	check(equipment.get_selected_weapon() == special, "Combat wheel skips owned but unequipped weapons")
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	check(equipment.get_selected_weapon() == rifle, "Combat selection wraps across equipped slots")
	mouse(MOUSE_BUTTON_WHEEL_UP)
	check(equipment.get_selected_weapon() == special, "Combat wheel reverses across equipped slots")
	mouse(MOUSE_BUTTON_RIGHT)
	await frames(30)
	check(rig.is_aiming and crosshair.visible, "RMB aims in Combat")
	await capture("input_combat")
	key(KEY_Q)
	check(mode.is_farming() and not rig.is_aiming and not crosshair.visible and inventory.selected_seed_id == chosen_seed, "returning to Farming cancels aim and restores remembered seed")
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	chosen_seed = inventory.selected_seed_id
	key(KEY_Q)
	check(equipment.get_selected_weapon() == special and not rig.is_aiming, "returning to Combat restores its weapon without stale held aim")
	key(KEY_Q)
	check(inventory.selected_seed_id == chosen_seed, "each mode preserves its independent selection")
	key(KEY_V)
	check(rig.shoulder_side == -shoulder and mode.is_farming(), "V switches shoulder without changing mode")
	key(KEY_V)
	# Plant the final Lead seed through real E interaction, then verify auto successor.
	inventory.select_seed(&"seed_lead")
	inventory.remove_item(&"seed_lead", 2)
	player.position = Vector3(-4, 0.05, 3.1)
	player.velocity = Vector3.ZERO
	rig.rotation.y = 0
	rig.pitch_pivot.rotation.x = -0.5
	await frames(10)
	var plot := player.interactor.target as FarmPlot
	check(plot != null, "Farming interactor finds a nearby plot")
	if plot != null:
		key(KEY_E)
		check(plot.state == FarmPlot.State.PLANTED and inventory.get_item_amount(&"seed_lead") == 0 and inventory.selected_seed_id == &"seed_paper", "planting final seed updates dynamic list to next seed immediately")
		check(hud.seed_label.text.contains("Paper Seed  x3"), "HUD displays fallback seed and live quantity")
		game.clock.advance_game_minutes(37)
		key(KEY_Q)
		key(KEY_E)
		check(plot.state == FarmPlot.State.READY and inventory.get_item_amount(&"lead") == 0 and not plot.is_available(player), "Combat cannot harvest through E or advertise farming availability")
		check(plot.interact(player).contains("Farming mode") and plot.state == FarmPlot.State.READY, "direct farm interaction also enforces mode")
		key(KEY_Q)
		await frames(2)
		key(KEY_E)
		check(plot.state == FarmPlot.State.EMPTY and inventory.get_item_amount(&"lead") == 2, "switching back to Farming permits exact harvest")
		await capture("input_harvest")
	# Pause takes ownership of cursor and prevents opening a second modal screen.
	key(KEY_Q)
	mouse(MOUSE_BUTTON_RIGHT)
	key(KEY_ESCAPE)
	var time_before: float = game.clock.get_elapsed_minutes()
	yaw = rig.rotation.y
	var seed_before := inventory.selected_seed_id
	var slot_before := equipment.selected_weapon_slot
	key(KEY_TAB)
	key(KEY_Q)
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	motion(Vector2(100, 100))
	await frames(30)
	check(pause_menu.is_open and not ui.is_open and paused and not rig.is_aiming and not crosshair.visible and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Esc opens Pause, disables aim and prevents overlapping inventory")
	check(game.clock.get_elapsed_minutes() == time_before and rig.rotation.y == yaw and inventory.selected_seed_id == seed_before and equipment.selected_weapon_slot == slot_before and not mode.is_farming(), "Pause blocks clock, camera, Q and both wheel selections")
	await capture("input_pause")
	click_button(pause_menu.get_node("Screen/Panel/Rows/Resume"))
	check(not paused and not pause_menu.is_open and rig.can_control() and not rig.is_aiming, "Resume button returns controls without stuck aim")
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await frames(20)
	check(player.is_sprinting and not rig.is_aiming and player.visual.current_state == &"Run", "movement and sprint still work after switching modes and menus")
	Input.action_release("move_forward")
	Input.action_release("sprint")
	key(KEY_TAB)
	await frames(2)
	click_button(ui.unequip_buttons[2])
	check(equipment.get_equipped_weapon(2) == null and inventory.has_item(special.id), "bag unequip button keeps weapon in inventory")
	key(KEY_TAB)
	inventory.clear()
	check(equipment.selected_weapon_slot == -1 and hud.seed_label.text.contains("No weapon equipped"), "empty Combat loadout is readable and safe after inventory clear")
	await capture("input_empty_loadout")
	key(KEY_Q)
	check(hud.seed_label.text.contains("No plantable seeds") and not crosshair.visible, "empty Farming selector has an explicit HUD state")
	await capture("input_empty_seeds")
	mouse(MOUSE_BUTTON_WHEEL_DOWN)
	key(KEY_Q)
	mouse(MOUSE_BUTTON_WHEEL_UP)
	check(inventory.get_selected_seed() == null and equipment.get_selected_weapon() == null, "wheel remains safe when either list is empty")
	player.health.die()
	key(KEY_Q)
	key(KEY_TAB)
	key(KEY_ESCAPE)
	check(not mode.is_farming() and not ui.is_open and not pause_menu.is_open and not rig.can_control(), "death blocks gameplay input and modal opening")
	key(KEY_R)
	await frames(10)
	game = current_scene as Node3D
	check(game.get_node("Player/GameplayMode").is_farming() and game.get_node("Player/EquipmentLoadout").selected_weapon_slot == -1 and not paused, "restart begins fresh in Farming with empty equipment")
	print("INPUT_MODES_INTEGRATION_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
