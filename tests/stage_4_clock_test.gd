extends SceneTree

var failures: int = 0
var dawn_events: int = 0
var night_events: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func run() -> void:
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	var clock := game.get_node("TimeController") as GameClock
	clock.set_process(false)
	clock.new_day_started.connect(func(_day: int) -> void: dawn_events += 1)
	clock.night_started.connect(func(_day: int) -> void: night_events += 1)
	check(clock.current_day == 1 and clock.current_hour == 6 and clock.is_daytime, "initial state is Day 1 at 06:00")
	clock.advance(600.0)
	check(clock.current_hour == 18 and clock.current_minute == 0 and clock.is_nighttime, "600 real seconds reaches night at 18:00")
	check(night_events == 1, "night transition emits once")
	var sun := game.get_node("MainWorld/Sun") as DirectionalLight3D
	check(is_equal_approx(sun.light_energy, game.get_node("DayNightEnvironment").night_energy) and sun.light_energy < game.get_node("DayNightEnvironment").day_energy, "night updates environment lighting")
	clock.advance(300.0)
	check(clock.current_hour == 0 and clock.current_day == 1, "midnight stays in survival Day 1")
	clock.advance(300.0)
	check(clock.current_hour == 6 and clock.current_day == 2 and dawn_events == 1, "dawn increments day exactly once")
	check(is_equal_approx(sun.light_energy, 1.2), "dawn restores daylight")
	clock.advance(0.0)
	check(dawn_events == 1, "zero delta does not repeat transition")
	clock.time_scale = 20.0
	clock.advance(30.0)
	check(clock.current_hour == 18 and clock.current_day == 2, "debug x20 reaches half-day in 30 seconds")
	clock.paused = true
	clock.advance(100.0)
	check(clock.current_hour == 18, "pause stops clock advance")
	clock.paused = false
	clock.seek(1, 6)
	dawn_events = 0
	night_events = 0
	clock.advance_game_minutes(2880.0)
	check(clock.current_day == 3 and dawn_events == 2 and night_events == 2, "large skips preserve every dawn and dusk event")
	clock.advance_game_minutes(-10000.0)
	check(clock.current_day == 1 and clock.current_hour == 6, "debug rewind clamps to start")
	clock.time_scale = 1.0
	dawn_events = 0
	night_events = 0
	for _tick in 72000:
		clock.advance(1.0 / 60.0)
	check(clock.current_day == 2 and clock.current_hour == 6 and dawn_events == 1 and night_events == 1, "fractional frame steps complete a full day without duplicate transitions")
	print("STAGE_4_CLOCK_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
