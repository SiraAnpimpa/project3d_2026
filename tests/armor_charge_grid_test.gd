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
	check(game.catalog.validation_errors().is_empty() and game.progression.data.validation_errors(game.catalog, game.recipe_book).is_empty(), "armor catalog and day progression validate")
	var plots := game.get_node("MainWorld/FarmArea").get_children().filter(func(node: Node) -> bool: return node is FarmPlot)
	var xs: Array[float] = []
	var zs: Array[float] = []
	for plot: FarmPlot in plots:
		if plot.position.x not in xs: xs.append(plot.position.x)
		if plot.position.z not in zs: zs.append(plot.position.z)
		var soil := plot.get_node("Soil") as MeshInstance3D
		check(absf((soil.global_transform * soil.get_aabb()).position.y - RuralTerrain.height_at(plot.position.x, plot.position.z)) < 0.01, "bed stays grounded: " + String(plot.name))
	xs.sort()
	zs.sort()
	check(plots.size() == 20 and xs.size() == 5 and zs.size() == 4, "farm is exactly four rows by five columns")
	for index in range(1, xs.size()): check(is_equal_approx(xs[index] - xs[index-1], 3.0), "column spacing is uniformly 3.0 metres")
	for index in range(1, zs.size()): check(is_equal_approx(zs[index] - zs[index-1], 3.0), "row spacing matches column spacing")
	check(game.inventory.get_item_amount(&"seed_lead") == 4, "Day 1 gives the original three starter seeds plus one")
	for day in range(1, 11):
		var expected: int = [1,4,5,5,6,6,7,12,14,16][day-1]
		check(game.progression.data.get_day(day).supply_quantity == expected, "requested daily supplies: Day %d" % day)
	var armor: ItemData = game.catalog.get_item(&"heavy_armor")
	var recipe: CraftRecipe = game.recipe_book.get_recipe(&"heavy_armor")
	game.waves.debug_set_day(5)
	game.inventory.add_item(game.catalog.get_item(&"iron"), 4)
	game.inventory.add_item(game.catalog.get_item(&"copper"), 2)
	check(game.crafting_system.craft(recipe).contains("Locked") and not game.inventory.has_item(armor.id), "armor cannot be crafted before Day 6 even with materials")
	game.waves.debug_set_day(6)
	check(game.crafting_system.craft(recipe).begins_with("Crafted") and game.equipment.armor_item == armor, "Day 6 armor crafts with Iron 4 / Copper 2 and auto-equips")
	check(not game.inventory.has_item(&"iron") and not game.inventory.has_item(&"copper") and is_equal_approx(player.health.incoming_damage_multiplier, 0.6), "crafting debits affordable materials and applies exactly 40 percent protection")
	check(game.crafting_system.armor_already_owned(recipe) and recipe not in game.crafting_system.get_available_recipes(), "owned armor cannot be crafted twice")
	check(not player.has_node("ArmorVisual") and game.hud._armor_badge.visible, "equipped armor uses only a compact symbol beside health")
	player.health.reset()
	player.health.take_damage(80)
	check(player.health.current_hp == 52, "80 incoming damage becomes 48 with heavy armor")
	game.inventory_ui.set_open(true)
	await frames(12)
	check(game.inventory_ui.armor_button.text.contains("Equipped"), "inventory clearly shows equipped armor")
	var weapons_window := game.inventory_ui.screen.find_child("WeaponsWindow", true, false) as Control
	var armor_window: Control = game.inventory_ui.armor_section
	check(armor_window.get_parent() == weapons_window.get_parent() and armor_window.global_position.y >= weapons_window.global_position.y + weapons_window.size.y, "Armor has its own window below Weapons")
	await capture("armor_inventory")
	game.inventory_ui.armor_button.pressed.emit()
	check(game.equipment.armor_item == null and not game.hud._armor_badge.visible and player.health.incoming_damage_multiplier == 1, "inventory removal disables protection and the health symbol")
	game.inventory.add_item(game.catalog.get_item(&"paper"), 1)
	check(game.equipment.armor_item == null, "unrelated inventory updates never re-equip manually removed armor")
	game.inventory_ui.armor_button.pressed.emit()
	check(game.equipment.armor_item == armor, "inventory can equip owned armor again")
	game.inventory_ui.set_open(false)
	var checkpoint := root.get_node("DayCheckpoint")
	check(checkpoint.capture_morning(6), "equipped armor persists in the morning checkpoint")
	var saved: Dictionary = checkpoint.read_checkpoint()
	game.equipment.unequip_armor()
	check(checkpoint._restore(game, saved) and game.equipment.armor_item == armor and is_equal_approx(player.health.incoming_damage_multiplier, 0.6), "Continue restores armor protection and the health symbol")
	var bad := saved.duplicate(true)
	bad.armor = "pistol"
	check(not checkpoint._valid_snapshot(bad), "a weapon cannot be substituted into the saved armor slot")
	game.equipment.unequip_armor()
	check(checkpoint.capture_morning(6), "unequipped owned armor can be checkpointed")
	var unequipped: Dictionary = checkpoint.read_checkpoint()
	game.equipment.equip_armor(armor)
	check(checkpoint._restore(game, unequipped) and game.equipment.armor_item == null, "Continue preserves a deliberately empty armor slot")
	game.inventory.remove_item(armor.id, 1)
	check(player.health.incoming_damage_multiplier == 1 and not game.inventory_ui.armor_section.visible, "removing owned armor leaves no phantom protection or equipment row")
	game.inventory.add_item(armor, 1)
	player.health.reset()
	player.set_physics_process(false)
	var floor := wall_at(Vector3(0, 49.85, 0), Vector3(80, 0.3, 80))
	player.position = Vector3(0, 50.03, 0)
	await frames(3)
	await charge_case(0.0, true, false)
	await charge_case(1.25, false, false)
	await charge_case(1.8, false, false)
	await charge_case(0.0, false, true)
	floor.queue_free()
	player.position = RuralTerrain.ground_point(0, 6, 0.03)
	player.health.reset()
	game.equipment.equip_armor(armor)
	if not capture_directory.is_empty() and DisplayServer.get_name() != "headless": await pictures(plots)
	game.queue_free()
	await frames(5)
	print("ARMOR_CHARGE_GRID_RESULT failures=", failures)
	quit(1 if failures else 0)

func charge_case(sideways: float, armored: bool, cover: bool) -> void:
	player.position = Vector3(sideways, 50.03, 0)
	player.health.reset()
	if armored: game.equipment.equip_armor(game.catalog.get_item(&"heavy_armor"))
	else: game.equipment.unequip_armor()
	var boss = load("res://scenes/enemies/BossZombie.tscn").instantiate()
	game.add_child(boss)
	boss.global_position = Vector3(0, 50.03, 9)
	boss.bind(player)
	boss.set_physics_process(false)
	# Lock the corridor to the original centre: test being inside/outside its radius.
	player.position.x = 0
	boss._begin_charge()
	player.position.x = sideways
	check(boss._warning.visible and boss._warning.mesh.get_aabb().size.z > 13 and boss.get_node_or_null("ChargeCountdown") == null and boss.charge_seconds_remaining() == 2.5, "red corridor shows full range and starts at 2.5 seconds")
	check(is_equal_approx(boss._warning.mesh.get_aabb().size.x, boss.CHARGE_RADIUS * 2), "filled warning covers the complete damage width")
	check(absf(boss._warning.mesh.get_aabb().position.y - 50.065) < 0.02, "telegraph follows the actual ground collider")
	boss.set_physics_process(true)
	await frames(140)
	check(boss.charge_phase == boss.ChargePhase.WINDUP and player.health.current_hp == 100, "Boss waits nearly 2.5 seconds with no early damage")
	var pause_time: float = boss._charge_timer
	paused = true
	await frames(8)
	check(boss._charge_timer == pause_time, "pause freezes the charge warning")
	paused = false
	var wall: StaticBody3D
	if cover: wall = wall_at(Vector3(0, 52, 4.5), Vector3(8, 4, 0.4))
	for tick in 160:
		await frames(1)
		if boss.charge_phase == boss.ChargePhase.RECOVERY: break
	var expected := 64.0 if armored else 40.0 if sideways < boss.CHARGE_RADIUS and not cover else 100.0
	check(player.health.current_hp == expected, "charge corridor applies the correct radius, armor and cover result")
	check(not boss._warning.visible and boss.get_node_or_null("ChargeCountdown") == null, "warning clears after the charge")
	check(boss.charge_hits == (1 if expected < 100 else 0), "each charge damages at most once")
	boss.queue_free()
	if is_instance_valid(wall): wall.queue_free()
	await frames(4)

func pictures(plots: Array) -> void:
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.make_current()
	camera.fov = 40
	player.visual.rotation.y = PI
	camera.position = player.global_position + Vector3(2.2, 1.55, -3.5)
	camera.look_at(player.global_position + Vector3.UP * 0.86)
	await frames(12)
	await capture("armor_health_symbol")
	game.hud.get_node("Root").hide()
	camera.fov = 50
	camera.position = Vector3(2, 14, 26)
	camera.look_at(Vector3(-11.5, 0, 10.7))
	await frames(12)
	await capture("farm_twenty_grid")
	player.position = RuralTerrain.ground_point(0, 6, 0.03)
	var boss = load("res://scenes/enemies/BossZombie.tscn").instantiate()
	game.add_child(boss)
	boss.global_position = RuralTerrain.ground_point(0, -5, 0.02)
	boss.bind(player)
	boss.set_physics_process(false)
	boss._begin_charge()
	camera.position = Vector3(9, 10, 14)
	camera.look_at(Vector3(0, 0, 2))
	boss.animation_player.advance(0.2)
	boss.animation_player.pause()
	boss._update_eyes()
	boss._update_hitboxes()
	await frames(12)
	await capture("boss_charge_red_range")
	game.clock.seek(7, 22)
	await frames(24)
	await capture("boss_charge_night")
