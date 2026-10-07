extends "res://tests/phase_9_presentation_test.gd"
## Real menu input and existing engine preferences; fixture does not alter gameplay.

func run() -> void:
	root.size = Vector2i(1280, 720)
	await load_menu()
	await click_scaled(current_scene.settings_button)
	await frames(12)
	var settings: UiSettingsPanel = current_scene.settings
	check(settings.visible and not paused, "title Settings has no gameplay pause to retain")
	await click_control(settings.volume_slider)
	await frames(2)
	var master := AudioServer.get_bus_index("Master")
	var expected: float = settings.volume_slider.value / 100.0
	check(absf(db_to_linear(AudioServer.get_bus_volume_db(master)) - expected) < 0.02, "actual slider click updates engine master gain")
	settings.volume_slider.grab_focus()
	var before := settings.volume_slider.value
	key(KEY_LEFT)
	check(settings.volume_slider.value < before, "volume slider works through keyboard input")
	settings.volume_slider.value = 0
	check(AudioServer.is_bus_mute(master) and settings.volume_label.text == "0%", "zero gain mutes all audio explicitly")
	settings.volume_slider.value = 100
	check(not AudioServer.is_bus_mute(master), "restoring volume unmutes audio")
	await click_scaled(settings.motion_button)
	check(PresentationStyle.reduced_motion and settings.motion_button.text == "Reduced", "actual reduced-motion button applies presentation preference")
	PresentationStyle.appear(settings)
	check(settings.modulate.a == 1, "reduced-motion presentation appears without a fade")
	await click_scaled(settings.motion_button)
	check(not PresentationStyle.reduced_motion, "motion preference can return to standard")
	key(KEY_ESCAPE)
	check(not settings.visible and current_scene.settings_button.has_focus(), "Escape returns from title Settings with focus")
	await start_play()
	var hud: PrototypeHUD = game.hud
	for panel: PanelContainer in [hud._clock_panel, hud._stats_panel, hud._equipment_panel, hud._wave_panel]:
		check(panel.get_theme_stylebox("panel") is StyleBoxFlat, "survival HUD has readable native backing: " + panel.name)
	check(hud.hp_label.text == "100" and hud.stamina_label.text == "100", "floating status reports exact current values")
	key(KEY_ESCAPE)
	await frames(12)
	await click_scaled(game.pause_menu.settings_button)
	await frames(12)
	check(game.pause_menu.settings.visible and game.pause_menu.is_open and paused, "pause Settings keeps its original modal owner")
	check(not game.player.camera_rig.can_control() and not hud._stats_panel.visible, "settings modal gates camera and hides gameplay HUD")
	var position_before: Vector3 = game.player.position
	Input.action_press("move_forward")
	await frames(20)
	Input.action_release("move_forward")
	check(game.player.position == position_before and not game.weapons.try_fire(), "movement and weapons stay gated behind Settings")
	key(KEY_ESCAPE)
	check(game.pause_menu.is_open and paused and not game.pause_menu.settings.visible, "first Escape returns to Pause without resuming")
	await click_scaled(game.pause_menu.get_node("Screen/Panel/Rows/Resume"))
	check(not paused and game.player.camera_rig.can_control() and hud._stats_panel.visible, "Resume restores the existing playfield input boundary")
	key(KEY_Q)
	await frames(3)
	check(hud.ammo_label.visible, "rifle keeps a readable ammo display")
	mouse(MOUSE_BUTTON_WHEEL_DOWN, true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN, false)
	await frames(3)
	check(game.weapons.current.data.is_melee() and not hud.ammo_label.visible and hud._selected_icon.texture == UiIcons.item_icon(game.catalog.get_item(&"wooden_bat")), "bat shows weapon art and no ammunition UI")
	check(hud._slots_row.visible, "combat keeps only a compact equipment slot indicator")
	print("UI_REFINEMENT_RESULT failures=", failures)
	quit(1 if failures else 0)

func click_control(control: Control) -> void:
	var point := root.get_final_transform() * control.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = down
		root.push_input(event)
