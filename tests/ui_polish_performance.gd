extends "res://tests/phase_10_performance_test.gd"

func run() -> void:
	root.size=Vector2i(1280,720)
	set_meta("normal_play",true)
	game=load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene=game
	await frames(30)
	game.clock.paused=true
	await sample("hud_720p")
	game.inventory_ui.set_open(true)
	await sample("inventory_720p")
	game.inventory_ui.set_open(false)
	game.crafting_ui.set_open(true)
	await sample("crafting_720p")
	game.crafting_ui.set_open(false)
	var file:=FileAccess.open("user://ui_polish_performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(samples,"  "))
	print("UI_POLISH_PERFORMANCE_RESULT failures=",failures)
	quit(1 if failures else 0)
