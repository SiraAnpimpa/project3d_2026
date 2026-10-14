extends "res://tests/phase_5_weapon_test.gd"

var game: Node3D
var player: PlayerController

func run() -> void:
	root.size = Vector2i(1280, 720)
	set_meta("normal_play", true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	game.clock.set_process(false)
	game.waves.enabled = false
	game.seed_rewards.process_mode = Node.PROCESS_MODE_DISABLED
	player = game.player
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	player.camera_rig.capture_mouse()
	check(game.catalog.validation_errors().is_empty() and game.recipe_book.validation_errors(game.catalog).is_empty(), "new catalog and recipes validate")
	var plots := game.get_node("MainWorld/FarmArea").get_children().filter(func(node: Node) -> bool: return node is FarmPlot)
	check(plots.size() == 20, "farm has twenty interactive planting beds")
	for plot: FarmPlot in plots:
		var soil := plot.get_node("Soil") as MeshInstance3D
		var bottom := (soil.global_transform * soil.get_aabb()).position.y
		check(absf(bottom - RuralTerrain.height_at(plot.global_position.x, plot.global_position.z)) < 0.015 and plot.has_node("FrontBoard"), "soil and wood bed are grounded: " + String(plot.name))
	var full_med: ItemData = game.catalog.get_item(&"large_medicine")
	var recipe: CraftRecipe = game.recipe_book.get_recipe(&"large_medicine")
	game.waves.debug_set_day(6)
	check(not game.progression.is_seed_unlocked(&"seed_large_herb") and not game.crafting_system.is_unlocked(recipe), "large medicine crop and recipe stay locked before Day 7")
	game.waves.debug_set_day(7)
	check(game.progression.is_seed_unlocked(&"seed_large_herb") and game.crafting_system.is_unlocked(recipe) and game.inventory.has_item(&"seed_large_herb") and not game.inventory.has_item(full_med.id), "Day 7 grants seeds and recipe, never free medicine")
	game.inventory.select_seed(&"seed_large_herb")
	for index in [12, 13]: check(plots[index].interact(player).begins_with("Planted"), "new plot plants the large herb through normal seed use")
	game.clock.advance_game_minutes(36)
	for index in [12, 13]: check(plots[index].state == FarmPlot.State.READY and plots[index].interact(player).begins_with("Harvested"), "new plot matures and harvests the existing herb model")
	check(game.crafting_system.craft(recipe).begins_with("Crafted") and game.inventory.get_item_amount(full_med.id) == 1, "two farm-grown herbs craft one full-heal medicine")
	player.health._set_hp(12)
	key(KEY_V)
	key(KEY_F)
	check(player.health.current_hp == player.health.max_hp and not game.inventory.has_item(full_med.id), "F consumes the selected large medicine and restores full health")
	await frames(32)
	game.inventory.add_item(full_med, 2)
	key(KEY_F)
	check(game.inventory.get_item_amount(full_med.id) == 2, "full health never wastes large medicine")
	player.health._set_hp(50)
	game.pause_menu.set_open(true)
	key(KEY_F)
	check(player.health.current_hp == 50 and game.inventory.get_item_amount(full_med.id) == 2, "menus block full-heal input")
	game.pause_menu.set_open(false)
	for day in [8, 9, 10]:
		var before: int = game.inventory.get_item_amount(&"seed_lead")
		game.waves.debug_set_day(day)
		var amount: int = {8:12, 9:14, 10:16}[day]
		check(game.inventory.get_item_amount(&"seed_lead") - before == amount and game.progression.seed_reward_amount(day) == amount, "Day %d grants the configured late-game supplies" % day)
		var total: int = game.inventory.get_item_amount(&"seed_lead")
		game.progression.apply_day(day)
		check(game.inventory.get_item_amount(&"seed_lead") == total, "same-day refresh never grants the boosted supplies twice")
	for day in range(1, 11):
		var queue: Array[PackedScene] = game.progression.data.get_day(day).wave.spawn_queue()
		var bosses := queue.filter(func(scene: PackedScene) -> bool: return scene.resource_path.ends_with("BossZombie.tscn"))
		check(bosses.size() == (1 if day == 7 else 3 if day == 10 else 0), "Boss count follows the requested schedule: Night %d" % day)
		if day == 7: check(queue[0] == bosses[0], "first enemy spawned on Night 7 is the boss")
	# Existing saves have twelve named plots; added beds start empty without losing crops.
	var checkpoint := root.get_node("DayCheckpoint")
	check(checkpoint.capture_morning(10), "expanded farm and new items can be saved")
	var old: Dictionary = checkpoint.read_checkpoint()
	old.crops.resize(12)
	old.progression.seeds.erase("seed_large_herb")
	old.progression.recipes.erase("large_medicine")
	check(checkpoint._valid_snapshot(old) and checkpoint._restore(game, old), "previous twelve-plot checkpoints remain loadable")
	check(plots[14].state == FarmPlot.State.EMPTY and game.progression.is_seed_unlocked(&"seed_large_herb") and game.progression.is_recipe_unlocked(&"large_medicine"), "old saves gain the extra empty beds and new earned unlocks")
	await frames(4)
	# Isolate collision cases above the outdoor level, with actual world/body physics.
	var floor := wall_at(Vector3(0, 49.85, 0), Vector3(80, 0.3, 80))
	player.position = Vector3(0, 50.03, 0)
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	await frames(4)
	for type in ["Normal", "Runner", "Tank", "Boss"]:
		var enemy = load("res://scenes/enemies/%sZombie.tscn" % type).instantiate()
		game.add_child(enemy)
		enemy.global_position = Vector3(10, 50.03, 0)
		enemy.set_physics_process(false)
		enemy._update_hitboxes()
		await frames(3)
		var origin: Vector3 = enemy.body_hitbox.global_position
		var body_hit: Dictionary = game.weapons._ray(origin + Vector3(0, 0, 4), origin - Vector3(0, 0, 4))
		var before: float = enemy.health.current_hp
		check(body_hit.get("collider") == enemy.body_hitbox and game.weapons.apply_bullet_hit(body_hit, 20, null) and enemy.health.current_hp == before - 20, type + " body shot deals base damage")
		var previous_head: Vector3 = enemy.head_hitbox.global_position
		enemy.animation_player.play(enemy.data.walk_animation)
		enemy.animation_player.advance(0.25)
		enemy._update_hitboxes()
		check(enemy.head_hitbox.global_position.distance_to(previous_head) > 0.001 and enemy.head_hitbox.global_basis.is_equal_approx(Basis.IDENTITY), type + " head shape follows the animated bone with unit-scale physics")
		await frames(2)
		origin = enemy.head_hitbox.global_position
		var head_hit: Dictionary = game.weapons._ray(origin + Vector3(0, 0, 4), origin - Vector3(0, 0, 4))
		before = enemy.health.current_hp
		check(head_hit.get("collider") == enemy.head_hitbox and game.weapons.apply_bullet_hit(head_hit, 20, game.catalog.get_item(&"fire_ammo")) and enemy.health.current_hp == before - 45, type + " animated head collider applies 1.5x to bullet plus Fire bonus")
		check(enemy.ammo_effects.has(ItemData.AmmoEffect.BURN), "headshot preserves elemental effect without multiplying its tick damage")
		var cover := wall_at(origin + Vector3(0, 0, 2), Vector3(2, 2, 0.3))
		await frames(2)
		var blocked: Dictionary = game.weapons._ray(origin + Vector3(0, 0, 4), origin - Vector3(0, 0, 4))
		before = enemy.health.current_hp
		check(blocked.get("collider") == cover and not game.weapons.apply_bullet_hit(blocked, 20, null) and enemy.health.current_hp == before, "cover blocks " + type + " headshot")
		cover.queue_free()
		enemy.health.take_damage(enemy.health.max_hp)
		check(enemy.head_hitbox.collision_layer == 0 and enemy.body_hitbox.collision_layer == 0, "dead " + type + " cannot receive phantom headshots")
		enemy.queue_free()
		await frames(3)
	# The full camera -> muzzle -> hitbox pipeline must deliver the multiplier too.
	var gun_target = load("res://scenes/enemies/NormalZombie.tscn").instantiate()
	game.add_child(gun_target)
	gun_target.global_position = Vector3(0, 50.03, -7)
	gun_target.set_physics_process(false)
	gun_target._update_hitboxes()
	game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT)
	mouse(MOUSE_BUTTON_RIGHT, true)
	var weapon: WeaponRuntime = game.weapons.current
	weapon.data = weapon.data.duplicate()
	weapon.data.spread_degrees = 0
	weapon.current_magazine = 5
	weapon.magazine_ammo_type = game.catalog.get_item(&"basic_ammo")
	weapon.fire_cooldown = 0
	await frames(5)
	aim_at(player, gun_target.head_hitbox.global_position)
	var hp_before: float = gun_target.health.current_hp
	check(game.weapons.try_fire() and game.weapons.last_hit == gun_target and gun_target.health.current_hp == hp_before - weapon.data.damage * 1.5 and weapon.current_magazine == 4, "real aimed pistol shot consumes one round and deals 1.5x head damage")
	check(game.hud.get_node("Root/Crosshair").head_hit, "headshots have a distinct red hit confirmation")
	mouse(MOUSE_BUTTON_RIGHT, false)
	game.gameplay_mode.set_mode(GameplayModeController.Mode.FARMING)
	gun_target.queue_free()
	await frames(3)
	await charge_case(false, false)
	await charge_case(true, false)
	await charge_case(false, true)
	floor.queue_free()
	player.position = RuralTerrain.ground_point(0, 6, 0.03)
	player.health.reset()
	player.set_physics_process(true)
	game.waves.enabled = true
	player.health.damage_enabled = false
	for day in [7, 10]:
		game.waves.debug_set_day(day)
		game.clock.skip_to_night()
		var spawned_bosses := 0
		var first := true
		for tick in 240:
			game.waves._spawn_wait = 0
			await frames(2)
			for enemy: NormalZombie in game.waves.alive.values().duplicate():
				if first and day == 7: check(enemy.data.zombie_id == &"boss_zombie", "production Night 7 spawns the boss first on navigation")
				first = false
				if enemy.data.zombie_id == &"boss_zombie":
					spawned_bosses += 1
					var status = game.hud.get_node("Root/BossStatus")
					check(status.boss == enemy and status.hp.max_value == 2000, "Boss HUD binds the live wave health")
				enemy.health.take_damage(enemy.health.max_hp)
			if game.waves.state == NightWaveManager.State.CLEARED: break
		check(spawned_bosses == (1 if day == 7 else 3) and game.waves.remaining_zombies == 0 and game.waves.state == NightWaveManager.State.CLEARED, "real Night %d includes all bosses in wave and death accounting" % day)
	game.waves.debug_set_day(10)
	game.waves.enabled = false
	player.health.damage_enabled = true
	game.inventory_ui.set_open(true)
	await frames(12)
	await capture("large_medicine_inventory")
	game.inventory_ui.set_open(false)
	game.crafting_ui.set_open(true)
	game.crafting_ui._select_recipe(recipe)
	await frames(12)
	await capture("large_medicine_crafting")
	game.crafting_ui.set_open(false)
	if not capture_directory.is_empty() and DisplayServer.get_name() != "headless":
		var camera := Camera3D.new()
		game.add_child(camera)
		camera.make_current()
		camera.fov = 50
		camera.position = Vector3(2, 11, 21)
		camera.look_at(Vector3(-12, 0, 8.5))
		game.hud.get_node("Root").hide()
		plots[12].restore_checkpoint({"plant": "large_herb", "age": 36})
		await frames(12)
		await capture("farm_fifteen_beds")
		var hero = load("res://scenes/enemies/BossZombie.tscn").instantiate()
		game.add_child(hero)
		hero.global_position = RuralTerrain.ground_point(0, 10, 0.02)
		hero.set_physics_process(false)
		hero.animation_player.advance(0.3)
		hero._update_eyes()
		camera.position = hero.global_position + Vector3(4.5, 3.3, 6)
		camera.look_at(hero.global_position + Vector3.UP * 1.7)
		await frames(12)
		await capture("big_arm_boss")
	game.queue_free()
	await frames(4)
	print("BOSS_HEADSHOT_HARVEST_RESULT failures=", failures)
	quit(1 if failures else 0)

func charge_case(sidestep: bool, obstruct: bool) -> void:
	player.position = Vector3(0, 50.03, 0)
	player.health.reset()
	var boss = load("res://scenes/enemies/BossZombie.tscn").instantiate()
	game.add_child(boss)
	boss.global_position = Vector3(0, 50.03, 9)
	boss.bind(player)
	boss._charge_cooldown = 0
	await frames(6)
	check(boss.health.max_hp == 2000 and boss._eyes.size() == 2 and boss.charge_phase == boss.ChargePhase.WINDUP, "large Big Arm has 2000 HP, red rigged eyes and a charge windup")
	await frames(30)
	check(player.health.current_hp == 100, "charge warning gives time to dodge without early damage")
	var direction: Vector3 = boss.charge_direction
	var wall: StaticBody3D
	if sidestep: player.position.x = 5
	if obstruct:
		wall = wall_at(Vector3(0, 52, 4.5), Vector3(8, 4, 0.4))
	for tick in 360:
		await frames(1)
		if boss.charge_phase == boss.ChargePhase.RECOVERY: break
	check(boss.charge_phase == boss.ChargePhase.RECOVERY, "charge always enters a punishable recovery")
	if sidestep:
		check(player.health.current_hp == 100 and boss.charge_direction == direction, "sidestepping avoids a committed charge without homing")
	elif obstruct:
		check(player.health.current_hp == 100 and boss.global_position.z > 5, "charge stops at solid cover without tunneling or wall damage")
	else:
		check(boss.charge_hits == 1 and player.health.current_hp == 40, "charge contact deals exactly 60 damage once")
		await frames(20)
		check(player.health.current_hp == 40, "remaining near the recovering boss never repeats charge damage")
	boss.queue_free()
	if is_instance_valid(wall): wall.queue_free()
	await frames(4)
