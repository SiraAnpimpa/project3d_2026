extends "res://tests/phase_3_integration_test.gd"


func mouse(button: MouseButton, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = down
	root.push_input(event)


func look(offset: Vector2) -> void:
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
	var ray := player.aim_ray
	var ui: InventoryUI = game.get_node("InventoryUI")
	var inventory: Inventory = player.get_node("Inventory")
	var clock: GameClock = game.get_node("TimeController")
	var hud: PrototypeHUD = game.get_node("HUD")
	clock.seek(1, 9, 0)
	key(KEY_F1)
	key(KEY_TAB)
	await frames(2)
	click_button(ui.slot_buttons[0])
	key(KEY_TAB)
	Input.action_press("move_left")
	await frames(60)
	Input.action_release("move_left")
	Input.action_press("move_forward")
	await frames(45)
	Input.action_release("move_forward")
	await frames(12)
	look(Vector2(0, 90))
	await frames(5)
	var plot := player.interactor.target as FarmPlot
	check(plot != null and hud.prompt_label.text.contains("[E] Plant"), "walk from spawn reaches planting prompt with shoulder camera")
	if plot == null:
		print("CAMERA_WALKTHROUGH_RESULT failures=", failures)
		quit(failures)
		return
	await capture("camera_normal_farm")
	key(KEY_E)
	check(plot.state == FarmPlot.State.PLANTED and inventory.get_item_amount(&"seed_lead") == 2, "E plants the selected seed through existing farming interaction")
	clock.time_scale = 20
	await frames(100)
	clock.time_scale = 1
	check(plot.state == FarmPlot.State.READY and hud.prompt_label.text.contains("[E] Harvest"), "crop becomes harvestable with live HUD prompt")
	await capture("camera_farm_ready")
	key(KEY_E)
	check(plot.state == FarmPlot.State.EMPTY and inventory.get_item_amount(&"lead") == 2, "E harvests exactly two Lead and clears plot")
	# Walk along the plots while turning; this follows the production controller.
	Input.action_press("move_left")
	for _i in 30:
		look(Vector2(2, 0))
		await frames(1)
	check(player.visual.current_state == &"Walk", "normal movement with mouse look keeps Walk animation")
	Input.action_release("move_left")
	Input.action_press("move_backward")
	Input.action_press("sprint")
	await frames(24)
	check(player.is_sprinting and player.visual.current_state == &"Run" and player.stamina.current_stamina < 100, "sprint around farm uses Run and consumes stamina")
	Input.action_release("sprint")
	Input.action_release("move_backward")
	await frames(30)
	check(player.visual.current_state == &"Idle", "stopping returns to Idle")
	# Stage near an existing greybox object, then traverse its front while aiming.
	player.position = Vector3(7, 0.05, 7)
	player.velocity = Vector3.ZERO
	rig.rotation.y = 0
	rig.pitch_pivot.rotation.x = -0.30
	key(KEY_Q) # Combat mode enables aim.
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(90)
	check(rig.is_aiming and ray.has_hit and ray.hit_collider == game.get_node("MainWorld/CollisionTestBlock"), "aim ray reaches the existing obstacle through the center crosshair")
	await capture("camera_aim_right")
	for stand_z in [12.0, 20.0]:
		player.position.z = stand_z
		rig.pitch_pivot.rotation.x = -atan(0.9 / (stand_z - 4.0))
		await frames(20)
		check(ray.has_hit and ray.hit_collider == game.get_node("MainWorld/CollisionTestBlock") and rig.camera.unproject_position(ray.aim_point).distance_to(Vector2(640, 360)) < 0.1, "rendered center aim still reaches obstacle from player z=" + str(stand_z))
	await capture("camera_aim_far")
	player.position.z = 7
	rig.pitch_pivot.rotation.x = -0.3
	key(KEY_V)
	await frames(90)
	await capture("camera_aim_left")
	check(rig.shoulder_pivot.position.x < 0 and player.visual.global_basis.z.dot(-rig.global_basis.z) > 0.99, "left shoulder keeps character facing the aim direction")
	key(KEY_V)
	Input.action_press("move_left")
	var start := player.position
	for _i in 30:
		look(Vector2(-1.7, 0))
		await frames(1)
	check(player.position.distance_to(start) > 1 and player.visual.global_basis.z.dot(-rig.global_basis.z) > 0.98 and player.visual.current_state == &"Walk", "strafing around obstacle with mouse aim keeps facing and placeholder Walk")
	await capture("camera_strafe")
	Input.action_release("move_left")
	await frames(15)
	key(KEY_F1)
	await frames(3)
	check(ray.debug_visible(), "F1 enables the aim point and direction debug display")
	await capture("camera_aim_debug")
	key(KEY_TAB)
	await frames(2)
	check(ui.is_open and not rig.is_aiming and not ray.debug_visible() and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "opening bag from aim releases mouse and disables aim/debug marker")
	await capture("camera_inventory")
	key(KEY_ESCAPE)
	key(KEY_F1)
	check(rig.can_control() and not rig.is_aiming, "closing bag resumes normal camera control")
	# Approach the back wall of the existing shelter with camera behind the player.
	player.position = Vector3(-9, 0.05, -6.5)
	player.velocity = Vector3.ZERO
	rig.rotation.y = PI
	rig.pitch_pivot.rotation.x = -0.15
	await frames(30)
	Input.action_press("move_backward")
	await frames(30)
	Input.action_release("move_backward")
	await frames(12)
	check(rig.collision_limited and rig.current_distance < 1, "walking close to existing shelter wall retracts shoulder camera")
	await capture("camera_wall")
	Input.action_press("move_forward")
	await frames(90)
	Input.action_release("move_forward")
	await frames(90)
	check(rig.current_distance > 4, "walking away from wall restores normal camera distance")
	clock.seek(1, 20, 30)
	await frames(5)
	check(hud.day_label.text.contains("NIGHTTIME"), "day-night and HUD remain active with camera rig")
	await capture("camera_night")
	print("CAMERA_WALKTHROUGH_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
