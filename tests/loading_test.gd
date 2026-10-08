extends "res://tests/phase_6_zombie_test.gd"
var saw_preparation_indicator := false
var preparation_frames := 0
var greatest_frame_ms := 0.0
var previous_frame := 0
var loading_snapshot := false

func run() -> void:
	root.size = Vector2i(1280,720)
	var menu: Control = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(6)
	click_button(menu.play_button)
	await frames(3)
	check(current_scene.scene_file_path.ends_with("Loading.tscn"), "real Play enters lightweight Loading scene")
	var loader = current_scene
	var deadline := Time.get_ticks_msec()+30000
	while current_scene == loader and Time.get_ticks_msec() < deadline:
		var now := Time.get_ticks_usec()
		if previous_frame > 0: greatest_frame_ms = maxf(greatest_frame_ms,(now-previous_frame)/1000.0)
		previous_frame = now
		preparation_frames += 1
		if is_instance_valid(loader._game):
			saw_preparation_indicator = saw_preparation_indicator or (loader._bar.visible and loader._bar.indeterminate)
			if preparation_frames%30 == 0:
				check(loader._game.process_mode == Node.PROCESS_MODE_DISABLED, "gameplay stays disabled throughout preparation/fade")
			for code in [KEY_Q, KEY_TAB, KEY_ESCAPE, KEY_E, KEY_X, KEY_C, KEY_R, KEY_QUOTELEFT, KEY_T]: key(code)
			if not loading_snapshot and DisplayServer.get_name() != "headless":
				await capture("loading_preparation_720")
				loading_snapshot = true
		await process_frame
	await wait_for_gameplay()
	game = current_scene
	player = game.player
	check(game.preparation_complete and game.get_node("MainWorld/Terrain").preparation_complete and game.get_node("MainWorld/RuralEnvironment").preparation_complete, "every world builder finishes before gameplay")
	check(saw_preparation_indicator and preparation_frames > 10, "loading keeps a progress indicator visible throughout world preparation")
	check(not paused and not game.pause_menu.is_open and not game.inventory_ui.is_open and not game.cheats_menu.is_open and game.gameplay_mode.is_farming(), "loading input cannot pause/open UI/open cheats/change gameplay mode")
	check(not has_meta("loading_world") and not has_meta("normal_play"), "transition removes preparation metadata")
	check(game.clock.current_day == 1 and game.clock.current_hour == 6 and game.weapons.current.current_magazine == 0, "loading does not advance campaign or grant ammunition")
	check(game.get_node("MainWorld/RuralEnvironment").grass_counts.size() > 0, "complete vegetation appears before fade finishes")
	await capture("loading_complete_720")
	key(KEY_TAB)
	await frames(3)
	check(game.inventory_ui.is_open, "input resumes after loading")
	key(KEY_TAB)
	await frames(3)
	# A missing resource must restore a usable menu and clear transition state.
	game.queue_free()
	await frames(3)
	var failure_scene = load("res://scenes/main/Loading.tscn").instantiate()
	failure_scene.game_path = "res://tests/intentionally_missing_game.tscn"
	root.add_child(failure_scene)
	current_scene = failure_scene
	deadline = Time.get_ticks_msec()+5000
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if current_scene != null and current_scene.scene_file_path.ends_with("MainMenu.tscn"): break
	check(current_scene != null and current_scene.scene_file_path.ends_with("MainMenu.tscn") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not paused, "load failure returns to usable Main Menu")
	check(not has_meta("loading_world") and not has_meta("normal_play"), "load failure cleans up preparation flags")
	print("LOADING_MEASURE frames=",preparation_frames," preparation_indicator=",saw_preparation_indicator," longest_ms=",greatest_frame_ms)
	current_scene.queue_free()
	await frames(5)
	print("LOADING_RESULT failures=",failures)
	quit(1 if failures else 0)
