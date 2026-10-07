extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func frames(count: int = 2) -> void:
	for _i in count: await process_frame

func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		root.push_input(event)

func click() -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event)

func motion(offset: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.screen_relative = offset
	root.push_input(event)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://scenes/main/GameRoot.tscn").instantiate()
	var rig = game.get_node("Player/CameraPivot")
	rig.set_script(load("res://tests/fixtures/web_camera_double.gd"))
	root.add_child(game)
	current_scene = game
	await frames(15)
	var menu: PauseMenu = game.pause_menu
	check(menu._web_capture_waiting and paused and not rig.can_control(), "startup waits safely for browser engagement")
	check(not rig.capture_requested, "loading never requests capture outside a gesture")
	var yaw: float = rig.rotation.y
	motion(Vector2(900, 400))
	check(rig.rotation.y == yaw, "visible cursor cannot move the camera")
	click()
	check(rig.capture_requested and paused and not rig.can_control(), "engagement click requests lock but waits for asynchronous confirmation")
	await frames()
	check(menu._web_capture_waiting and paused, "a rejected request remains clickable without trapping the game")
	rig.pointer_locked = true
	await frames(3)
	check(not menu._web_capture_waiting and not paused and rig.can_control(), "confirmed lock resumes gameplay")
	motion(Vector2(800, 400))
	check(rig.rotation.y == yaw, "first motion after browser confirmation discards recenter displacement")
	motion(Vector2(20, 0))
	check(is_equal_approx(rig.rotation.y - yaw, -0.06 * CameraPreferences.get_sensitivity()), "subsequent raw mouse motion uses normal sensitivity")
	rig.set_combat_enabled(true)
	var aim := InputEventAction.new()
	aim.action = "aim"
	aim.pressed = true
	rig._unhandled_input(aim)
	check(rig.is_aiming, "captured browser gameplay can aim")
	rig.pointer_locked = false
	await frames(3)
	check(menu.is_open and paused and not rig.is_aiming and not rig.can_control(), "browser-consumed Escape opens Pause and cancels aim")
	menu._open_settings()
	check(menu.settings.visible, "settings opens from Pause")
	key(KEY_ESCAPE)
	check(menu.is_open and not menu.settings.visible and paused, "Escape closes Settings once and returns to Pause")
	rig.capture_requested = false
	key(KEY_ESCAPE)
	check(not menu.is_open and menu._web_capture_waiting and paused, "Escape out of Pause returns to the capture prompt")
	check(not rig.capture_requested, "Escape never tries to bypass the browser unlock gesture requirement")
	click()
	rig.pointer_locked = true
	await frames(3)
	check(rig.can_control() and not paused, "fresh click resumes after Escape")
	key(KEY_TAB)
	check(game.inventory_ui.is_open and paused and not rig.can_control(), "bag releases browser capture")
	key(KEY_ESCAPE)
	check(not game.inventory_ui.is_open and not menu.is_open and menu._web_capture_waiting and paused, "bag Escape returns to capture prompt without also opening Pause")
	key(KEY_ESCAPE)
	check(menu.is_open and not menu._web_capture_waiting and paused, "Escape at capture prompt can open Pause")
	rig.pointer_locked = true
	await frames(3)
	check(not rig.pointer_locked and menu.is_open and paused, "a delayed browser lock is released if a menu opened in the meantime")
	rig.capture_requested = false
	menu._resume_from_button()
	check(rig.capture_requested and menu._web_capture_waiting, "Resume button requests pointer lock inside its pressed gesture")
	rig.pointer_locked = true
	await frames(3)
	rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await frames(3)
	check(menu.is_open and paused and not rig.can_control(), "losing browser focus pauses safely")
	rig.capture_requested = false
	rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(not rig.capture_requested, "focus restoration does not make an unauthorized capture request")
	key(KEY_ESCAPE)
	click()
	rig.pointer_locked = true
	await frames(3)
	check(rig.can_control() and not paused, "focus loss can recover through a fresh engagement")
	game.player.health.die()
	rig.pointer_locked = true
	await frames(3)
	check(not rig.pointer_locked and not rig.can_control() and not menu._web_capture_waiting, "death cancels late capture without covering the death screen")
	print("WEB_MOUSE_CAPTURE_RESULT failures=", failures)
	# Let the engine own teardown of the large rendered world.
	quit(failures)
