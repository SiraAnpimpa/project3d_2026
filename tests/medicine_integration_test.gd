extends "res://tests/arsenal_test.gd"
## Real planting/harvest/workbench and input integration, then isolated edge cases.

var medicine: ItemData
var uses := 0

func blocked_input(reason: String) -> void:
	var hp := player.health.current_hp
	var count := bag.get_item_amount(medicine.id)
	key(KEY_F)
	check(not game.consumables.use_item(medicine), reason + " rejects direct use")
	await frames(2)
	check(player.health.current_hp == hp and bag.get_item_amount(medicine.id) == count, reason + " blocks F without consuming")

func run() -> void:
	root.size = Vector2i(1280, 720)
	await new_game()
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	player.camera_rig.capture_mouse()
	medicine = game.catalog.get_item(&"basic_medicine")
	game.consumables.used.connect(func(_item: ItemData, _hp: float) -> void: uses += 1)
	check(InputMap.action_get_events("use_medicine")[0].physical_keycode == KEY_F, "F maps to use_medicine")
	check(medicine.heal_amount == 30 and medicine.consume_on_use and medicine.validation_errors().is_empty(), "medicine data heals 30 HP and consumes one")
	key(KEY_F)
	check(game.hud.toast_label.text == "No Medicine" and uses == 0, "empty bag gives No Medicine")
	check(not game.hud._medicine_row.visible, "empty bag has no HUD clutter")
	await gather(&"small_herb", 2)
	await craft_item(medicine.id)
	check(bag.get_item_amount(medicine.id) == 1 and game.hud._medicine_row.visible, "real crafting adds one medicine and shows its HUD")
	check(game.hud.toast_label.text.contains("[F] Use Medicine"), "first real craft explains F after closing workbench")
	check(game.hud._medicine_icon.texture == medicine.icon and game.hud._medicine_count.text == "×1", "HUD uses actual item icon and inventory count")
	key(KEY_F)
	check(player.health.current_hp == 100 and bag.get_item_amount(medicine.id) == 1 and game.hud.toast_label.text == "HP Full", "full HP does not waste medicine")
	await place_player(RuralTerrain.ground_point(14, 6) + Vector3.UP * .03)
	if game.gameplay_mode.is_farming(): key(KEY_Q)
	var enemy := enemy_at("Normal", 1.0)
	enemy.set_physics_process(true)
	for tick in 120:
		if enemy.attacks_landed > 0: break
		await frames(1)
	check(enemy.attacks_landed == 1 and player.health.current_hp == 90, "real zombie windup hits for 10 HP in Combat")
	enemy.set_physics_process(false)
	key(KEY_F)
	await frames(2)
	check(player.health.current_hp == 100 and bag.get_item_amount(medicine.id) == 0 and uses == 1, "Combat F consumes real crafted medicine and clamps heal to max")
	check(game.hud.hp_bar.value == 100 and game.hud.toast_label.text.contains("+10 HP"), "health bar and feedback show actual restored HP")
	check(not game.hud._medicine_row.visible, "last medicine disappears from HUD")
	enemy.queue_free()
	await frames(32)
	player.health.take_damage(40)
	key(KEY_F)
	check(player.health.current_hp == 60 and bag.get_item_amount(medicine.id) == 0 and game.hud.toast_label.text == "No Medicine", "damaged with empty bag remains safe")
	# Only subsequent edge-case setup grants supplies. First loop above is all real.
	check(bag.add_item(game.catalog.get_item(&"small_herb"), 4), "edge-case ingredients fit bag")
	await craft_item(medicine.id)
	await craft_item(medicine.id)
	check(bag.get_item_amount(medicine.id) == 2, "repeated actual crafting stacks medicine")
	player.health.take_damage(35)
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_F
	echo.pressed = true
	echo.echo = true
	root.push_input(echo)
	check(uses == 1 and bag.get_item_amount(medicine.id) == 2, "keyboard echo does not consume")
	key(KEY_F)
	for press in 12: key(KEY_F)
	check(player.health.current_hp == 55 and bag.get_item_amount(medicine.id) == 1 and uses == 2, "rapid presses consume only one and heal exactly ItemData amount")
	check(game.hud._medicine_count.text == "×1" and game.hud._medicine_hint.text == "Recovering…", "HUD immediately updates quantity and cooldown state")
	await capture("medicine_heal_720p")
	await frames(32)
	check(game.hud._medicine_hint.text == "Use Medicine", "HUD returns to ready after half-second cooldown")
	key(KEY_F)
	check(player.health.current_hp == 85 and bag.get_item_amount(medicine.id) == 0 and uses == 3, "next deliberate press works after cooldown")
	await frames(32)
	check(bag.add_item(medicine, 21), "edge-case supply spans multiple stacks")
	var reentry := {"accepted": false}
	var listener := func() -> void: reentry.accepted = game.consumables.use_item(medicine)
	bag.inventory_changed.connect(listener, CONNECT_ONE_SHOT)
	key(KEY_F)
	check(not reentry.accepted and bag.get_item_amount(medicine.id) == 20 and uses == 4, "synchronous inventory listeners cannot double-consume across stacks")
	await frames(32)
	player.health.take_damage(50)
	key(KEY_TAB)
	await frames(4)
	check(game.inventory_ui.is_open and not game.hud._medicine_row.visible, "bag owns input and hides medicine HUD")
	await blocked_input("Inventory")
	key(KEY_TAB)
	await frames(4)
	if not game.gameplay_mode.is_farming(): key(KEY_Q)
	await place_player(game.get_node("MainWorld/Workbench").global_position + Vector3(0,.03,1.1))
	await frames(8)
	key(KEY_E)
	await frames(4)
	check(game.crafting_ui.is_open, "workbench opens for input ownership check")
	await blocked_input("Crafting menu")
	key(KEY_ESCAPE)
	await frames(3)
	key(KEY_ESCAPE)
	await frames(3)
	check(game.pause_menu.is_open and paused, "Esc pauses gameplay")
	await blocked_input("Pause")
	click_button(game.pause_menu.help_button)
	await frames(5)
	check(game.pause_menu.guide.visible, "in-game How to Play opens")
	var guide_panel: Control = game.pause_menu.get_node("Screen/Panel")
	check(Rect2(Vector2.ZERO, Vector2(root.size)).encloses(guide_panel.get_global_rect()), "How to Play with F fits 720p")
	await capture("medicine_guide_720p")
	key(KEY_ESCAPE)
	key(KEY_ESCAPE)
	await frames(4)
	game.rest.is_resting = true
	await blocked_input("Rest transition")
	game.rest.is_resting = false
	game.preparation_complete = false
	await blocked_input("Loading")
	game.preparation_complete = true
	game.presentation.ending_started = true
	await blocked_input("Ending")
	game.presentation.ending_started = false
	game.waves.state = NightWaveManager.State.GAME_COMPLETED
	await blocked_input("Game completed")
	game.waves.state = NightWaveManager.State.DAY
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await blocked_input("Lost application focus")
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	player.camera_rig.capture_mouse()
	# During Combat, aiming and healing coexist and normal fire still spends ammo.
	bag.add_item(game.catalog.get_item(&"basic_ammo"), 10)
	key(KEY_Q)
	key(KEY_R)
	await frames(100)
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(12)
	var shots := weapons.shots_fired
	key(KEY_F)
	mouse(MOUSE_BUTTON_LEFT, true)
	await frames(1)
	mouse(MOUSE_BUTTON_LEFT, false)
	await frames(3)
	check(player.health.current_hp == 80 and bag.get_item_amount(medicine.id) == 19, "F works while aiming in Combat")
	check(weapons.shots_fired == shots + 1 and weapons.current.current_magazine == 9, "shooting and ammo still work after medicine")
	mouse(MOUSE_BUTTON_RIGHT, false)
	await frames(32)
	root.size = Vector2i(1920,1080)
	await frames(6)
	check(game.hud._medicine_row.get_global_rect().end.y < game.hud._stats_panel.get_global_rect().position.y, "medicine row stays above HP without overlap")
	await capture("medicine_hud_1080p")
	root.size = Vector2i(1024,768)
	await frames(6)
	check(game.hud._medicine_row.visible and Rect2(Vector2.ZERO,Vector2(root.size)).encloses(game.hud._medicine_row.get_global_rect()), "medicine HUD fits 4:3 viewport")
	await capture("medicine_hud_4x3")
	# A different data resource uses the same effect path; no shipped extra item.
	var other := ItemData.new()
	other.id = &"medicine_test_fixture"
	other.display_name = "Data fixture"
	other.item_type = ItemData.ItemType.CONSUMABLE
	other.heal_amount = 17
	other.consume_on_use = false
	bag.add_item(other)
	player.health.take_damage(50)
	check(game.consumables.use_item(other) and player.health.current_hp == 47 and bag.get_item_amount(other.id) == 1, "generic use reads alternate heal amount and consume_on_use from data")
	bag.remove_item(other.id)
	await frames(32)
	game.waves.enabled = true
	game.clock.paused = false
	game.clock.skip_to_night()
	await frames(3)
	check(game.waves.state == NightWaveManager.State.ACTIVE, "actual night wave starts")
	key(KEY_F)
	check(player.health.current_hp == 77 and bag.get_item_amount(medicine.id) == 18, "medicine remains usable during active night wave")
	player.health.take_damage(1000)
	await frames(3)
	await blocked_input("Death / game over")
	check(not game.hud._medicine_row.visible, "medicine hint is hidden on death")
	print("MEDICINE INTEGRATION failures=", failures)
	game.queue_free()
	await frames(4)
	quit(0 if failures == 0 else 1)
