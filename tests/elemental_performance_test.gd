extends "res://tests/phase_10_performance_test.gd"
## Identical synthetic full-farm before/after render fixture, not balance evidence.

func run() -> void:
	root.size = Vector2i(1920,1080)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(25)
	game.debug_controls.set_active(false)
	game.clock.paused = true
	var plots := game.get_node("MainWorld/FarmArea").get_children()
	for index in plots.size():
		var plant := load("res://scenes/farming/Plant.tscn").instantiate() as PlantVisual
		plots[index].get_node("PlantAnchor").add_child(plant)
		var data: PlantData=load("res://resources/plants/%s.tres" % ["fire_pepper","ice_plant","poison_plant"][index%3])
		if "--without-vfx" in OS.get_cmdline_user_args():
			data=data.duplicate() as PlantData
			data.ambient_vfx=null
		plant.configure(data)
		plant.set_stage(3)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.position = Vector3(-13.4,2.8,16.5)
	camera.look_at(Vector3(-13.4,0.25,8.5))
	camera.current = true
	await sample("day_full_farm_1080p")
	game.player.health.damage_enabled = false
	game.waves.debug_set_day(10)
	game.clock.seek(10,18,0)
	game.clock.paused = true
	await frames(1000)
	await sample("night_12_alive_full_farm_1080p")
	var out := FileAccess.open(".godot/vfx-performance-%s.json" % ("off" if "--without-vfx" in OS.get_cmdline_user_args() else "on"),FileAccess.WRITE)
	out.store_string(JSON.stringify(samples,"  "))
	print("ELEMENTAL_PERFORMANCE_RESULT failures=",failures)
	quit(1 if failures else 0)
