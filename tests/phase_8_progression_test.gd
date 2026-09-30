extends "res://tests/phase_7_lifecycle_test.gd"

func run() -> void:
	root.size = Vector2i(1280, 720)
	await fresh()
	var progression: ProgressionManager = game.progression
	check(progression.data.validation_errors(game.catalog, game.recipe_book).is_empty(), "all ten configs validate identities, wave data and unique unlocks")
	var invalid := progression.data.duplicate() as DayProgressionData
	invalid.days = progression.data.days.duplicate()
	invalid.days.remove_at(5)
	check("Missing DayConfig for Day 6" in invalid.validation_errors(game.catalog, game.recipe_book), "missing config has explicit diagnostic")
	check(game.inventory.get_item_amount(&"seed_lead") == 3 and progression.unlocked_seed_ids.size() == 5, "Day 1 existing starter seeds are not awarded twice")
	check(not game.crafting_system.is_unlocked(game.recipe_book.get_recipe(&"fire_ammo")), "special recipe starts locked independently of materials")
	game.inventory.add_item(game.catalog.get_item(&"seed_fire_pepper"), 1)
	check(not game.inventory.select_seed(&"seed_fire_pepper"), "owned locked seed cannot be selected")
	game.inventory.remove_item(&"seed_fire_pepper", 1)
	var notifications := [0]
	progression.feedback.connect(func(_message: String) -> void: notifications[0] += 1)
	for day in [1, 3, 5, 7, 10]:
		game.debug_controls.set_active(true)
		game.debug_controls.execute(StringName("debug_set_day_%d" % day))
		await frames(3)
		check(game.clock.current_day == day and progression.current.day == day and game.hud.day_label.text.contains("%d / 10" % day), "debug day %d updates config and HUD" % day)
		if day in [3, 7, 10]: await capture("phase8_day%d" % day)
		var before: int = game.inventory.get_item_amount(&"seed_lead")
		var notices: int = notifications[0]
		game.clock.day_started.emit(day)
		await frames(3)
		check(game.inventory.get_item_amount(&"seed_lead") == before and notifications[0] == notices, "Day %d duplicate event has no reward/notification duplication" % day)
		game.clock.skip_to_night()
		var expected := {}
		for scene in waves.data.spawn_queue():
			expected[scene.resource_path] = int(expected.get(scene.resource_path, 0)) + 1
		var observed := {}
		for _tick in 100:
			waves._spawn_wait = 0 # Accelerate spawn cadence only for exact composition coverage.
			await frames(2)
			for enemy in waves.alive.values():
				observed[enemy.scene_file_path] = int(observed.get(enemy.scene_file_path, 0)) + 1
				enemy.health.take_damage(enemy.health.max_hp)
			if waves.state == NightWaveManager.State.CLEARED: break
		check(observed == expected and waves.state == NightWaveManager.State.CLEARED, "Day %d spawns exact mixed composition and clears after pending is empty" % day)
		if day == 10:
			check(waves.state != NightWaveManager.State.GAME_COMPLETED, "final clear waits for dawn/rest rather than instant victory")
			check(game.rest.request_rest(player), "final clear allows rest")
			await frames(30)
			check(waves.state == NightWaveManager.State.GAME_COMPLETED and not paused and not player.camera_rig.can_control(), "final rest completes safely and keeps gameplay locked")
			await capture("phase8_completed_rest")
	# New farming resources use existing selection, growth, harvest and crafting transactions.
	await fresh()
	for row in [[3, "fire_pepper", "fire_ammo"], [5, "ice_plant", "ice_ammo"], [7, "poison_plant", "poison_ammo"]]:
		waves.debug_set_day(row[0])
		var seed_id := StringName("seed_" + row[1])
		var plant: PlantData = game.catalog.get_plant(StringName(row[1]))
		check(game.inventory.get_item_amount(seed_id) == 3 and game.inventory.select_seed(seed_id), "new seed reward selectable: " + row[1])
		var plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
		plot.interact(player)
		game.clock.advance_game_minutes(plant.growth_minutes + 1)
		check(plot.state == FarmPlot.State.READY, "magical plant grows: " + row[1])
		plot.interact(player)
		check(game.inventory.get_item_amount(plant.harvest_item.id) == plant.harvest_amount, "magical harvest uses correct material: " + row[1])
		game.inventory.add_item(game.catalog.get_item(&"paper"), 1)
		game.inventory.add_item(game.catalog.get_item(&"copper"), 1)
		var recipe: CraftRecipe = game.recipe_book.get_recipe(StringName(row[2]))
		game.crafting_ui.set_open(true)
		game.crafting_ui._select_recipe(recipe)
		await frames(3)
		check(not game.crafting_ui.craft_button.disabled, "unlocked recipe UI enables craft: " + row[2])
		await click_button(game.crafting_ui.craft_button)
		check(game.inventory.get_item_amount(StringName(row[2])) == 10, "workbench produces special ammo: " + row[2])
		await capture("phase8_" + row[2])
		game.crafting_ui.set_open(false)
	# Full bags retain earned rewards and grant them once when space opens.
	await fresh()
	game.debug_controls.set_active(true)
	game.debug_controls.execute(&"debug_fill_inventory")
	waves.debug_set_day(3)
	check(game.progression.is_seed_unlocked(&"seed_fire_pepper") and game.progression.pending_rewards.has(&"seed_fire_pepper") and game.inventory.get_item_amount(&"seed_fire_pepper") == 0, "full bag keeps unlock separate from owned quantity and queues reward")
	game.inventory.clear()
	await frames(2)
	check(game.inventory.get_item_amount(&"seed_fire_pepper") == 3 and game.progression.pending_rewards.is_empty(), "freeing bag claims queued rewards atomically once")
	game.progression.apply_day(3)
	check(game.inventory.get_item_amount(&"seed_fire_pepper") == 3, "queued delivery cannot duplicate on repeated day")
	game.debug_controls.execute(&"debug_unlock_all")
	var owned_poison: int = game.inventory.get_item_amount(&"seed_poison_plant")
	game.debug_controls.execute(&"debug_reset_unlocks")
	check(not game.progression.is_seed_unlocked(&"seed_poison_plant") and game.inventory.get_item_amount(&"seed_poison_plant") == owned_poison, "debug reset separates unlocks from owned seeds")
	waves.debug_set_day(7)
	check(game.progression.is_seed_unlocked(&"seed_poison_plant") and game.inventory.get_item_amount(&"seed_poison_plant") == owned_poison, "reaching day after debug reset restores unlock without duplicate starter grant")
	# Active cap keeps pending types; unexpected removal preserves the exact type.
	waves.debug_set_day(10)
	game.clock.skip_to_night()
	var relocated := {}
	for _tick in 12:
		waves._spawn_wait = 0
		await frames(2)
		for enemy in waves.alive.values():
			if relocated.has(enemy.get_instance_id()): continue
			var index := relocated.size()
			relocated[enemy.get_instance_id()] = true
			enemy.position = Vector3(-12 + (index % 4) * 3, 0.05, 10 + (index / 4) * 3)
			enemy.set_physics_process(false)
	check(waves.alive.size() == 12 and waves.pending.size() == 12 and waves.remaining_zombies == 24, "final wave caps twelve alive while counting twelve pending")
	var tank: NormalZombie
	for enemy in waves.alive.values():
		if enemy.data.zombie_id == &"tank_zombie": tank = enemy
	check(tank != null, "mixed queue includes tank before normal batch ends")
	if tank != null:
		var scene_path := tank.scene_file_path
		tank.queue_free()
		await frames(2)
		check(waves.pending[0].resource_path == scene_path and waves.remaining_zombies == 24, "unexpected tank deletion returns same variant to pending")
	# Natural final dawn is victory even with active and pending enemies; no healing.
	player.health.take_damage(35)
	game.clock.skip_to_day()
	await frames(3)
	check(waves.state == NightWaveManager.State.GAME_COMPLETED and player.health.current_hp == 65 and waves.tracked.is_empty() and waves.pending.is_empty(), "unfinished final wave dawn wins, cleans up and does not heal")
	var elapsed: float = game.clock.get_elapsed_minutes()
	game.clock.set_process(true)
	Input.action_press("move_forward")
	key(KEY_TAB)
	key(KEY_ESCAPE)
	await frames(30)
	Input.action_release("move_forward")
	check(game.clock.get_elapsed_minutes() == elapsed and not game.inventory_ui.is_open and not game.pause_menu.is_open and not game.weapons.try_fire(), "completion stops clock and gameplay menus/fire")
	await capture("phase8_completed_dawn")
	key(KEY_R)
	await frames(20)
	game = current_scene
	check(game.clock.current_day == 1 and game.progression.unlocked_seed_ids.size() == 5 and game.inventory.get_item_amount(&"seed_lead") == 3, "victory restart creates fresh Day 1 progression and rewards")
	# Genuine clock-driven accelerated sequence, no day seeks, kills or healing.
	await fresh()
	game.inventory.select_seed(&"seed_lead")
	var persistent_plot: FarmPlot = game.get_node("MainWorld/FarmArea/Plot01")
	persistent_plot.interact(player)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 10)
	key(KEY_Q)
	key(KEY_R)
	await frames(95)
	var initial_magazine: int = game.weapons.current.current_magazine
	var day_events: Array[int] = []
	game.clock.new_day_started.connect(func(day: int) -> void: day_events.append(day))
	game.clock.half_day_real_seconds = 3
	game.clock.set_process(true)
	var max_tracked := 0
	var daytime_nodes := {}
	for _tick in 4000:
		await frames(1)
		max_tracked = maxi(max_tracked, waves.tracked.size())
		if game.clock.is_daytime and game.clock.current_hour == 8:
			daytime_nodes[game.clock.current_day] = get_node_count()
		if waves.state == NightWaveManager.State.GAME_COMPLETED: break
	check(waves.state == NightWaveManager.State.GAME_COMPLETED and day_events == range(2, 12), "accelerated natural Day 1 through Night 10 completes with exactly ten dawns")
	check(game.progression.reached_days.size() == 10 and game.progression.unlocked_seed_ids.size() == 8 and game.progression.unlocked_recipe_ids.size() == 6, "ten-day registry has no duplicate grants or Day 11 content")
	check(waves.tracked.is_empty() and waves.pending.is_empty() and waves.alive.is_empty(), "long run has no stale enemy or pending references")
	check(persistent_plot.state == FarmPlot.State.READY and game.weapons.current.current_magazine == initial_magazine and game.inventory.has_item(&"basic_rifle"), "ten-day transitions preserve crop, magazine and inventory")
	check(daytime_nodes.size() == 10 and int(daytime_nodes[10]) <= int(daytime_nodes[2]) + 5, "daytime node count does not accumulate across ten days")
	print("TEN_DAY_NODES ", daytime_nodes, " memory_bytes=", Performance.get_monitor(Performance.MEMORY_STATIC))
	print("TEN_DAY_RUNTIME max_tracked=", max_tracked, " hp=", player.health.current_hp, " nodes=", get_node_count(), " dawns=", day_events)
	print("PHASE_8_PROGRESSION_RESULT failures=", failures)
	quit(1 if failures else 0)
