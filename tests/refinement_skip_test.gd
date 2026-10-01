extends "res://tests/phase_6_zombie_test.gd"

var nights := 0
var dawns := 0

func fresh(day: int = 1, hour: int = 6, minute: int = 0) -> void:
	if is_instance_valid(game):
		game.queue_free()
		await frames(3)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	player = game.player
	game.clock.set_process(false)
	game.waves.debug_set_day(day)
	game.clock.seek(day,hour,minute)
	game.debug_controls.set_active(false)
	nights = 0
	dawns = 0
	game.clock.night_started.connect(func(_day: int) -> void: nights+=1)
	game.clock.new_day_started.connect(func(_day: int) -> void: dawns+=1)

func run() -> void:
	root.size = Vector2i(1280,720)
	await fresh()
	check(game.skip_night.action_button.visible and not game.skip_night.action_button.disabled,"daytime action visible by clock with distinct N binding")
	# Empty ammo never blocks the player's preparation decision.
	key(KEY_N)
	check(game.skip_night.is_open and paused and game.clock.current_hour == 6 and nights == 0,"N opens confirmation without skipping even with zero ammunition")
	check(game.skip_night.cancel_button.has_focus(),"Cancel gets default keyboard focus")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not player.camera_rig.can_control() and not player.interactor.enabled,"confirmation releases mouse and locks camera/interactor")
	var before: float = game.clock.get_elapsed_minutes()
	var point := player.position
	key(KEY_Q)
	key(KEY_E)
	key(KEY_TAB)
	mouse(MOUSE_BUTTON_RIGHT,true)
	# An explicit point outside the dialog avoids activating a focused UI button.
	for down in [true,false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = Vector2(1200,650)
		event.global_position = event.position
		event.pressed = down
		root.push_input(event)
	Input.action_press("move_forward")
	await frames(10)
	Input.action_release("move_forward")
	check(game.clock.get_elapsed_minutes()==before and player.position==point and not player.camera_rig.is_aiming and game.weapons.shots_fired==0 and not game.inventory_ui.is_open,"modal blocks background movement/time/fire/aim/interact/bag")
	await capture("skip_confirmation")
	var panel: Control = game.skip_night.screen.find_child("Confirmation",true,false)
	check(root.get_visible_rect().encloses(panel.get_global_rect()),"confirmation and both buttons fit720p viewport")
	key(KEY_ESCAPE)
	check(not game.skip_night.is_open and not paused and not game.pause_menu.is_open and game.clock.get_elapsed_minutes()==before and nights==0,"Escape cancels with no time/day/wave change and no nested Pause")
	check((DisplayServer.get_name()=="headless" or Input.mouse_mode==Input.MOUSE_MODE_CAPTURED) and player.camera_rig.can_control(),"cancel restores gameplay and captured mouse in windowed runs")
	# Enter on the initially focused Cancel must cancel, not confirm.
	key(KEY_N)
	key(KEY_ENTER)
	await frames(2)
	check(not game.skip_night.is_open and nights==0,"default Enter is Cancel")
	for attempt in 5:
		key(KEY_N)
		key(KEY_N)
		game.skip_night.cancel_button.pressed.emit()
	check(not paused and game.clock.get_elapsed_minutes()==before and nights==0,"repeated open/N/cancel cannot duplicate modal or advance time")
	# Real button Confirm, exactly one boundary notification, no free HP/stamina/ammo.
	player.health.take_damage(35)
	player.stamina.current_stamina = 42
	key(KEY_N)
	click_button(game.skip_night.confirm_button)
	for attempt in 8: game.skip_night.confirm_skip()
	check(game.clock.current_day==1 and game.clock.current_hour==18 and game.clock.current_minute==0 and nights==1 and dawns==0,"06:00 Confirm reaches same-day18:00 and starts night exactly once despite spam")
	check(player.health.current_hp==65 and player.stamina.current_stamina==42 and not game.rest.is_resting and game.weapons.current.current_magazine==0,"skip gives no healing/stamina/rest/reload reward")
	await frames(8)
	check(game.waves.state==NightWaveManager.State.ACTIVE and game.waves.total_zombies==6 and game.waves.spawned_zombies==1,"normal manager starts production Day1 wave")
	check(not game.skip_night.action_button.visible and not game.skip_night.request_open(),"night hides action and rejects reopening")
	check(game.hud.time_label.text.contains("18:00") and is_equal_approx(game.lighting.sun.light_energy,game.lighting.night_energy),"HUD and lighting share the new clock phase")
	await capture("skip_night_started")
	# Midday and near-dusk growth use timestamp delta, including a fractional minute.
	for time in [Vector2i(12,34),Vector2i(17,55)]:
		await fresh(1,time.x,time.y)
		var plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
		await place_player(plot.position + Vector3(0,0.05,0.9))
		key(KEY_E)
		check(plot.state==FarmPlot.State.PLANTED,"E plants before midday/late skip")
		game.clock.advance_game_minutes(0.25)
		var growth: float = plot.growth_progress
		var timestamp: float = game.clock.get_elapsed_minutes()
		var seed_count: int = game.inventory.get_item_amount(&"seed_lead")
		key(KEY_N)
		await frames(8)
		game.skip_night.cancel()
		check(plot.growth_progress==growth and game.clock.get_elapsed_minutes()==timestamp,"Cancel preserves plant timestamp and progress")
		key(KEY_N)
		game.skip_night.confirm_skip()
		var expected := clampf(float(18*60-(time.x*60+time.y))/36.0,0,1)
		check(is_equal_approx(plot.growth_progress,expected),"skipped elapsed minutes correctly advance Lead growth")
		check(game.inventory.get_item_amount(&"seed_lead")==seed_count and game.inventory.get_item_amount(&"lead")==0,"growing never auto-harvests or grants resources")
		check(nights==1 and dawns==0 and game.clock.current_day==1 and game.clock.current_hour==18 and game.clock.current_minute==0,"midday/17:55 fractional skip reaches exactly one dusk")
	# Menu ownership and critical timed action gates.
	await fresh()
	key(KEY_TAB)
	key(KEY_N)
	check(game.inventory_ui.is_open and not game.skip_night.is_open,"bag owns input; no overlapping confirmation")
	key(KEY_TAB)
	game.crafting_ui.set_open(true)
	key(KEY_N)
	check(game.crafting_ui.is_open and not game.skip_night.is_open,"workbench owns input; no overlapping confirmation")
	key(KEY_ESCAPE)
	key(KEY_ESCAPE)
	key(KEY_N)
	check(game.pause_menu.is_open and not game.skip_night.is_open,"Pause owns input; no overlapping confirmation")
	key(KEY_ESCAPE)
	key(KEY_Q)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),10)
	game.weapons.start_reload()
	key(KEY_N)
	check(game.weapons.current.is_reloading and not game.skip_night.is_open,"critical reload must finish before waiting")
	await frames(95)
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(5)
	key(KEY_N)
	check(game.skip_night.is_open and not player.camera_rig.is_aiming,"opening from Combat cancels aim safely")
	player.health.die()
	await frames(3)
	check(not paused and not game.skip_night.is_open and not game.skip_night.request_open() and Input.mouse_mode==Input.MOUSE_MODE_VISIBLE,"death while confirming closes ownership and prevents skip")
	# Final night wording and terminal exclusion.
	await fresh(10,17,55)
	key(KEY_N)
	check(game.skip_night.title.text=="Begin the Final Night?" and game.skip_night.confirm_button.text=="BEGIN FINAL NIGHT","Day10 warns explicitly about the final night")
	await capture("skip_final_night")
	root.size = Vector2i(1920,1080)
	await frames(3)
	await capture("skip_final_night_1080")
	panel = game.skip_night.screen.find_child("Confirmation",true,false)
	check(root.get_visible_rect().encloses(panel.get_global_rect()),"final confirmation fits1080p viewport")
	game.skip_night.confirm_skip()
	check(nights==1 and game.waves.total_zombies==24 and game.clock.current_day==10,"Day10 uses existing final wave once")
	game.clock.advance_game_minutes(720)
	await frames(3)
	check(game.presentation.ending_started and not game.skip_night.action_button.visible and not game.skip_night.request_open(),"ending rejects skip")
	# External day invalidation while a modal is open cannot confirm a stale decision.
	await fresh()
	key(KEY_N)
	game.clock.seek(2,6,0)
	game.skip_night.confirm_skip()
	check(not game.skip_night.is_open and not paused and game.clock.current_hour==6 and nights==0,"stale day confirmation aborts safely")
	print("REFINEMENT_SKIP_RESULT failures=",failures)
	quit(1 if failures else 0)
