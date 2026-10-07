extends "res://tests/camera_controls_test.gd"
## Exercise actual mouse events in rendered runs; headless must reject them.

var game: Node3D
var capture_dir := ""

func angles() -> Vector2:
	return Vector2(game.player.camera_rig.global_rotation.y, game.player.camera_rig.pitch_pivot.rotation.x)

func capture_view(label: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless": return
	await frames(15) # Capture the settled existing UI fade, not its opening frame.
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label + ".png"))

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if "--settings-write" in args or "--settings-read" in args:
		if "--settings-write" in args: CameraPreferences.set_sensitivity(1.7)
		check(is_equal_approx(CameraPreferences.get_sensitivity(), 1.7), "preference persists across separate game processes")
		print("CAMERA_SETTINGS_RESULT failures=", failures)
		quit(failures)
		return
	if "--capture-dir" in args: capture_dir = args[args.find("--capture-dir") + 1]
	var original := CameraPreferences.get_sensitivity()
	CameraPreferences.set_sensitivity(1.0)
	root.size = Vector2i(1280, 720)
	if "--idle-only" not in args:
		var first_menu: Control = load("res://scenes/main/MainMenu.tscn").instantiate()
		root.add_child(first_menu)
		current_scene = first_menu
		await frames(5)
		var point: Vector2 = root.get_final_transform() * first_menu.settings_button.get_global_rect().get_center()
		for down in [true, false]:
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.position = point
			event.global_position = point
			event.pressed = down
			root.push_input(event)
		await frames(15)
		check(first_menu.settings.visible and root.get_visible_rect().encloses(first_menu.settings.get_global_rect()), "first Main Menu Settings click fits 720p without hidden autowrap growth")
		first_menu.queue_free()
		await frames(3)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	game.clock.set_process(false)
	game.debug_controls.set_active(false)
	game.player.health.damage_enabled = false
	game.player.position = Vector3(12, 0.05, -12)
	var rig: ThirdPersonCamera = game.player.camera_rig
	await frames(10)
	if "--idle-only" in args:
		for context in ["farming_day", "combat_day", "released_aim", "farming_night", "combat_night", "near_cabin", "near_workbench"]:
			game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT if context in ["combat_day", "combat_night", "released_aim"] else GameplayModeController.Mode.FARMING)
			if context == "farming_night": game.clock.skip_to_night()
			if context == "released_aim":
				mouse(MOUSE_BUTTON_RIGHT, true)
				await frames(5)
				mouse(MOUSE_BUTTON_RIGHT, false)
			if context == "near_cabin": game.player.position = game.get_node("MainWorld/Bed").global_position + Vector3(0, 0.1, 1.35)
			if context == "near_workbench": game.player.position = game.get_node("MainWorld/Workbench").global_position + Vector3(0, 0.1, 1.2)
			await frames(5)
			var before := angles()
			var basis: Basis = rig.camera.global_basis
			await frames(1800)
			check(angles().is_equal_approx(before) and rig.camera.global_basis.is_equal_approx(basis), "30 simulated seconds without yaw/pitch drift: " + context)
	else:
		for action in ["move_forward", "move_left", "move_backward", "move_right", "sprint"]:
			var before := angles()
			Input.action_press(action)
			if action == "sprint": Input.action_press("move_forward")
			await frames(60)
			Input.action_release(action)
			Input.action_release("move_forward")
			check(angles().is_equal_approx(before), "movement has no camera feedback: " + action)
		var before := angles()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		motion(Vector2(100, 50))
		check(angles().is_equal_approx(before), "visible cursor cannot rotate camera")
		rig.capture_mouse()
		motion(Vector2(700, 500))
		check(angles().is_equal_approx(before), "capture-frame motion cannot cause jump")
		await frames(3)
		for screen_name in ["inventory", "crafting", "pause", "settings"]:
			before = angles()
			match screen_name:
				"inventory": game.inventory_ui.set_open(true)
				"crafting": game.crafting_ui.set_open(true)
				_: game.pause_menu.set_open(true)
			if screen_name == "settings": game.pause_menu._open_settings()
			motion(Vector2(900, 700))
			check(angles().is_equal_approx(before), "UI motion gated: " + screen_name)
			match screen_name:
				"inventory": game.inventory_ui.set_open(false)
				"crafting": game.crafting_ui.set_open(false)
				_:
					if screen_name == "settings": game.pause_menu.settings.close()
					game.pause_menu.set_open(false)
			motion(Vector2(700, 500))
			check(angles().is_equal_approx(before), "closing UI discards recapture delta: " + screen_name)
			await frames(3)
		rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		before = angles()
		motion(Vector2(100, 50))
		rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
		motion(Vector2(700, 500))
		check(angles().is_equal_approx(before), "focus restoration discards pending motion")
		await frames(3)
		for multiplier in [0.2, 1.0, 2.0]:
			game.pause_menu.set_open(true)
			game.pause_menu._open_settings()
			var settings: UiSettingsPanel = game.pause_menu.settings
			settings.sensitivity_slider.value = multiplier
			check(is_equal_approx(CameraPreferences.get_sensitivity(), multiplier) and settings.sensitivity_label.text == "%.1fx" % multiplier, "shared slider applies immediately: %.1fx" % multiplier)
			await frames(3)
			check(root.get_visible_rect().encloses(settings.get_global_rect()), "Settings fits 720p")
			if multiplier == 1.0:
				settings.sensitivity_slider.grab_focus()
				key(KEY_LEFT)
				check(is_equal_approx(settings.sensitivity_slider.value, 0.9) and is_equal_approx(CameraPreferences.get_sensitivity(), 0.9), "real slider keyboard input updates the shared setting")
				settings.sensitivity_slider.value = multiplier
				await capture_view("camera_settings_720p")
			settings.close()
			check(paused and game.pause_menu.is_open, "Settings Back retains Pause owner")
			game.pause_menu.set_open(false)
			await frames(3)
			for aiming in [false, true]:
				game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT)
				mouse(MOUSE_BUTTON_RIGHT, aiming)
				rig.pitch_pivot.rotation.x = -0.23
				before = angles()
				motion(Vector2(20, -10))
				var expected: Vector2 = Vector2(-20, 10) * rig.mouse_sensitivity * multiplier if DisplayServer.get_name() != "headless" else Vector2.ZERO
				check((angles() - before).is_equal_approx(expected), "actual mouse multiplier %.1fx aim=%s" % [multiplier, aiming])
			mouse(MOUSE_BUTTON_RIGHT, false)
			before = angles()
			await frames(5)
			check(angles().is_equal_approx(before), "RMB release has no rotation snap")
		CameraPreferences.set_sensitivity(1.0)
		for rate in [30, 120]:
			Engine.physics_ticks_per_second = rate
			await frames(3)
			before = angles()
			motion(Vector2(20, 0))
			check(is_equal_approx(angles().x - before.x, -0.06 if DisplayServer.get_name() != "headless" else 0.0), "equal displacement at %d physics Hz" % rate)
		Engine.physics_ticks_per_second = 60
		var menu: Control = load("res://scenes/main/MainMenu.tscn").instantiate()
		root.add_child(menu)
		game.hide()
		rig.set_menu_open(true)
		menu._open_settings()
		await frames(3)
		check(is_equal_approx(menu.settings.sensitivity_slider.value, 1.0), "Main Menu shares the preference")
		root.size = Vector2i(1920, 1080)
		await frames(10)
		check(root.get_visible_rect().encloses(menu.settings.get_global_rect()), "Main Menu Settings fits 1080p")
		await capture_view("camera_settings_1080p")
		menu.queue_free()
	CameraPreferences.set_sensitivity(original)
	print("CAMERA_CLARITY_RESULT failures=", failures, " rendered=", DisplayServer.get_name() != "headless")
	game.queue_free()
	await process_frame
	quit(failures)
