extends "res://tests/phase_5_weapon_test.gd"

var game: Node3D
var player: PlayerController


func new_game() -> void:
	if is_instance_valid(game):
		game.queue_free()
		await frames(3)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(12)
	player = game.player
	game.debug_controls.set_active(false)
	var map := game.get_world_3d().navigation_map
	var first_plot: Vector3 = game.get_node("MainWorld/FarmArea").get_child(0).position+Vector3(0,0,0.9)
	for tick in 600:
		if NavigationServer3D.map_get_path(map,player.position,first_plot,true).size() >= 2: break
		await frames(1)
	check(NavigationServer3D.map_get_path(map,player.position,first_plot,true).size() >= 2,"baked map has a synchronized farm path before starting the input walk")


func steer(point: Vector3, sprint: bool = false) -> void:
	var direction := point - player.global_position
	player.camera_rig.rotation.y = atan2(-direction.x, -direction.z)
	Input.action_press("move_forward")
	if sprint: Input.action_press("sprint")
	else: Input.action_release("sprint")


func stop_walk() -> void:
	Input.action_release("move_forward")
	Input.action_release("sprint")


func walk(point: Vector3, sprint: bool = false) -> void:
	var map := game.get_world_3d().navigation_map
	var path := NavigationServer3D.map_get_path(map,player.position,point,true)
	check(path.size() > 0,"baked navigation has a route to the interaction point")
	for waypoint in path:
		for _i in 1000:
			if Vector2(player.position.x-waypoint.x,player.position.z-waypoint.z).length() < 0.2: break
			steer(waypoint,sprint)
			await frames(1)
		stop_walk()
		await frames(8)
	check(Vector2(player.position.x-point.x,player.position.z-point.z).length() < 0.7,"walked to %s through player input" % point)


func select_seed(id: StringName) -> void:
	for _i in 10:
		if game.inventory.selected_seed_id == id: break
		mouse(MOUSE_BUTTON_WHEEL_DOWN, true)
		mouse(MOUSE_BUTTON_WHEEL_DOWN, false)
	check(game.inventory.selected_seed_id == id, "wheel selects %s" % id)


func wait_for_night() -> void:
	while game.clock.is_daytime: await frames(30)


func run() -> void:
	root.size = Vector2i(1280, 720)
	var start_ticks := Time.get_ticks_msec()
	await new_game()
	check(game.clock.current_day == 1 and game.clock.current_hour == 6, "full loop begins Day 1 06:00 with production clock")
	var seeds := [&"seed_lead", &"seed_lead", &"seed_paper", &"seed_paper", &"seed_copper", &"seed_copper", &"seed_small_herb", &"seed_small_herb"]
	for i in seeds.size():
		var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(i)
		select_seed(seeds[i])
		await walk(plot.position + Vector3(0, 0, 0.9))
		key(KEY_E)
		check(plot.state == FarmPlot.State.PLANTED, "E plants real starter seed %d" % i)
	# Natural timestamps, no clock seek/advance, time-scale change or debug growth.
	await frames(2500)
	for i in seeds.size():
		var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(i)
		await walk(plot.position + Vector3(0, 0, 0.9))
		key(KEY_E)
		check(plot.state == FarmPlot.State.EMPTY, "E harvests naturally grown crop %d" % i)
	await walk(game.get_node("MainWorld/Workbench").position + Vector3(0, 0, 1.1))
	key(KEY_E)
	await frames(3)
	check(game.crafting_ui.is_open, "E opens workbench after harvest")
	if not game.crafting_ui.is_open:
		print("BEAUTIFICATION_FULL_DAY_RESULT failures=", failures)
		quit(1)
		return
	for _batch in 4:
		click_button(game.crafting_ui.craft_button)
		await frames(3)
	for recipe in game.crafting_ui._buttons:
		if recipe.recipe_id == &"basic_medicine":
			click_button(game.crafting_ui._buttons[recipe])
			await frames(3)
	click_button(game.crafting_ui.craft_button)
	await frames(3)
	print("CRAFT_RESULT ammo=", game.inventory.get_item_amount(&"basic_ammo"), " medicine=", game.inventory.get_item_amount(&"basic_medicine"))
	check(game.inventory.get_item_amount(&"basic_ammo") == 40 and game.inventory.get_item_amount(&"basic_medicine") == 1, "harvested materials craft forty ammo and one medicine without grants")
	key(KEY_ESCAPE)
	await walk(Vector3(10, 0, 10))
	key(KEY_Q)
	key(KEY_R)
	await frames(95)
	check(game.weapons.current.current_magazine == 10 and game.weapons.reserve_ammo() == 30, "prepare rifle using only crafted ammunition")
	await wait_for_night()
	check(game.waves.state == NightWaveManager.State.ACTIVE and not game.debug_controls.active, "18:00 starts production wave with debug disabled")
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(12)
	var combat_ticks := 0
	while game.waves.state == NightWaveManager.State.ACTIVE and not player.health.is_dead and combat_ticks < 6000:
		combat_ticks += 1
		var closest: NormalZombie
		for enemy in game.waves.alive.values():
			if closest == null or enemy.position.distance_to(player.position) < closest.position.distance_to(player.position): closest = enemy
		if closest != null:
			aim_at(player, closest.global_position + Vector3.UP)
			# Observe one real melee hit before fighting; no healing cheats.
			if player.health.current_hp < player.health.max_hp and player.aim_ray.hit_collider == closest:
				if game.weapons.current.current_magazine == 0:
					key(KEY_R)
				else:
					mouse(MOUSE_BUTTON_LEFT, true)
					mouse(MOUSE_BUTTON_LEFT, false)
		await frames(1)
	mouse(MOUSE_BUTTON_RIGHT, false)
	check(not player.health.is_dead and game.waves.state == NightWaveManager.State.CLEARED, "six production zombies die through actual rifle fire without healing or kill cheats")
	if player.health.is_dead or game.waves.state != NightWaveManager.State.CLEARED:
		print("FULL_DAY_DIAGNOSTIC hp=", player.health.current_hp, " remaining=", game.waves.remaining_zombies, " magazine=", game.weapons.current.current_magazine, " reserve=", game.weapons.reserve_ammo())
		for enemy in game.waves.alive.values(): print("FULL_DAY_ENEMY hp=",enemy.health.current_hp," position=",enemy.position," state=",enemy.state)
		print("BEAUTIFICATION_FULL_DAY_RESULT failures=", failures)
		quit(1)
		return
	check(player.health.current_hp < 100, "wave attack actually reduced player health")
	await walk(Vector3(-13.5, 0, -3))
	await walk(game.get_node("MainWorld/Bed").position+Vector3(1.0,0.02,1.5),true)
	var before_rest_hp := player.health.current_hp
	key(KEY_E)
	check(game.rest.is_resting, "real E bed interaction begins earned rest")
	await frames(30)
	check(game.clock.current_day == 2 and game.clock.current_hour == 6 and player.health.current_hp == 100 and player.stamina.current_stamina == 100 and before_rest_hp < 100, "complete uncheated Day 1 farming crafting combat rest reaches healthy Day 2")
	print("FULL_DAY_EARLY_CLEAR hp_before_rest=", before_rest_hp, " shots=", game.weapons.shots_fired, " medicine=", game.inventory.get_item_amount(&"basic_medicine"))
	# Second complete day: unprepared, receives damage and kites until natural dawn.
	await new_game()
	await walk(Vector3(14, 0, 14))
	await wait_for_night()
	while player.health.current_hp == 100 and not player.health.is_dead: await frames(1)
	# Use the open combat field; the old loop now crosses the house and forest camp.
	var corners := [RuralTerrain.ground_point(16,20),RuralTerrain.ground_point(-3,20),RuralTerrain.ground_point(-3,-3),RuralTerrain.ground_point(16,-3)]
	var corner := 0
	while game.clock.current_day == 1 and not player.health.is_dead:
		if player.position.distance_to(corners[corner]) < 0.8: corner = (corner + 1) % corners.size()
		var near_dawn: bool = game.clock.current_hour == 5 and game.clock.current_minute == 59
		steer(corners[corner], near_dawn)
		await frames(1)
	stop_walk()
	check(not player.health.is_dead and game.clock.current_day == 2 and game.waves.state == NightWaveManager.State.DAY, "bad night survives by running until natural Day 2 dawn")
	check(player.health.current_hp < 100 and player.stamina.current_stamina < 100, "bad night retains damaged HP and spent sprint stamina without rest restoration")
	check(game.waves.tracked.is_empty() and game.waves.remaining_zombies == 0 and not game.rest.is_resting, "bad-night dawn removes remaining wave without sleep")
	print("FULL_DAY_BAD_NIGHT hp=", player.health.current_hp, " stamina=", player.stamina.current_stamina, " day=", game.clock.current_day)
	print("FULL_DAY_RUNTIME wall_seconds=", float(Time.get_ticks_msec() - start_ticks) / 1000.0, " fixed_simulation=true debug_cheats=false")
	print("BEAUTIFICATION_FULL_DAY_RESULT failures=", failures)
	quit(1 if failures else 0)
