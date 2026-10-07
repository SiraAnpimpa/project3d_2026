extends "res://tests/phase_6_zombie_test.gd"
## Real X/E input and production clock/waves. Debug time seeks and invulnerability
## keep the fixture deterministic; this is not a human ten-night playthrough.

var nights := 0
var dawns := 0

func ready_game() -> void:
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	await frames(15)
	player = game.player
	player.health.damage_enabled = false
	game.clock.set_process(false)
	game.debug_controls.set_active(false)
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	player.camera_rig.capture_mouse()
	game.clock.night_started.connect(func(_day: int) -> void: nights += 1)
	game.clock.new_day_started.connect(func(_day: int) -> void: dawns += 1)

func clear_wave() -> void:
	for tick in 160:
		game.waves._spawn_wait = 0
		game.waves.debug_kill_active()
		await frames(2)
		if game.waves.state == NightWaveManager.State.CLEARED: break
	check(game.waves.state == NightWaveManager.State.CLEARED, "existing wave lifecycle reaches CLEARED")

func hint_visible() -> bool:
	game.skip_night._refresh()
	return game.skip_night.action_button.is_visible_in_tree()

func click_ui(button: Button) -> void:
	var point := root.get_final_transform() * button.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = down
		root.push_input(event)
	await frames(2)

func run() -> void:
	root.size = Vector2i(1280, 720)
	await ready_game()
	check(InputMap.has_action("skip_to_night") and not InputMap.has_action("skip_to_day"), "X has one explicit Skip to Night action")
	check(InputMap.action_get_events("skip_to_night")[0].physical_keycode == KEY_X, "Skip to Night uses physical X")
	game.waves.debug_set_day(2)
	game.clock.seek(2, 8)
	await frames(3)
	check(hint_visible(), "daytime shows contextual X hint")
	check(game.skip_night.action_button.find_children("*", "Label", true, false).any(func(label: Label) -> bool: return label.text == "Skip to Night"), "hint includes full action text")
	await capture("daytime_hint_720")
	var start: float = game.clock.get_elapsed_minutes()
	key(KEY_X)
	check(game.skip_night.is_open and paused and game.skip_night.cancel_button.has_focus(), "X opens confirmation with Cancel focused")
	check(not hint_visible(), "modal hides its gameplay hint")
	await frames(12)
	await capture("confirmation_720")
	var panel: Control = game.skip_night.screen.find_child("Confirmation", true, false)
	check(root.get_visible_rect().encloses(panel.get_global_rect()) and panel.size.y < 310, "confirmation is compact and fits 720p")
	var position_before: Vector3 = player.position
	key(KEY_Q)
	key(KEY_E)
	key(KEY_TAB)
	mouse(MOUSE_BUTTON_RIGHT, true)
	Input.action_press("move_forward")
	await frames(8)
	Input.action_release("move_forward")
	check(player.position == position_before and not player.camera_rig.is_aiming and not game.inventory_ui.is_open and game.clock.get_elapsed_minutes() == start, "confirmation blocks gameplay and time")
	key(KEY_ESCAPE)
	check(not paused and not game.skip_night.is_open and not game.pause_menu.is_open and nights == 0 and game.clock.get_elapsed_minutes() == start, "Esc cancels at Day 2 08:00 without starting night")
	key(KEY_X)
	key(KEY_ENTER)
	await frames(2)
	check(not game.skip_night.is_open and nights == 0, "default Enter activates Cancel")
	key(KEY_X)
	await click_ui(game.skip_night.cancel_button)
	check(not paused and game.clock.get_elapsed_minutes() == start, "Cancel button preserves time")
	for attempt in 3:
		key(KEY_X)
		key(KEY_X)
		game.skip_night.cancel()
	check(not paused and nights == 0, "repeated X and cancel retain a single modal owner")
	# Explicit menu, loading, focus, reload and stale-dialog gates.
	for ui in [game.inventory_ui, game.crafting_ui, game.pause_menu]:
		ui.set_open(true)
		key(KEY_X)
		check(not hint_visible() and not game.skip_night.is_open, "open modal hides and blocks X: " + ui.get_class())
		ui.set_open(false)
		await frames(2)
	game.preparation_complete = false
	check(not hint_visible() and not game.skip_night.request_open(), "loading/preparation blocks X")
	game.preparation_complete = true
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not hint_visible() and not game.skip_night.request_open(), "focus loss hides and blocks X")
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	game.clock.paused = true
	check(not hint_visible() and not game.skip_night.request_open(), "paused clock blocks X")
	game.clock.paused = false
	game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 10)
	game.weapons.start_reload()
	key(KEY_X)
	check(game.weapons.current.is_reloading and not hint_visible() and not game.skip_night.is_open, "reload blocks X")
	await frames(120)
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(2)
	key(KEY_X)
	check(game.skip_night.is_open and not player.camera_rig.is_aiming, "opening confirmation cancels aim")
	game.clock.seek(2, 9)
	game.skip_night.confirm_skip()
	check(not paused and nights == 1 and game.clock.current_hour == 18 and game.clock.current_day == 2, "commit uses current clock time without adding a day")
	await frames(3)
	game.waves.debug_set_day(2)
	game.clock.seek(2, 8)
	key(KEY_X)
	game.clock.skip_to_night()
	var stale_time: float = game.clock.get_elapsed_minutes()
	game.skip_night.confirm_skip()
	check(not paused and not game.skip_night.is_open and game.clock.get_elapsed_minutes() == stale_time, "night transition invalidates stale confirmation")
	game.waves.debug_set_day(2)
	game.clock.seek(2, 8)
	await frames(3)
	# Plant through E; growth must be notified by GameClock's elapsed timestamp.
	game.gameplay_mode.set_mode(GameplayModeController.Mode.FARMING)
	var plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
	game.inventory.select_seed(&"seed_lead")
	await place_player(plot.global_position + Vector3(0, 0.03, 1.1))
	await frames(8)
	key(KEY_E)
	check(plot.state == FarmPlot.State.PLANTED, "actual E plants before daytime skip")
	player.health.damage_enabled = true
	player.health.take_damage(50)
	player.health.damage_enabled = false
	player.stamina.current_stamina = 40
	var hp_before: float = player.health.current_hp
	var seed_count: int = game.inventory.get_item_amount(&"seed_lead")
	var night_before := nights
	var dawn_before := dawns
	start = game.clock.get_elapsed_minutes()
	key(KEY_X)
	game.skip_night.confirm_button.pressed.emit()
	for attempt in 8: game.skip_night.confirm_skip()
	check(game.clock.current_day == 2 and game.clock.current_hour == 18 and game.clock.current_minute == 0 and nights == night_before + 1 and dawns == dawn_before, "Day 2 08:00 confirm reaches same-day 18:00 with one night signal")
	check(player.health.current_hp == hp_before and player.stamina.current_stamina == 40 and not game.rest.is_resting, "skip preserves damaged HP and partly depleted stamina")
	check(is_equal_approx(game.clock.get_elapsed_minutes() - start, 600) and plot.state == FarmPlot.State.READY and game.inventory.get_item_amount(&"lead") == 0, "ten elapsed game hours grow crop without auto-harvest")
	check(game.inventory.get_item_amount(&"seed_lead") == seed_count, "same-day skip grants no next-day supplies")
	await frames(8)
	check(game.waves.state == NightWaveManager.State.ACTIVE and game.waves.spawned_zombies > 0 and not hint_visible(), "ordinary night signal starts production wave/spawning and hides X")
	var bed: ShelterBed = game.get_node("MainWorld/Bed")
	await place_player(bed.global_position + Vector3(0, 0.25, 1.35))
	await frames(15)
	check(player.interactor.target == bed and game.hud.prompt_label.text.contains("Zombies remaining") and not game.hud._prompt_key.visible, "near cabin active-wave prompt explains why rest is unavailable")
	key(KEY_E)
	key(KEY_X)
	check(not game.rest.is_resting and not game.skip_night.is_open and game.clock.current_day == 2, "remaining/incoming zombies block E rest; X cannot bypass night")
	await clear_wave()
	await frames(8)
	check(game.hud.prompt_label.text == "Rest until Morning" and game.hud._prompt_key.text == "E" and game.hud._prompt_key.visible and not hint_visible(), "cleared-night cabin shows E Rest until Morning and no X")
	await capture("cabin_rest_720")
	var cleared_time: float = game.clock.get_elapsed_minutes()
	key(KEY_X)
	check(game.clock.get_elapsed_minutes() == cleared_time and not game.skip_night.is_open, "X has no effect even after a cleared night")
	key(KEY_E)
	check(game.rest.is_resting and paused, "E starts the unchanged cabin rest flow")
	await frames(60)
	check(game.clock.current_day == 3 and game.clock.current_hour == 6 and player.health.current_hp == 100 and player.stamina.current_stamina == 100 and not paused, "rest heals/replenishes and reaches next-day 06:00")
	# Day 1–10 coverage and the late-day boundary use the original wave configs.
	for day in range(1, 11):
		game.waves.debug_set_day(day)
		game.clock.seek(day, 17, 55) if day == 3 else game.clock.seek(day, 10)
		await frames(3)
		check(hint_visible(), "X is available in daytime on Day %d" % day)
		night_before = nights
		dawn_before = dawns
		key(KEY_X)
		check(game.skip_night.is_open, "X opens on Day %d" % day)
		if day == 10:
			check(game.skip_night.title.text == "Begin the Final Night?", "Day 10 explicitly identifies the final night")
			root.size = Vector2i(1920, 1080)
			await frames(12)
			check(root.get_visible_rect().encloses(panel.get_global_rect()), "final-night confirmation fits 1080p")
			await capture("final_night_1080")
		await click_ui(game.skip_night.confirm_button)
		check(game.clock.current_day == day and game.clock.current_hour == 18 and game.clock.current_minute == 0 and nights == night_before + 1 and dawns == dawn_before, "same-day 18:00 and exactly one night event on Day %d" % day)
		check(game.waves.state == NightWaveManager.State.ACTIVE and game.waves._last_started_day == day and game.waves.total_zombies == game.progression.data.get_day(day).wave.spawn_queue().size(), "normal progression wave config starts once on Day %d" % day)
		if day == 3: check(not game.skip_night.request_open(), "17:55 reaches 18:00 without reopening/duplicate transition")
	# Ordinary dawn and final rescue still use existing clock/rest services.
	await clear_wave()
	await place_player(bed.global_position + Vector3(0, 0.25, 1.35))
	await frames(12)
	key(KEY_E)
	await frames(60)
	check(game.presentation.ending_started and game.clock.current_day == 11 and not hint_visible() and not game.skip_night.request_open(), "final-night cabin rest reaches original rescue and disables X")
	game.queue_free()
	await frames(5)
	await ready_game()
	key(KEY_X)
	player.health.die()
	await frames(3)
	check(not paused and not game.skip_night.is_open and not hint_visible() and not game.skip_night.request_open(), "death closes modal and blocks X")
	game.queue_free()
	await frames(5)
	print("SKIP_NIGHT_RESTORATION_RESULT failures=", failures)
	quit(1 if failures else 0)
