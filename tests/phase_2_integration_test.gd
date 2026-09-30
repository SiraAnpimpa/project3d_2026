extends SceneTree

var failures: int = 0
var capture_directory: String = ""


func _initialize() -> void:
	var arguments := OS.get_cmdline_user_args()
	var index := arguments.find("--capture-dir")
	if index >= 0 and index + 1 < arguments.size():
		capture_directory = arguments[index + 1]
	call_deferred("run")


func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func frames(count: int) -> void:
	for _index in count:
		await physics_frame


func press_key(key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	root.push_input(event)
	event = InputEventKey.new()
	event.physical_keycode = key
	event.pressed = false
	root.push_input(event)


func capture(name: String) -> void:
	if capture_directory.is_empty() or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var result := image.save_png(capture_directory.path_join(name + ".png"))
	check(result == OK and not image.is_empty(), "rendered screenshot saved: " + name)


func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	var player := game.get_node("Player") as PlayerController
	var clock := game.get_node("TimeController") as GameClock
	var hud := game.get_node("HUD") as PrototypeHUD
	var debug := game.get_node("DebugControls") as DebugControls
	clock.paused = true
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/main/MainMenu.tscn", "main scene is configured")
	var input_ok := true
	for action in ["move_forward", "move_backward", "move_left", "move_right", "sprint", "interact", "aim", "debug_toggle"]:
		input_ok = input_ok and InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty()
	check(input_ok, "required actions have input bindings")
	check(hud.hp_bar.value == 100.0 and hud.stamina_bar.value == 100.0, "HUD initializes player stats")
	check(hud.day_label.text.contains("DAY 1") and hud.time_label.text == "06:00", "HUD initializes day and HH:MM clock")
	press_key(KEY_F2)
	check(player.health.current_hp == 80.0 and hud.hp_bar.value == 80.0, "physical F2 input damages player and updates HUD")
	press_key(KEY_F3)
	check(player.health.current_hp == 100.0, "physical F3 heals player")
	press_key(KEY_F4)
	check(player.stamina.current_stamina == 70.0 and hud.stamina_bar.value == 70.0, "F4 drains stamina and updates HUD")
	press_key(KEY_F5)
	check(player.stamina.current_stamina == 100.0, "F5 restores stamina")
	press_key(KEY_F9)
	check(clock.is_nighttime and hud.time_label.text == "18:00", "F9 changes clock and HUD to night")
	press_key(KEY_F8)
	check(clock.current_day == 2 and hud.day_label.text.contains("DAY 2"), "F8 advances next dawn and day counter")
	press_key(KEY_F7)
	check(hud.time_label.text == "07:00", "F7 adds one game hour")
	press_key(KEY_F6)
	check(hud.time_label.text == "06:00", "F6 rewinds one game hour")
	clock.paused = false
	press_key(KEY_F10)
	check(clock.time_scale == 20.0 and hud.debug_status.text.contains("x20"), "F10 toggles accelerated time")
	press_key(KEY_F11)
	check(clock.paused, "F11 pauses the game clock")
	press_key(KEY_F1)
	press_key(KEY_F2)
	check(not debug.active and not hud.debug_panel.visible and player.health.current_hp == 100.0, "disabled debug ignores damage keys and hides panel")
	check(clock.time_scale == 1.0 and not clock.paused, "disabling debug restores normal running time")
	debug.debug_enabled = false
	press_key(KEY_F1)
	check(not debug.active, "Inspector debug switch prevents re-enabling controls")
	debug.debug_enabled = true
	press_key(KEY_F1)
	check(debug.active and hud.debug_panel.visible, "F1 re-enables development tools")
	clock.paused = true
	player.position = Vector3(0, 0.05, 1.2)
	await frames(8)
	check(hud.prompt_panel.visible and hud.prompt_label.text.contains("[E]"), "nearby station displays interaction prompt")
	press_key(KEY_E)
	check(hud.toast_label.text == "Interaction Successful", "physical E input shows interaction feedback")
	press_key(KEY_Q) # Enter Combat for the existing aim-camera integration check.
	var old_yaw := player.camera_rig.rotation.y
	var mouse_button := InputEventMouseButton.new()
	mouse_button.button_index = MOUSE_BUTTON_RIGHT
	mouse_button.pressed = true
	root.push_input(mouse_button)
	var motion := InputEventMouseMotion.new()
	motion.screen_relative = Vector2(80, 40)
	root.push_input(motion)
	if DisplayServer.get_name() != "headless":
		check(not is_equal_approx(old_yaw, player.camera_rig.rotation.y), "mouse motion rotates the shoulder camera while aiming")
	else:
		print("SKIP: captured mouse motion requires a window; covered by the rendered test run")
	press_key(KEY_ESCAPE)
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Escape pauses and releases captured mouse")
	press_key(KEY_ESCAPE)
	player.camera_rig.rotation.y = 0.0
	player.camera_rig.pitch_pivot.rotation.x = -0.38
	clock.seek(1, 14, 32)
	await frames(5)
	await capture("phase2_day")
	clock.seek(1, 21, 0)
	await frames(5)
	await capture("phase2_night")
	player.health.take_damage(1000)
	await frames(5)
	check(hud.death_panel.visible and not player.interactor.enabled, "death shows restart UI and disables interactions")
	press_key(KEY_F12)
	await frames(5)
	check(not player.health.is_dead and not hud.death_panel.visible, "F12 restores player and clears death UI")
	# Verify the actual restart action, including reconnection of all new scene signals.
	player.health.die()
	press_key(KEY_R)
	await frames(10)
	game = current_scene as Node3D
	player = game.get_node("Player") as PlayerController
	hud = game.get_node("HUD") as PrototypeHUD
	check(player.health.current_hp == 100.0 and not hud.death_panel.visible, "R restarts the main scene with fresh state")
	print("PHASE_2_INTEGRATION_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
