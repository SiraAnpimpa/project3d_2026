extends "res://tests/phase_5_weapon_test.gd"

var game: Node3D
var waves: NightWaveManager
var player: PlayerController


func fresh() -> void:
	if is_instance_valid(game):
		game.queue_free()
		await frames(3)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	waves = game.waves
	player = game.player
	game.clock.set_process(false)
	game.debug_controls.set_active(false)
	# Modern map registration is asynchronous; wait for the actual baked route
	# before testing spawn timing, rather than assuming a fixed import duration.
	var map := game.get_world_3d().navigation_map
	var farm_point: Vector3 = game.get_node("MainWorld/FarmArea/Plot01").global_position
	for _tick in 600:
		if NavigationServer3D.map_get_path(map, player.global_position, farm_point, true).size() >= 2: break
		await frames(1)
	check(NavigationServer3D.map_get_path(map, player.global_position, farm_point, true).size() >= 2, "navigation is synchronized before lifecycle fixture")


func run() -> void:
	root.size = Vector2i(1280, 720)
	await fresh()
	check(waves.state == NightWaveManager.State.DAY and waves.remaining_zombies == 0, "06:00 starts in DAY with no wave")
	check(not game.rest.request_rest(player), "daytime rest is rejected")
	game.debug_controls.execute(&"debug_start_night")
	check(game.clock.is_daytime, "disabled debug cannot skip to night")
	game.clock.seek(1, 17, 50)
	game.clock.advance(8.34)
	check(waves.state == NightWaveManager.State.ACTIVE and game.clock.is_nighttime, "clock crosses 18:00 and automatically begins one wave")
	check(game.gameplay_mode.is_farming(), "night does not force Combat mode")
	game.clock.night_started.emit(1)
	for _tick in 180:
		await frames(1)
		if waves.spawned_zombies > 0: break
	check(waves.total_zombies == 6 and waves.spawned_zombies == 1 and waves.remaining_zombies == 6, "duplicate night event does not duplicate spawns; count includes pending")
	check(not game.rest.request_rest(player), "active wave blocks rest")
	var first: NormalZombie = waves.alive.values()[0]
	check(first.position.distance_to(player.position) >= waves.data.minimum_spawn_distance and first.pursue_target, "wave spawn respects minimum distance and pursues beyond local detection")
	first.health.take_damage(100)
	check(waves.alive.is_empty() and waves.remaining_zombies == 5 and waves.state == NightWaveManager.State.ACTIVE, "zero alive cannot clear while five are pending")
	await capture("phase7_pending")
	var clears := [0]
	waves.wave_cleared.connect(func() -> void: clears[0] += 1)
	var positions: Array[Vector3] = [first.position]
	for _i in 5:
		await frames(122)
		for enemy in waves.alive.values():
			positions.append(enemy.position)
			enemy.health.take_damage(100)
	check(positions.size() == 6 and positions[0].distance_to(positions[1]) > 10, "wave distributes six spawns across different directions")
	check(waves.state == NightWaveManager.State.CLEARED and clears[0] == 1 and waves.remaining_zombies == 0, "all spawned and dead emits clear exactly once")
	check(game.hud._wave_label.text == "Area cleared" and game.hud._night_copy.text.contains("Cabin"), "clear HUD advertises cabin skip")
	await capture("phase7_cleared")
	# Plant near the end of the night so the rest time skip is the growth source.
	game.clock.seek(1, 22, 0)
	var plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
	player.position = plot.global_position + Vector3(0, 0.05, 0.9)
	await frames(6)
	key(KEY_E)
	check(plot.state == FarmPlot.State.PLANTED, "plant exists before sleep time skip")
	player.position = game.get_node("MainWorld/Bed").global_position + Vector3(0, 0.25, 1.35)
	await frames(6)
	player.health.take_damage(35)
	player.stamina.drain(50)
	key(KEY_Q)
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(5)
	var days := [0]
	game.clock.new_day_started.connect(func(_day: int) -> void: days[0] += 1)
	key(KEY_E)
	check(game.rest.is_resting and paused and not player.camera_rig.is_aiming and not player.camera_rig.can_control(), "E at bed begins rest and locks aim/control")
	check(not game.rest.request_rest(player) and not game.weapons.try_fire(), "rest cannot repeat and firing is blocked")
	await capture("phase7_rest")
	await frames(30)
	check(game.clock.current_day == 2 and game.clock.current_hour == 6 and game.clock.current_minute == 0 and days[0] == 1, "rest advances to Day 2 06:00 exactly once")
	check(player.health.current_hp == 100 and player.stamina.current_stamina == 100 and not paused and player.camera_rig.can_control(), "rest fully restores existing stats and returns controls")
	check(waves.state == NightWaveManager.State.DAY and waves.tracked.is_empty() and waves.remaining_zombies == 0, "morning resets wave and corpse references")
	check(plot.state == FarmPlot.State.READY, "sleep advances plant timestamp growth without resetting farm")
	await capture("phase7_morning")
	mouse(MOUSE_BUTTON_RIGHT, false)
	# Unfinished night ends without healing; ensure no delayed melee or false clear.
	await fresh()
	game.clock.skip_to_night()
	await frames(130)
	var survivors := waves.alive.values()
	var no_rest_clears := [0]
	waves.wave_cleared.connect(func() -> void: no_rest_clears[0] += 1)
	player.health.take_damage(40)
	player.stamina.drain(60)
	game.clock.seek(1, 5, 50)
	game.clock.advance(8.34)
	check(game.clock.current_day == 2 and waves.state == NightWaveManager.State.DAY, "natural dawn enters Day 2 with unfinished wave")
	check(player.health.current_hp == 60 and player.stamina.current_stamina == 40, "no-rest dawn does not restore HP or stamina")
	check(waves.remaining_zombies == 0 and waves.tracked.is_empty() and no_rest_clears[0] == 0, "dawn cleanup resets tracking without awarding clear")
	for enemy in survivors:
		check(not enemy.is_physics_processing() and enemy.collision_layer == 0, "dawn disables AI and collision before deferred removal")
	await frames(3)
	await capture("phase7_no_rest")
	check(not game.rest.request_rest(player), "dawn cannot retroactively rest")
	# Unexpected deletion returns an enemy to pending rather than counting it as a kill.
	await fresh()
	game.clock.skip_to_night()
	for _tick in 180:
		await frames(1)
		if waves.spawned_zombies > 0: break
	first = waves.alive.values()[0]
	first.queue_free()
	await frames(3)
	check(waves.remaining_zombies == 6 and waves.spawned_zombies == 0 and waves.state == NightWaveManager.State.ACTIVE, "unexpected removal becomes pending replacement")
	# If every marker is blocked, retry safely without losing pending count.
	var blockers: Array[StaticBody3D] = []
	for marker in waves.spawn_points.get_children():
		blockers.append(wall_at(marker.global_position + Vector3.UP, Vector3(3, 2, 3)))
	await frames(130)
	check(waves.spawned_zombies == 0 and waves.remaining_zombies == 6, "blocked spawn points retain pending enemies")
	for blocker in blockers: blocker.queue_free()
	await frames(130)
	check(waves.spawned_zombies > 0, "unblocked points retry successfully")
	# Death terminates pending spawning and blocks rest until a fresh scene restart.
	player.health.take_damage(100)
	var spawned_before := waves.spawned_zombies
	await frames(130)
	check(waves.state == NightWaveManager.State.GAME_OVER and waves.spawned_zombies == spawned_before and waves.tracked.is_empty() and game.clock.paused, "game over stops wave spawning and clock and cleans enemies")
	check(not game.rest.request_rest(player) and game.hud.death_panel.visible, "dead player cannot rest and sees game over")
	key(KEY_R)
	await frames(20)
	game = current_scene
	check(game.clock.current_day == 1 and game.clock.current_hour == 6 and game.player.health.current_hp == 100 and game.player.stamina.current_stamina == 100 and game.waves.state == NightWaveManager.State.DAY and game.waves.tracked.is_empty(), "R restart resets day time stats wave and zombies")
	check(game.get_node("MainWorld/FarmArea/Plot01").state == FarmPlot.State.EMPTY, "restart creates fresh farm state")
	# Rest interruption cannot resurrect a player or leave the tree paused.
	await fresh()
	game.clock.skip_to_night()
	for _i in 6:
		await frames(122)
		waves.debug_kill_active()
	check(game.rest.request_rest(player), "cleared wave accepts rest for interruption test")
	player.health.take_damage(100)
	await frames(30)
	check(player.health.is_dead and not paused and not game.rest.is_resting and game.clock.current_day == 1, "death during rest cancels recovery and releases pause without advancing day")
	# A completed night is not replayed by repeated seek/event delivery.
	await fresh()
	game.clock.skip_to_night()
	game.clock.advance_game_minutes(720)
	game.clock.seek(1, 18)
	await frames(3)
	check(waves.state == NightWaveManager.State.DAY and waves.tracked.is_empty(), "backward debug seek does not replay an already started night")
	game.clock.seek(2, 18)
	await frames(3)
	check(waves.state == NightWaveManager.State.ACTIVE and waves.total_zombies == 7, "Day 2 uses progression wave with seven normal zombies")
	var invalid := waves.data.duplicate() as NightWaveData
	invalid.spawn_interval = 0
	check(not invalid.validation_errors().is_empty(), "invalid wave interval is rejected")
	print("PHASE_7_LIFECYCLE_RESULT failures=", failures)
	quit(1 if failures else 0)
