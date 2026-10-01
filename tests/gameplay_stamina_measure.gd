extends "res://tests/phase_3_integration_test.gd"
## Identical before/after actual-input measurement; no tuning overrides.

func run() -> void:
	root.size = Vector2i(1280,720)
	set_meta("normal_play",true)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	game.clock.paused = true
	game.debug_controls.set_active(false)
	var player: PlayerController = game.player
	player.position = Vector3(0,RuralTerrain.height_at(0,6)+0.03,6)
	player.velocity = Vector3.ZERO
	player.camera_rig.rotation.y = 0
	await frames(20)
	var stamina: StaminaComponent = player.stamina
	stamina.reset()
	await capture("stamina_full")
	Input.action_press("sprint")
	var started := Engine.get_physics_frames()
	var values: Array = []
	for tick in 1200:
		var right := int(tick/90)%2 == 0
		Input.action_release("move_left" if right else "move_right")
		Input.action_press("move_right" if right else "move_left")
		await frames(1)
		values.append({"tick":tick,"stamina":stamina.current_stamina,"sprinting":player.is_sprinting,"grounded":player.is_on_floor(),"hud":game.hud.stamina_bar.value})
		if stamina.exhausted: break
	var duration := float(Engine.get_physics_frames()-started)/60.0
	for action in ["sprint","move_left","move_right"]: Input.action_release(action)
	check(stamina.exhausted and stamina.current_stamina == 0,"actual sprint reaches empty and leaves sprint state")
	var stop := Engine.get_physics_frames()
	await capture("stamina_empty")
	var first_recovery := 0
	var full_recovery := 0
	for tick in 1200:
		await frames(1)
		if first_recovery == 0 and stamina.current_stamina > 0.0001: first_recovery = Engine.get_physics_frames()-stop
		if is_equal_approx(stamina.current_stamina,stamina.max_stamina):
			full_recovery = Engine.get_physics_frames()-stop
			break
	check(first_recovery > 0 and full_recovery > first_recovery,"delayed recovery reaches full without negative/overflow")
	var range_ok := true
	var hud_ok := true
	for row in values:
		range_ok = range_ok and row.stamina >= 0 and row.stamina <= stamina.max_stamina
		hud_ok = hud_ok and absf(row.hud-row.stamina) <= game.hud.stamina_bar.step*0.5+0.001
	check(range_ok and hud_ok,"stamina range and HUD match every sampled physics tick")
	await capture("stamina_recovered")
	var row := {"maximum":stamina.max_stamina,"drain_per_second":stamina.drain_rate,"recovery_per_second":stamina.recovery_rate,"configured_delay_seconds":stamina.recovery_delay,"restart_fraction":stamina.restart_fraction,"walk_speed":player.walk_speed,"sprint_speed":player.sprint_speed,"aim_speed":player.aim_walk_speed,"sprint_duration_seconds":duration,"first_recovery_seconds":first_recovery/60.0,"full_recovery_seconds":full_recovery/60.0,"failures":failures,"trace":values}
	var out := FileAccess.open("user://gameplay_stamina_measure.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(row,"  "))
	print("STAMINA_MEASUREMENT duration=",duration," first_recovery=",first_recovery/60.0," full_recovery=",full_recovery/60.0)
	print("GAMEPLAY_STAMINA_MEASURE_RESULT failures=",failures)
	quit(1 if failures else 0)
