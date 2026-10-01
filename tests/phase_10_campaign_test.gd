extends "res://tests/phase_7_full_day_test.gd"

# Automated skilled player: normal clock, movement, E interactions, UI crafting,
# finite ammunition, real reload/hits and ordinary damage. No state grants/seeks.
var records: Array = []

func run() -> void:
	root.size = Vector2i(1280, 720)
	await new_game()
	if not OS.is_debug_build():
		key(KEY_F1)
		check(not game.debug_controls.active and game.get_node_or_null("MainWorld/TargetDummy") == null, "release blocks F1 cheats and removes dummy")
	for day in range(1, 11):
		check(game.clock.current_day == day, "campaign dawn %d" % day)
		if not game.gameplay_mode.is_farming(): key(KEY_Q)
		var per_type: int = 3 if day == 1 else game.progression.data.get_day(day).supply_quantity
		var seeds: Array[StringName] = []
		for id in [&"seed_lead", &"seed_paper", &"seed_copper"]:
			for count in per_type: seeds.append(id)
		for batch_start in range(0, seeds.size(), 12):
			var count := mini(12, seeds.size() - batch_start)
			for i in count:
				var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(i)
				select_seed(seeds[batch_start + i])
				await walk(plot.position + Vector3(0, 0, 0.9))
				key(KEY_E)
				check(plot.state == FarmPlot.State.PLANTED, "campaign plants finite seed")
			await frames(2500)
			for i in count:
				var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(i)
				await walk(plot.position + Vector3(0, 0, 0.9))
				key(KEY_E)
				check(plot.state == FarmPlot.State.EMPTY, "campaign harvests naturally")
		await walk(game.get_node("MainWorld/Workbench").position + Vector3(0, 0, 1.1))
		key(KEY_E)
		await frames(3)
		var recipe: CraftRecipe = game.recipe_book.get_recipe(&"basic_ammo")
		while game.crafting_system.failure_reason(recipe).is_empty():
			click_button(game.crafting_ui.craft_button)
			await frames(3)
		key(KEY_ESCAPE)
		await walk(Vector3(10, 0, 10))
		key(KEY_Q)
		key(KEY_R)
		await frames(95)
		var resources_before := resources_snapshot()
		var before: int = game.weapons.reserve_ammo() + game.weapons.current.current_magazine
		var shots_before: int = game.weapons.shots_fired
		var hp_before: float = player.health.current_hp
		while game.clock.is_daytime: await frames(30)
		await frames(12)
		while game.waves.state == NightWaveManager.State.ACTIVE and not player.health.is_dead:
			var closest: NormalZombie
			for enemy in game.waves.alive.values():
				if closest == null or enemy.position.distance_to(player.position) < closest.position.distance_to(player.position): closest = enemy
			if closest != null:
				var retreat: bool = closest.position.distance_to(player.position) < 3.5 or game.weapons.current.is_reloading
				if retreat:
					mouse(MOUSE_BUTTON_RIGHT, false)
					retreat_from_threats()
					if game.weapons.current.current_magazine == 0: key(KEY_R)
					await frames(1)
					continue
				stop_walk()
				mouse(MOUSE_BUTTON_RIGHT, true)
				aim_at(player, closest.global_position + Vector3.UP)
				if game.weapons.current.current_magazine == 0: key(KEY_R)
				elif player.aim_ray.hit_collider == closest:
					mouse(MOUSE_BUTTON_LEFT, true)
					mouse(MOUSE_BUTTON_LEFT, false)
			await frames(1)
		mouse(MOUSE_BUTTON_RIGHT, false)
		stop_walk()
		var record := {"resources_before":resources_before, "resources_after":resources_snapshot(), "zombies":game.waves.total_zombies, "day":day, "ammo_before":before, "shots":game.weapons.shots_fired-shots_before, "damage":hp_before-player.health.current_hp, "hp":player.health.current_hp, "cleared":game.waves.state==NightWaveManager.State.CLEARED, "reserve":game.weapons.reserve_ammo(), "magazine":game.weapons.current.current_magazine, "medicine":game.inventory.get_item_amount(&"basic_medicine"), "weapon":"Basic Rifle", "nodes":get_node_count()}
		records.append(record)
		print("CAMPAIGN_DAY ", JSON.stringify(record))
		check(not player.health.is_dead and (game.waves.state == NightWaveManager.State.CLEARED or game.clock.current_day == day+1), "finite resource campaign survives Night %d" % day)
		if player.health.is_dead or failures > 0: break
		if game.clock.current_day == day+1: continue
		await walk(Vector3(-9, 0, -2.5))
		await walk(Vector3(-9, 0, -6.5))
		key(KEY_E)
		await frames(35)
		if failures > 0: break
	if failures == 0:
		await frames(500)
		check(game.presentation.ending_finished, "full finite-resource campaign reaches rescue ending")
	var file := FileAccess.open("user://phase10_campaign.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(records, "  "))
	print("PHASE_10_CAMPAIGN_RESULT failures=", failures)
	game.queue_free()
	await frames(5)
	quit(1 if failures else 0)



func walk(point: Vector3, sprint: bool = false) -> void:
	var map := player.get_world_3d().navigation_map
	var path := NavigationServer3D.map_get_path(map, player.global_position, point, true)
	for waypoint in path:
		for tick in 1500:
			if Vector2(player.position.x-waypoint.x, player.position.z-waypoint.z).length() < 0.3: break
			steer(waypoint, sprint)
			await frames(1)
	stop_walk()
	await frames(12)
	check(Vector2(player.position.x-point.x, player.position.z-point.z).length() < 0.75, "campaign follows walkable route to %s" % point)

func resources_snapshot() -> Dictionary:
	var result := {}
	for id in [&"lead", &"paper", &"copper", &"seed_lead", &"seed_paper", &"seed_copper", &"small_herb"]:
		result[String(id)] = game.inventory.get_item_amount(id)
	return result

func retreat_from_threats() -> void:
	# Choose a locally clear escape direction instead of blindly running toward
	# a fixed corner that may contain an attacker. Movement still uses input.
	var best := player.position
	var best_score := -INF
	for i in 16:
		var angle := TAU * float(i) / 16.0
		var point := player.position + Vector3(cos(angle),0,sin(angle))*3.0
		if absf(point.x)>21 or absf(point.z)>21: continue
		var query := PhysicsRayQueryParameters3D.create(player.position+Vector3.UP, point+Vector3.UP, 1, [player.get_rid()])
		if not player.get_world_3d().direct_space_state.intersect_ray(query).is_empty(): continue
		var score := INF
		for enemy in game.waves.alive.values(): score = minf(score, point.distance_to(enemy.position))
		if score > best_score:
			best_score = score
			best = point
	steer(best,true)
