extends "res://tests/phase_6_zombie_test.gd"

var pack: Array[NormalZombie] = []

func spawn_variant(kind: String, point: Vector3) -> NormalZombie:
	var enemy := ZombieSpawnFactory.spawn(game.get_node("MainWorld"), load("res://scenes/enemies/%sZombie.tscn" % kind), player, point)
	if enemy != null: pack.append(enemy)
	return enemy

func clear_pack() -> void:
	for enemy in pack:
		if is_instance_valid(enemy): enemy.despawn()
	pack.clear()
	await frames(3)
	player.health.reset()

func run() -> void:
	root.size = Vector2i(1280, 720)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	player = game.player
	game.clock.set_process(false)
	game.debug_controls.set_active(false)
	for kind in ["Normal", "Runner", "Tank"]:
		await place_player(Vector3(12, 0.05, 6))
		var enemy := spawn_variant(kind, Vector3(12, 0.05, -4))
		check(enemy != null and enemy.data.validation_errors().is_empty(), kind + " uses shared controller with valid data")
		if enemy == null: continue
		await frames(5)
		var origin := enemy.position
		await frames(30)
		var distance := enemy.position.distance_to(origin)
		check(absf(distance - enemy.data.move_speed * 0.5) < 0.15, kind + " measured movement matches configured speed")
		check(enemy.animation_player.has_animation(enemy.data.walk_animation), kind + " movement clip exists (Runner uses Run)")
		check(enemy.health.max_hp == enemy.data.max_health, kind + " applies per-instance HP")
		await wait_for_attack(enemy, 900)
		await frames(25)
		check(enemy.attacks_landed == 1 and player.health.current_hp == 100 - enemy.data.damage, kind + " navigates into melee and lands data-driven damage")
		await capture("phase8_" + kind.to_lower())
		await clear_pack()
	# Larger Tank collider uses the existing 0.5m nav clearance and fits shelter entrance.
	await place_player(Vector3(7, 0.05, 7))
	var tank := spawn_variant("Tank", Vector3(7, 0.05, -1))
	await wait_for_attack(tank, 900)
	check(tank.state == NormalZombie.State.ATTACK and absf(tank.position.y) < 0.12, "Tank routes around solid obstacle without floating")
	await clear_pack()
	await place_player(Vector3(-9, 0.05, -6))
	tank = spawn_variant("Tank", Vector3(-9, 0.05, -11))
	await wait_for_attack(tank, 1200)
	check(tank.state == NormalZombie.State.ATTACK, "Tank collider navigates shelter front")
	await clear_pack()
	# Several runners can be escaped using actual sprint input.
	await place_player(Vector3(12, 0.05, 0))
	for x in [10, 12, 14]: spawn_variant("Runner", Vector3(x, 0.05, -5))
	player.camera_rig.rotation.y = 0
	var start := player.position
	Input.action_press("move_backward")
	Input.action_press("sprint")
	await frames(60)
	Input.action_release("move_backward")
	Input.action_release("sprint")
	check(player.position.distance_to(start) > 6 and player.health.current_hp == 100, "player sprint outruns three Runners without unavoidable damage")
	await clear_pack()
	# Real mixed combat: two Normal, one Runner, one Tank. Heal only for observation.
	await place_player(Vector3(13, 0.05, 12))
	spawn_variant("Normal", Vector3(9, 0.05, 12))
	spawn_variant("Normal", Vector3(17, 0.05, 12))
	spawn_variant("Runner", Vector3(13, 0.05, 8))
	spawn_variant("Tank", Vector3(13, 0.05, 16))
	for _tick in 230:
		await frames(1)
		if player.health.current_hp < 60: player.health.heal(100)
	var all_attacked := true
	for enemy in pack: all_attacked = all_attacked and enemy.attacks_landed > 0
	check(pack.size() == 4 and all_attacked, "mixed pack navigates, collides and independently attacks")
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 60)
	key(KEY_Q)
	key(KEY_R)
	for _tick in 100:
		await frames(1)
		player.health.heal(100)
	check(game.weapons.current.current_magazine == 10, "reload works while all variants attack")
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(10)
	await capture("phase8_mixed")
	var hits := {&"normal_zombie": 0, &"runner_zombie": 0, &"tank_zombie": 0}
	for _shot in 45:
		var closest: NormalZombie
		for enemy in pack:
			if not is_instance_valid(enemy) or enemy.health.is_dead: continue
			if closest == null or enemy.position.distance_to(player.position) < closest.position.distance_to(player.position): closest = enemy
		if closest == null: break
		player.health.heal(100)
		if game.weapons.current.current_magazine == 0:
			key(KEY_R)
			for _tick in 95:
				await frames(1)
				player.health.heal(100)
		aim_at(player, closest.global_position + Vector3.UP)
		var previous := closest.health.current_hp
		mouse(MOUSE_BUTTON_LEFT, true)
		mouse(MOUSE_BUTTON_LEFT, false)
		if closest.health.current_hp < previous: hits[closest.data.zombie_id] += 1
		await frames(13)
	mouse(MOUSE_BUTTON_RIGHT, false)
	await frames(80)
	var living := 0
	for enemy in pack:
		if is_instance_valid(enemy): living += 1
	check(living == 0 and hits[&"normal_zombie"] == 10 and hits[&"runner_zombie"] == 3 and hits[&"tank_zombie"] == 15, "mixed rifle fight: five hits per Normal, three Runner, fifteen Tank; all clean up")
	print("MIXED_COMBAT hits=", hits, " reserve=", game.weapons.reserve_ammo(), " magazine=", game.weapons.current.current_magazine)
	print("PHASE_8_VARIANTS_RESULT failures=", failures)
	quit(1 if failures else 0)
