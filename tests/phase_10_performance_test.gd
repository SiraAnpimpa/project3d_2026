extends "res://tests/phase_3_integration_test.gd"

var game: Node3D
var samples: Array = []

func sample(label: String) -> void:
	await frames(120)
	var times: Array[float] = []
	var physics := 0.0
	var process := 0.0
	var nav := 0.0
	var last := Time.get_ticks_usec()
	for tick in 600:
		await process_frame
		var now := Time.get_ticks_usec()
		times.append((now-last)/1000.0)
		last = now
		physics += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000
		process += Performance.get_monitor(Performance.TIME_PROCESS)*1000
		nav += Performance.get_monitor(Performance.TIME_NAVIGATION_PROCESS)*1000
	times.sort()
	var total := 0.0
	for t in times: total += t
	var data := {"scenario":label, "frames":600, "mean_ms":total/600, "p95_ms":times[569], "p99_ms":times[593], "max_ms":times[-1], "physics_ms":physics/600, "process_ms":process/600, "navigation_ms":nav/600, "static_memory":Performance.get_monitor(Performance.MEMORY_STATIC), "nodes":get_node_count(), "draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "alive":game.waves.alive.size()}
	samples.append(data)
	print("PERFORMANCE_SAMPLE ", JSON.stringify(data))

func run() -> void:
	root.size = Vector2i(1280,720)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	game.debug_controls.set_active(false)
	game.clock.paused = true
	await sample("day_720p")
	# Synthetic stress only; not balance evidence. Ordinary cadence, 12 living cap.
	game.player.health.damage_enabled = false
	game.waves.debug_set_day(10)
	game.clock.seek(10,18,0)
	game.clock.paused = true
	await frames(1000)
	await sample("final_night_12_alive_720p")
	root.size = Vector2i(1920,1080)
	await sample("final_night_12_alive_1080p")
	game.clock.seek(11,6,0)
	await frames(520)
	await sample("ending_1080p")
	check(game.presentation.ending_finished and game.waves.tracked.is_empty(), "stress wave cleans up for ending")
	var file := FileAccess.open("user://phase10_performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(samples,"  "))
	game.queue_free()
	await frames(5)
	print("PHASE_10_PERFORMANCE_RESULT failures=", failures)
	quit(1 if failures else 0)
