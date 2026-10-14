extends "res://tests/phase_5_weapon_test.gd"
var game: Node3D
var player: PlayerController

func enemy_at(type: String, point: Vector3) -> NormalZombie:
	var enemy := load("res://scenes/enemies/%sZombie.tscn" % type).instantiate() as NormalZombie
	game.add_child(enemy)
	enemy.position = point
	enemy.bind(player)
	enemy.set_physics_process(false)
	enemy._update_hitboxes()
	return enemy

func run() -> void:
	root.size = Vector2i(1280,720)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	game.clock.set_process(false)
	game.waves.enabled = false
	game.seed_rewards.process_mode = Node.PROCESS_MODE_DISABLED
	player = game.player
	player.set_physics_process(false)
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	player.camera_rig.capture_mouse()
	check(game.catalog.validation_errors().is_empty() and game.recipe_book.validation_errors(game.catalog).is_empty() and game.progression.data.validation_errors(game.catalog,game.recipe_book).is_empty(),"all new item, recipe and wave definitions validate")
	game.waves.debug_set_day(7)
	for id in [&"basic_ammo",&"fire_ammo",&"ice_ammo",&"poison_ammo"]:
		var recipe: CraftRecipe = game.recipe_book.get_recipe(id)
		for entry: RecipeEntry in recipe.ingredients: game.inventory.add_item(entry.item,entry.quantity)
		var before: int = game.inventory.get_item_amount(id)
		check(game.crafting_system.craft(recipe).begins_with("Crafted") and game.inventory.get_item_amount(id)-before == 10,"actual craft yields ten " + String(id))
	var grenade_recipe: CraftRecipe = game.recipe_book.get_recipe(&"ice_grenade")
	for entry: RecipeEntry in grenade_recipe.ingredients: game.inventory.add_item(entry.item,entry.quantity)
	check(game.crafting_system.craft(grenade_recipe).begins_with("Crafted") and game.inventory.has_item(&"ice_grenade"),"Ice Grenade crafts from 2 Ice Crystal / 1 Iron / 1 Paper")
	game.crafting_ui.set_open(true)
	game.crafting_ui._select_recipe(grenade_recipe)
	await frames(14)
	check(game.crafting_ui.recipe_tabs.get_tab_count() == 3 and game.crafting_ui.recipe_tabs.current_tab == 0,"Workbench has Ammo, Weapons and Parts tabs")
	await capture("craft_ammo")
	game.crafting_ui.recipe_tabs.current_tab = 1
	await frames(14)
	check(game.crafting_ui.selected_recipe.category == CraftRecipe.Category.WEAPON,"Weapons tab selects only weapon recipes")
	await capture("craft_weapons")
	game.crafting_ui.recipe_tabs.current_tab = 2
	await frames(14)
	check(game.crafting_ui._buttons[game.recipe_book.get_recipe(&"heavy_armor")].is_visible_in_tree() and game.crafting_ui._buttons[game.recipe_book.get_recipe(&"large_medicine")].is_visible_in_tree(),"Parts tab retains armor and medicine access")
	await capture("craft_parts")
	game.crafting_ui.set_open(false)
	var floor := wall_at(Vector3(0,49.85,0),Vector3(80,0.3,80))
	player.position = Vector3(0,50.03,0)
	await frames(3)
	var boss = enemy_at("Boss",Vector3(10,50.03,0))
	check(boss.health.max_hp == 2000, "Boss health is two thousand in the live enemy instance")
	var fire: ItemData = game.catalog.get_item(&"fire_ammo")
	var poison: ItemData = game.catalog.get_item(&"poison_ammo")
	var ice: ItemData = game.catalog.get_item(&"ice_ammo")
	var rifle: WeaponData = load("res://resources/weapons/basic_rifle.tres")
	var sniper: WeaponData = load("res://resources/weapons/marksman_rifle.tres")
	game.weapons.apply_bullet_hit({"collider":boss.body_hitbox},40,fire,rifle)
	check(boss.health.current_hp == boss.health.max_hp - 50,"Fire adds ten to rifle bullet damage")
	for tick in 5: boss._tick_ammo_effects(1)
	check(boss.health.current_hp == boss.health.max_hp * 0.95 - 50,"Fire burns 1 percent max HP/s for five seconds")
	boss.health.reset()
	boss.ammo_effects.clear()
	game.weapons.apply_bullet_hit({"collider":boss.head_hitbox},100,fire,sniper)
	check(boss.health.current_hp == boss.health.max_hp - 225,"Marksman Fire adds fifty before the 1.5x headshot multiplier")
	for tick in 5: boss._tick_ammo_effects(1)
	check(boss.health.current_hp == boss.health.max_hp * 0.95 - 225,"headshots never multiply the percentage burn")
	boss.health.reset()
	boss.apply_ammo_effect(poison)
	check(is_equal_approx(boss.ammo_damage_multiplier(),0.9),"Poison immediately reduces outgoing damage ten percent")
	for tick in 3: boss._tick_ammo_effects(1)
	check(boss.health.current_hp == boss.health.max_hp * 0.85 and boss.ammo_damage_multiplier() == 1,"Poison totals fifteen percent max HP and the debuff expires after three seconds")
	boss.apply_ammo_effect(ice)
	boss._tick_ammo_effects(3.1)
	check(boss.ammo_speed_multiplier() == 0.5,"Ice still slows after three seconds")
	boss._tick_ammo_effects(1)
	check(boss.ammo_speed_multiplier() == 1,"Ice expires after four seconds")
	boss.apply_ammo_effect(fire)
	boss._tick_ammo_effects(1)
	boss.apply_ammo_effect(fire)
	check(boss.ammo_effects.size() == 1 and boss.ammo_effects[ItemData.AmmoEffect.BURN].remaining == 5,"repeated elemental hits refresh duration without stacking strength")
	boss.queue_free()
	await frames(3)
	await grenade_case()
	await melee_case(false)
	await melee_case(true)
	await charge_case()
	await leap_case(4.2,false)
	await leap_case(5.1,false)
	await leap_case(0.0,true)
	await airborne_death_case()
	floor.queue_free()
	player.position = Vector3(0,0.05,6)
	player.health.reset()
	game.equipment.unequip_armor()
	await frames(5)
	await final_wave_case()
	game.waves.enabled = false
	game.inventory.add_item(game.catalog.get_item(&"ice_grenade"),3)
	var checkpoint := root.get_node("DayCheckpoint")
	check(checkpoint.capture_morning(10),"grenade inventory can be saved in the morning checkpoint")
	var save: Dictionary = checkpoint.read_checkpoint()
	var count: int = game.inventory.get_item_amount(&"ice_grenade")
	game.inventory.remove_item(&"ice_grenade",count)
	check(checkpoint._restore(game,save) and game.inventory.get_item_amount(&"ice_grenade") == count,"Continue restores canonical grenade items and recipes")
	if not capture_directory.is_empty() and DisplayServer.get_name() != "headless": await pictures()
	game.queue_free()
	await frames(6)
	print("ELEMENTAL_BOSS_EXPANSION_RESULT failures=",failures)
	quit(1 if failures else 0)

func grenade_case() -> void:
	var enemies: Array[NormalZombie] = [enemy_at("Normal",Vector3(1,50.03,0)),enemy_at("Runner",Vector3(5.6,50.03,0)),enemy_at("Tank",Vector3(6.5,50.03,0)),enemy_at("Boss",Vector3(0,50.03,4))]
	var cover := wall_at(Vector3(0,51.5,2),Vector3(2,3,0.3))
	var grenade = load("res://scripts/inventory/ice_grenade.gd").new()
	grenade.item = game.catalog.get_item(&"ice_grenade")
	game.add_child(grenade)
	grenade.position = Vector3(0,50.2,0)
	grenade.freeze = true
	grenade.set_physics_process(false)
	await frames(4)
	check(grenade.explode() == 2 and enemies[0].ammo_speed_multiplier() == 0.5 and enemies[1].ammo_speed_multiplier() == 0.5,"grenade applies a wide-area slow to multiple enemy types")
	check(enemies[2].ammo_speed_multiplier() == 1 and enemies[3].ammo_speed_multiplier() == 1,"grenade respects blast radius and solid cover")
	check(grenade.explode() == 0,"grenade detonation commits once")
	for enemy in enemies: enemy.queue_free()
	cover.queue_free()
	await frames(4)
	game.gameplay_mode.set_mode(GameplayModeController.Mode.FARMING)
	check(not game.grenades.can_throw(),"Farming mode blocks grenade throws")
	game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT)
	player.camera_rig.set_menu_open(false)
	player.camera_rig.capture_mouse()
	await frames(3)
	game.inventory.add_item(game.catalog.get_item(&"ice_grenade"),1)
	var before: int = game.inventory.get_item_amount(&"ice_grenade")
	key(KEY_G)
	check(game.inventory.get_item_amount(&"ice_grenade") == before-1,"G consumes exactly one grenade through the real input action")
	var thrown := game.find_children("*","RigidBody3D",true,false)
	check(thrown.size() == 1 and not game.grenades.throw_grenade(),"throw cooldown blocks duplicate input")
	if not thrown.is_empty():
		var remaining: float = thrown[0].fuse
		paused = true
		await frames(10)
		check(thrown[0].fuse == remaining,"grenade fuse pauses with modal menus")
		paused = false
		thrown[0].queue_free()
	await frames(5)

func melee_case(poisoned: bool) -> void:
	player.position = Vector3(0,50.03,1.5)
	player.health.reset()
	game.equipment.unequip_armor()
	# Flush the player's teleport before inserting another solid body at its old site.
	await frames(3)
	var boss = enemy_at("Boss",Vector3(0,50.03,0))
	boss._charge_cooldown = 100
	boss._leap_cooldown = 100
	if poisoned: boss.apply_ammo_effect(game.catalog.get_item(&"poison_ammo"))
	boss.set_physics_process(true)
	for tick in 90:
		await frames(1)
		if boss.attacks_landed > 0: break
	if boss.attacks_landed == 0: print("MELEE_DIAGNOSTIC ",boss.global_position," player=",player.global_position," state=",boss.state," windup=",boss._windup," distance=",boss.global_position.distance_to(player.global_position)," clear=",boss._clear_melee_line()," paused=",paused)
	check(player.health.current_hp == (64 if poisoned else 60),"real Boss melee damage (HP=%s, hits=%s)" % [player.health.current_hp,boss.attacks_landed])
	boss.queue_free()
	await frames(4)

func charge_case() -> void:
	player.position = Vector3(0,50.03,0)
	player.health.reset()
	var boss = enemy_at("Boss",Vector3(0,50.03,9))
	boss._begin_charge()
	var status = game.hud.get_node("Root/BossStatus")
	game.waves.alive[boss.get_instance_id()] = boss
	status._select()
	check(status.amount.text == "2000 / 2000" and status.phase.text == "CHARGE" and boss._warning.visible and boss.get_node_or_null("ChargeCountdown") == null, "Boss HUD shows 2000 HP and a red charge warning without a seconds counter")
	await aim_at(player, boss.global_position + Vector3.UP * 2)
	await capture("boss_charge_clean")
	check(boss.get_node_or_null("ChargeCountdown") == null and boss.charge_seconds_remaining() == 2.5 and boss._charge_cooldown == 15,"charge telegraph is 2.5 seconds with a fifteen-second cooldown")
	boss._leap_cooldown = 100
	boss.set_physics_process(true)
	await frames(140)
	check(player.health.current_hp == 100 and boss.charge_phase == boss.ChargePhase.WINDUP,"charge causes no damage before the revised warning finishes")
	for tick in 120:
		await frames(1)
		if boss.charge_phase == boss.ChargePhase.RECOVERY: break
	check(player.health.current_hp == 40 and boss.charge_hits == 1,"charge hits for sixty exactly once")
	game.waves.alive.erase(boss.get_instance_id())
	status._select()
	boss.queue_free()
	await frames(4)

func leap_case(offset: float, armor: bool) -> void:
	player.position = Vector3(0,50.03,0)
	player.health.reset()
	if armor:
		game.inventory.add_item(game.catalog.get_item(&"heavy_armor"),1)
		game.equipment.equip_armor(game.catalog.get_item(&"heavy_armor"))
	else: game.equipment.unequip_armor()
	var boss = enemy_at("Boss",Vector3(0,50.03,8))
	boss._begin_leap()
	check(boss._leap_warning.visible and boss.get_node_or_null("ChargeCountdown") == null and boss.charge_seconds_remaining() == 3.0 and boss._leap_cooldown == 15,"slam displays a locked circular warning for three seconds")
	player.position.x = offset
	boss.set_physics_process(true)
	await frames(170)
	check(player.health.current_hp == 100,"slam has no early damage during windup")
	var time: float = boss._charge_timer
	paused = true
	await frames(6)
	check(boss._charge_timer == time,"pause freezes the slam warning")
	paused = false
	var peak := 0.0
	for tick in 90:
		await frames(1)
		peak = maxf(peak,boss.position.y)
		if boss.charge_phase == boss.ChargePhase.RECOVERY: break
	var expected := 64.0 if armor else 40.0 if offset <= 4.5 else 100.0
	check(is_equal_approx(player.health.current_hp,expected) and peak > 53,"jump has a physical airborne arc and applies the advertised circular radius/armor damage")
	check(not boss._leap_warning.visible and boss.leap_hits == (1 if expected < 100 else 0),"slam clears its warning and never hits twice")
	await frames(5)
	check(boss.position.y < 50.2,"landing on a player's position stays grounded instead of climbing onto the player")
	if offset == 0: check(boss.get_collision_exceptions().has(player),"a player inside the landing body can move out without getting trapped")
	boss.queue_free()
	await frames(4)

func airborne_death_case() -> void:
	player.position = Vector3(0,50.03,0)
	player.health.reset()
	var boss = enemy_at("Boss",Vector3(0,50.03,8))
	boss._begin_leap()
	boss._charge_timer = 0.01
	boss.set_physics_process(true)
	await frames(25)
	check(boss.position.y > 53,"airborne death fixture reaches the top of the arc")
	boss.health.take_damage(boss.health.max_hp)
	await frames(40)
	check(boss.position.y < 50.2 and boss.leap_hits == 0 and player.health.current_hp == 100 and not boss._leap_warning.visible,"killing an airborne boss makes it fall without phantom landing damage")
	boss.queue_free()
	await frames(4)

func final_wave_case() -> void:
	game.waves.enabled = true
	game.waves.debug_set_day(10)
	game.clock.skip_to_night()
	game.waves.data = game.waves.data.duplicate()
	game.waves.data.spawn_interval = 0.04
	var born: Array[int] = []
	game.get_node("MainWorld").child_entered_tree.connect(func(node: Node) -> void:
		if node is NormalZombie and node.data.zombie_id == &"boss_zombie": born.append(Engine.get_physics_frames()))
	for tick in 140:
		await frames(1)
		for enemy: NormalZombie in game.waves.alive.values(): enemy.set_physics_process(false)
		if game.waves.spawned_zombies >= 8: break
	var bosses: Array = game.waves.alive.values().filter(func(enemy: NormalZombie) -> bool: return enemy.data.zombie_id == &"boss_zombie")
	check(bosses.size() == 1 and game.waves.held_bosses.size() == 2 and game.waves.total_zombies == 27,"Night 10 starts with one boss and holds two in the wave accounting")
	game.waves._spawn_wait = 100
	var before: int = game.waves.spawned_zombies
	if not bosses.is_empty(): bosses[0].health.take_damage(bosses[0].health.max_hp)
	await frames(4)
	bosses = game.waves.alive.values().filter(func(enemy: NormalZombie) -> bool: return enemy.data.zombie_id == &"boss_zombie")
	check(bosses.size() == 2 and game.waves.spawned_zombies == before+2 and born.size() == 3 and born[1] == born[2],"killing the first boss spawns both replacements in the same physics frame")
	check(game.waves.held_bosses.is_empty() and game.waves.state == NightWaveManager.State.ACTIVE,"reinforcements are counted without prematurely clearing the wave")
	game.waves.debug_clear_wave()
	await frames(6)
	check(game.waves.alive.is_empty() and not game.waves._reinforcement_due,"wave cleanup cancels all staged and live bosses")

func pictures() -> void:
	game.clock.seek(10,22)
	player.position = Vector3(0,0.03,6)
	player.health.reset()
	game.equipment.unequip_armor()
	game.hud.get_node("Root").hide()
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.make_current()
	camera.position = Vector3(9,10,15)
	camera.look_at(Vector3(0,0,3))
	var boss = enemy_at("Boss",Vector3(0,0.03,-5))
	boss._begin_leap()
	boss.set_physics_process(true)
	await frames(45)
	await capture("boss_slam_warning")
	boss.set_physics_process(true)
	while boss.charge_phase != boss.ChargePhase.LEAPING: await frames(1)
	await frames(26)
	await capture("boss_slam_airborne")
	while boss.charge_phase != boss.ChargePhase.RECOVERY: await frames(1)
	await frames(2)
	await capture("boss_slam_impact")
	boss.queue_free()
	await frames(5)
