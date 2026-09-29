extends SceneTree

var failures := 0


func _initialize() -> void: call_deferred("run")


func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func frames(count: int) -> void:
	for _i in count: await physics_frame


func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = down
		root.push_input(event)


func mouse(button: MouseButton, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = down
	root.push_input(event)


func motion(offset: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.screen_relative = offset
	root.push_input(event)


func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	var player: PlayerController = game.get_node("Player")
	var rig := player.camera_rig
	var camera := rig.camera
	var ui: InventoryUI = game.get_node("InventoryUI")
	var crosshair: AimCrosshair = game.get_node("HUD/Root/Crosshair")
	game.clock.paused = true
	player.position = Vector3(12, 0.05, -12)
	await frames(20)
	check(InputMap.has_action("aim") and not InputMap.has_action("camera_orbit"), "RMB action migrated to aim without duplicate orbit binding")
	check(rig.can_control(), "gameplay starts with active mouse-look intent")
	if DisplayServer.get_name() != "headless": check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "rendered gameplay captures mouse at startup")
	var body_screen := camera.unproject_position(player.global_position + Vector3.UP * 1.0)
	check(body_screen.x < 620 and rig.shoulder_pivot.position.x > 0, "right-shoulder framing places Somchai left of center")
	var yaw := rig.rotation.y
	var pitch := rig.pitch_pivot.rotation.x
	motion(Vector2(100, -50))
	check(is_equal_approx(rig.rotation.y - yaw, -0.3) and is_equal_approx(rig.pitch_pivot.rotation.x - pitch, 0.15), "raw mouse displacement rotates yaw and pitch without delta scaling")
	rig.orbit(0, -100)
	check(is_equal_approx(rig.pitch_pivot.rotation.x, deg_to_rad(-65)), "downward pitch clamps at -65 degrees")
	rig.orbit(0, 100)
	check(is_equal_approx(rig.pitch_pivot.rotation.x, deg_to_rad(45)) and rig.rotation.z == 0 and rig.pitch_pivot.rotation.z == 0, "upward pitch clamps at 45 degrees with no roll")
	rig.rotation.y = PI / 2
	rig.pitch_pivot.rotation.x = -0.23
	await frames(10)
	var start := player.position
	Input.action_press("move_forward")
	await frames(30)
	Input.action_release("move_forward")
	check(player.position.x < start.x - 1.4 and absf(player.position.z - start.z) < 0.1, "W follows camera forward after a 90-degree yaw")
	check(player.visual.global_basis.z.dot(-rig.global_basis.z) > 0.97, "normal visual +Z turns toward movement smoothly")
	await frames(15)
	# Source GLB Foot.L_end/Foot.R_end translate along each foot's local +Y.
	# Godot omits these non-skin endpoint nodes; use the imported foot rest basis.
	var skeleton := player.visual.find_child("Skeleton3D", true, false) as Skeleton3D
	var forward_verified := skeleton != null
	if skeleton != null:
		for bone_name in ["Foot.L", "Foot.R"]:
			var foot := skeleton.find_bone(bone_name)
			if foot < 0:
				forward_verified = false
				continue
			var authored_forward := skeleton.global_basis * skeleton.get_bone_global_rest(foot).basis.y
			var alignment := authored_forward.normalized().dot(player.visual.global_basis.z.normalized())
			print("MATT_FOOT_FORWARD ", bone_name, " dot_visual_Z=", alignment)
			forward_verified = forward_verified and alignment > 0.99
	check(forward_verified, "both imported Matt foot directions confirm authored +Z forward")
	rig.rotation.y = 0
	key(KEY_Q) # Aim now requires Combat mode.
	var normal_fov := camera.fov
	mouse(MOUSE_BUTTON_RIGHT, true)
	check(rig.is_aiming and crosshair.visible, "RMB press enters aim and enables crosshair")
	await frames(2)
	check(camera.fov < normal_fov and camera.fov > rig.aim_fov and rig.desired_distance > rig.aim_distance, "aim framing transitions instead of snapping")
	await frames(75)
	check(absf(camera.fov - rig.aim_fov) < 0.01 and absf(rig.current_distance - rig.aim_distance) < 0.01, "aim reaches configured distance and FOV")
	check(player.visual.global_basis.z.dot(-rig.global_basis.z) > 0.999, "stationary aiming rotates visual toward camera forward")
	var directions := {"move_forward": Vector3.FORWARD, "move_backward": Vector3.BACK, "move_left": Vector3.LEFT, "move_right": Vector3.RIGHT}
	for action in directions:
		player.velocity = Vector3.ZERO
		start = player.position
		Input.action_press(action)
		await frames(30)
		Input.action_release(action)
		check((player.position - start).dot(directions[action]) > 1.0 and player.visual.global_basis.z.dot(Vector3.FORWARD) > 0.99, "aim movement " + action + " keeps visual facing aim")
		await frames(12)
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await frames(10)
	check(player.is_sprinting and not rig.is_aiming and player.stamina.current_stamina < 100, "moving with Shift exits aim, sprints and drains stamina")
	Input.action_release("sprint")
	Input.action_release("move_forward")
	await frames(5)
	check(rig.is_aiming and not player.is_sprinting, "held RMB resumes aim after sprint ends")
	mouse(MOUSE_BUTTON_RIGHT, false)
	check(not rig.is_aiming, "RMB release exits aim")
	await frames(90)
	check(absf(camera.fov - rig.normal_fov) < 0.01, "normal FOV restores smoothly")
	key(KEY_V)
	await frames(75)
	check(rig.shoulder_pivot.position.x < -0.69, "V switches smoothly to left shoulder")
	key(KEY_V)
	await frames(75)
	check(rig.shoulder_pivot.position.x > 0.69, "V switches back to right shoulder")
	mouse(MOUSE_BUTTON_RIGHT, true)
	key(KEY_TAB)
	check(ui.is_open and paused and not rig.is_aiming and not crosshair.visible and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "inventory releases mouse, disables aim and hides crosshair")
	yaw = rig.rotation.y
	var time_before: float = game.clock.get_elapsed_minutes()
	motion(Vector2(800, 600))
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(20)
	check(rig.rotation.y == yaw and not rig.is_aiming and game.clock.get_elapsed_minutes() == time_before, "menu blocks mouse look and aiming behind UI")
	key(KEY_ESCAPE)
	check(not ui.is_open and not paused and rig.can_control() and not rig.is_aiming, "Escape closes inventory once and restores normal camera control")
	if DisplayServer.get_name() != "headless": check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "closing inventory recaptures mouse")
	key(KEY_ESCAPE)
	motion(Vector2(500, 0))
	check(not rig.can_control() and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and rig.rotation.y == yaw, "Escape during gameplay pauses and releases the cursor")
	key(KEY_ESCAPE)
	check(rig.can_control() and not paused, "Escape resumes and recaptures camera control")
	mouse(MOUSE_BUTTON_RIGHT, true)
	rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not rig.is_aiming and not rig.can_control(), "focus loss cancels aim and camera control")
	rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(rig.can_control() and not rig.is_aiming, "focus restoration never leaves aim stuck")
	paused = true
	check(not rig.is_aiming and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "external scene pause also releases mouse")
	paused = false
	player.health.die()
	check(not rig.can_control() and not rig.is_aiming, "death disables camera controls and aim")
	player.health.reset()
	check(rig.can_control(), "restoring player restores camera controls")
	print("CAMERA_CONTROLS_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
