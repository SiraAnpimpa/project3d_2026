extends "res://tests/phase_6_zombie_test.gd"
## Reuse production wave, clock, modal and cabin rest for the N dawn action.

var dawns := 0

func fresh(day: int = 1) -> void:
	if is_instance_valid(game):
		game.queue_free()
		await frames(3)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	player.health.damage_enabled = false
	game.clock.set_process(false)
	game.waves.debug_set_day(day)
	game.debug_controls.set_active(false)
	dawns = 0
	game.clock.new_day_started.connect(func(_day: int) -> void: dawns += 1)

func clear_night() -> void:
	game.clock.skip_to_night()
	for _tick in 100:
		game.waves._spawn_wait = 0
		game.waves.debug_kill_active()
		await frames(2)
		if game.waves.state == NightWaveManager.State.CLEARED: break
	check(game.waves.state == NightWaveManager.State.CLEARED, "real wave is cleared before dawn skip")
	await frames(3)

func run() -> void:
	root.size = Vector2i(1280, 720)
	await fresh()
	check(InputMap.has_action("skip_to_day") and not InputMap.has_action("skip_to_night"), "N has one unambiguous dawn action")
	key(KEY_N)
	check(not game.skip_day.is_open and not game.skip_day.action_button.visible, "daytime hides and rejects Skip to Day")
	game.clock.skip_to_night()
	await frames(10)
	var bed: ShelterBed = game.get_node("MainWorld/Bed")
	await place_player(bed.global_position + Vector3(0, 0.25, 1.35))
	check(player.interactor.target == bed and game.hud.prompt_label.text.contains("Zombies remaining"), "cabin shows concise blocked condition")
	key(KEY_E)
	key(KEY_N)
	check(not game.rest.is_resting and not game.skip_day.is_open and not game.skip_day.action_button.visible, "E and N cannot bypass remaining or incoming zombies")
	await clear_night()
	check(game.hud.prompt_panel.visible and game.hud.prompt_label.text == "Skip Night" and game.skip_day.action_button.visible, "cabin E and contextual N have explicit distinct labels")
	game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT)
	await frames(3)
	check(game.hud.prompt_panel.visible and game.skip_day.action_button.visible, "cabin and dawn actions remain visible in Combat")
	await capture("skip_actions_cabin")
	key(KEY_N)
	check(game.skip_day.is_open and paused and game.skip_day.cancel_button.has_focus(), "N opens reused confirmation with Cancel focused")
	var before: float = game.clock.get_elapsed_minutes()
	var position: Vector3 = player.position
	key(KEY_Q)
	key(KEY_E)
	key(KEY_TAB)
	mouse(MOUSE_BUTTON_RIGHT, true)
	Input.action_press("move_forward")
	await frames(10)
	Input.action_release("move_forward")
	check(player.position == position and not player.camera_rig.is_aiming and game.clock.get_elapsed_minutes() == before and not game.inventory_ui.is_open, "modal blocks movement, aim, interact, inventory and time")
	await capture("skip_day_confirmation")
	var panel: Control = game.skip_day.screen.find_child("Confirmation", true, false)
	check(root.get_visible_rect().encloses(panel.get_global_rect()), "dawn dialog fits 720p")
	key(KEY_ESCAPE)
	check(not paused and not game.skip_day.is_open and not game.pause_menu.is_open and dawns == 0, "Escape cancels without a nested pause or dawn")
	key(KEY_N)
	key(KEY_ENTER)
	await frames(2)
	check(not game.skip_day.is_open and dawns == 0, "default Enter cancels")
	for _attempt in 5:
		key(KEY_N)
		key(KEY_N)
		game.skip_day.cancel_button.pressed.emit()
	check(not paused and dawns == 0, "repeated open/cancel has one modal owner")
	# Plant at cleared night, then use normal clock timestamps for overnight growth.
	game.gameplay_mode.set_mode(GameplayModeController.Mode.FARMING)
	var plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
	await place_player(plot.global_position + Vector3(0, 0.05, 0.9))
	key(KEY_E)
	check(plot.state == FarmPlot.State.PLANTED, "production E plants before the dawn skip")
	var seeds: int = game.inventory.get_item_amount(&"seed_lead")
	player.health.damage_enabled = true
	player.health.take_damage(35)
	player.health.damage_enabled = false
	player.stamina.current_stamina = 42
	key(KEY_N)
	game.skip_day.confirm_button.pressed.emit()
	for _attempt in 8: game.skip_day.confirm_skip()
	check(game.clock.current_day == 2 and game.clock.current_hour == 6 and game.clock.current_minute == 0 and dawns == 1, "confirm reaches next-day 06:00 exactly once")
	check(player.health.current_hp == 65 and player.stamina.current_stamina == 42 and not game.rest.is_resting, "N grants no remote cabin healing or stamina")
	check(plot.state == FarmPlot.State.READY and game.inventory.get_item_amount(&"lead") == 0, "elapsed skip grows plants without auto-harvest")
	var next_day: DayConfig = game.progression.data.get_day(2)
	var expected_seeds := seeds + (next_day.supply_quantity if &"seed_lead" in next_day.supply_seed_ids else 0)
	check(game.inventory.get_item_amount(&"seed_lead") == expected_seeds, "dawn preserves the existing daily seed supply reward")
	await frames(3)
	check(not game.skip_day.action_button.visible and not game.skip_day.request_open() and game.waves.state == NightWaveManager.State.DAY, "dawn hides hint and retains normal day lifecycle")
	# Paused screens, reloading, aim and stale/night-state transitions.
	await fresh()
	await clear_night()
	for ui in [game.inventory_ui, game.crafting_ui, game.pause_menu]:
		ui.set_open(true)
		key(KEY_N)
		check(not game.skip_day.is_open and not game.skip_day.action_button.is_visible_in_tree(), "other modal owns input and hides N hint")
		ui.set_open(false)
		await frames(3)
	game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 10)
	game.weapons.start_reload()
	key(KEY_N)
	check(game.weapons.current.is_reloading and not game.skip_day.is_open, "reload blocks skip")
	await frames(120)
	mouse(MOUSE_BUTTON_RIGHT, true)
	key(KEY_N)
	check(game.skip_day.is_open and not player.camera_rig.is_aiming, "opening N from aim cancels aim safely")
	game.waves.state = NightWaveManager.State.ACTIVE
	game.skip_day.confirm_skip()
	check(not paused and not game.skip_day.is_open and dawns == 0, "lost clear condition aborts stale confirmation")
	game.waves.state = NightWaveManager.State.CLEARED
	key(KEY_N)
	player.health.die()
	await frames(3)
	check(not paused and not game.skip_day.is_open and not game.skip_day.request_open(), "death closes confirmation and blocks skip")
	# Cabin E still restores HP/Stamina via the unchanged RestSystem.
	await fresh()
	await clear_night()
	bed = game.get_node("MainWorld/Bed")
	await place_player(bed.global_position + Vector3(0, 0.25, 1.35))
	player.health.damage_enabled = true
	player.health.take_damage(20)
	player.health.damage_enabled = false
	player.stamina.current_stamina = 42
	var yaw: float = player.camera_rig.rotation.y
	key(KEY_E)
	check(game.rest.is_resting and paused, "E starts the existing cabin rest")
	await frames(60)
	check(game.clock.current_day == 2 and player.health.current_hp == 100 and player.stamina.current_stamina == 100 and not paused and player.camera_rig.rotation.y == yaw, "cabin preserves healing/dawn and camera orientation")
	# Final-night dawn still runs the original rescue.
	await fresh(10)
	await clear_night()
	key(KEY_N)
	check(game.skip_day.title.text == "Skip to rescue morning?", "final night identifies rescue dawn")
	root.size = Vector2i(1920, 1080)
	await frames(3)
	panel = game.skip_day.screen.find_child("Confirmation", true, false)
	check(root.get_visible_rect().encloses(panel.get_global_rect()), "dawn dialog fits 1080p")
	await capture("skip_day_rescue_1080p")
	game.skip_day.confirm_skip()
	await frames(3)
	check(game.presentation.ending_started and not game.skip_day.action_button.visible and not game.skip_day.request_open(), "final dawn reaches original rescue and disables skip")
	print("REFINEMENT_SKIP_RESULT failures=", failures)
	quit(failures)
