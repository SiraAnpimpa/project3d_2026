extends "res://tests/phase_5_weapon_test.gd"

var game: Node3D
var player: PlayerController
var spawner: ZombieTestSpawner


func place_player(point: Vector3) -> void:
	player.global_position = point
	player.velocity = Vector3.ZERO
	await frames(2)


func wait_for_attack(zombie: NormalZombie, maximum_frames: int = 600) -> void:
	for _i in maximum_frames:
		if zombie.state == NormalZombie.State.ATTACK: return
		await frames(1)


func clear_enemies() -> void:
	spawner.clear_zombies()
	await frames(3)
	player.health.reset()


func run() -> void:
	root.size = Vector2i(1280, 720)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	player = game.player
	spawner = game.debug_controls.zombie_spawner
	game.debug_controls.set_active(false)
	check(spawner.spawn_test_zombies(3) == 0 and spawner.zombies.is_empty(), "debug disabled blocks test spawning; no automatic enemies")
	game.debug_controls.set_active(true)
	key(KEY_TAB)
	await frames(3)
	await click_button(game.inventory_ui.find_child("debug_spawn_three", true, false))
	check(spawner.zombies.size() == 3, "bag debug button spawns three safe reusable zombies")
	await capture("phase6_debug_spawn")
	key(KEY_TAB)
	game.debug_controls.execute(&"debug_spawn_three")
	check(spawner.zombies.size() == 5, "test spawner caps at five")
	game.debug_controls.set_active(false)
	check(not spawner.zombies[0].label.visible, "debug labels turn off independently of AI")
	await clear_enemies()
	check(spawner.spawn_at(Vector3(7, 0, 3)) == null, "spawner rejects occupied obstacle")
	await place_player(Vector3(18, 0.05, 18))
	var zombie := spawner.spawn_at(Vector3(5, 0.05, -5))
	check(zombie != null and zombie.data.validation_errors().is_empty(), "NormalZombie uses valid data and existing Health")
	await frames(30)
	check(zombie.state == NormalZombie.State.IDLE and zombie.path_updates == 0, "out of detection range remains idle")
	check(zombie.animation_player.has_animation(zombie.data.idle_animation) and zombie.animation_player.has_animation(zombie.data.walk_animation) and zombie.animation_player.has_animation(zombie.data.attack_animation) and zombie.animation_player.has_animation(zombie.data.death_animation), "actual imported idle walk punch death clips exist")
	await place_player(Vector3(5, 0.05, 0))
	await frames(10)
	check(zombie.state == NormalZombie.State.CHASE, "enter detection range starts chase")
	var first_position := zombie.position
	await frames(30)
	check(zombie.position.distance_to(first_position) > 0.8 and zombie.position.distance_to(first_position) < 1.15, "chase speed about two metres per second")
	check(zombie.visual.global_basis.z.dot((player.position - zombie.position).normalized()) > 0.9, "visual smoothly faces movement with authored positive Z forward")
	await wait_for_attack(zombie)
	check(zombie.state == NormalZombie.State.ATTACK and player.health.current_hp == 100, "enter attack stops movement and starts windup without immediate damage")
	await frames(25)
	check(player.health.current_hp == 90 and zombie.attacks_landed == 1, "windup applies one ten-point hit through Player Health")
	await frames(25)
	check(player.health.current_hp == 90, "cooldown prevents damage every frame")
	await frames(50)
	check(player.health.current_hp == 80, "next interval applies exactly one additional hit")
	check(zombie.path_updates < 15, "path target refresh is throttled")
	await place_player(Vector3(5, 0.05, 5))
	await frames(2)
	check(zombie.state == NormalZombie.State.CHASE, "leaving attack range resumes chase")
	# A new attack can miss during its windup.
	await clear_enemies()
	await place_player(Vector3(12, 0.05, 0))
	zombie = spawner.spawn_at(Vector3(12, 0.05, -1.1))
	await frames(5)
	await place_player(Vector3(12, 0.05, 3))
	await frames(25)
	check(player.health.current_hp == 100 and zombie.attacks_landed == 0, "escaping during windup avoids damage")
	await clear_enemies()
	# Approach the block from both sides; sample every physics tick for penetration.
	for side in [-1.0, 1.0]:
		await place_player(Vector3(7, 0.05, 3 + side * 4))
		zombie = spawner.spawn_at(Vector3(7, 0.05, 3 - side * 4))
		var detour := false
		var penetrated := false
		for _tick in 650:
			await frames(1)
			if absf(zombie.position.x - 7) > 1.35: detour = true
			if absf(zombie.position.x - 7) < 1.25 and absf(zombie.position.z - 3) < 1.25: penetrated = true
			if zombie.state == NormalZombie.State.ATTACK: break
		check(detour and not penetrated and zombie.state == NormalZombie.State.ATTACK, "navigation detours around block side %s without crossing its collider" % side)
		check(absf(zombie.position.y) < 0.12, "zombie remains grounded after detour")
		await clear_enemies()
	# Shelter corner: target inside, zombie behind back wall must use the open front.
	await place_player(Vector3(7, 0.05, 7))
	zombie = spawner.spawn_at(Vector3(7, 0.05, -1))
	player.camera_rig.rotation.y = 0
	var run_start := player.position
	Input.action_press("move_right")
	Input.action_press("sprint")
	await frames(45)
	Input.action_release("move_right")
	Input.action_release("sprint")
	check(player.position.distance_to(run_start) > 3, "player sprints away beside obstacle using movement input")
	await wait_for_attack(zombie)
	check(zombie.state == NormalZombie.State.ATTACK, "navigation refresh follows moving player around obstacle")
	await clear_enemies()
	# Shelter corner: target inside, zombie behind back wall must use the open front.
	await place_player(Vector3(-9, 0.05, -6))
	zombie = spawner.spawn_at(Vector3(-9, 0.05, -11))
	var reached_front := false
	for _tick in 900:
		await frames(1)
		if zombie.position.z > -3.8: reached_front = true
		if zombie.state == NormalZombie.State.ATTACK: break
	check(reached_front and zombie.state == NormalZombie.State.ATTACK, "navigation rounds shelter walls and enters through open front")
	await clear_enemies()
	# Thin wall within melee distance blocks attacks even though detection is distance-only.
	await place_player(Vector3(12, 0.05, 0.55))
	zombie = spawner.spawn_at(Vector3(12, 0.05, -0.55))
	var wall := wall_at(Vector3(12, 1, 0), Vector3(3, 2, 0.1))
	await frames(100)
	check(player.health.current_hp == 100, "melee cannot damage through a thin wall")
	wall.queue_free()
	await clear_enemies()
	# Combat with the real gun and reserve/reload; close range exercises camera offset.
	await place_player(Vector3(12, 0.05, 0))
	zombie = spawner.spawn_at(Vector3(12, 0.05, -4))
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 20)
	key(KEY_Q)
	key(KEY_R)
	await frames(95)
	check(game.weapons.current.current_magazine == 10 and game.weapons.reserve_ammo() == 10, "inventory reload completes during live zombie chase")
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(12)
	aim_at(player, zombie.global_position + Vector3.UP)
	game.debug_controls.set_active(true)
	await capture("phase6_combat")
	var hp_before := zombie.health.current_hp
	mouse(MOUSE_BUTTON_LEFT, true)
	mouse(MOUSE_BUTTON_LEFT, false)
	check(zombie.health.current_hp == hp_before - 20 and game.weapons.last_hit == zombie, "same generic rifle damage receiver hits zombie at close melee range")
	await frames(2)
	check(zombie._flash_time > 0 and game.hud.get_node("Root/Crosshair").hit_time > 0, "zombie hit flash and shared hit marker confirm damage")
	await capture("phase6_hit")
	for _i in 4:
		await frames(13)
		aim_at(player, zombie.global_position + Vector3.UP)
		mouse(MOUSE_BUTTON_LEFT, true)
		mouse(MOUSE_BUTTON_LEFT, false)
	check(zombie.state == NormalZombie.State.DEAD and zombie.health.current_hp == 0, "five rifle hits kill normal zombie")
	check(zombie.collision_layer == 0 and zombie.velocity == Vector3.ZERO and zombie.animation_player.current_animation == zombie.data.death_animation, "death stops motion and collision and plays Death")
	var old_hits := zombie.attacks_landed
	var death_position := zombie.position
	await frames(35)
	check(is_instance_valid(zombie) and zombie.attacks_landed == old_hits and zombie.position == death_position, "death feedback persists without further attack or navigation")
	await capture("phase6_death")
	await frames(45)
	check(not is_instance_valid(zombie) and spawner.zombies.is_empty(), "dead zombie removes safely after delay")
	check(game.weapons.current.current_magazine == 5 and game.weapons.reserve_ammo() == 10, "zombie death leaves ammo accounting intact")
	mouse(MOUSE_BUTTON_RIGHT, false)
	await clear_enemies()
	# Farm and night compatibility, plus pause lifecycle.
	await place_player(Vector3(-9, 0.05, 9))
	zombie = spawner.spawn_at(Vector3(-9, 0.05, 1))
	game.clock.skip_to_night()
	await wait_for_attack(zombie)
	check(zombie.state == NormalZombie.State.ATTACK, "zombie crosses farm plots and chases at night")
	key(KEY_TAB)
	var paused_position := zombie.position
	var paused_hp := player.health.current_hp
	await frames(50)
	check(zombie.position == paused_position and player.health.current_hp == paused_hp, "inventory pause freezes AI and melee timers")
	key(KEY_TAB)
	await clear_enemies()
	game.clock.skip_to_day()
	# Multiple agents: each independently detects, attacks and respects cooldown.
	for count in [3, 5]:
		await place_player(Vector3(13, 0.05, 12))
		var pack: Array[NormalZombie] = []
		for i in count:
			var angle: float = TAU * float(i) / count
			pack.append(spawner.spawn_at(player.position + Vector3(cos(angle), 0, sin(angle)) * 4))
		var elapsed_ticks := 0
		for _tick in 270:
			await frames(1)
			elapsed_ticks += 1
			if player.health.current_hp <= 50: player.health.heal(50)
		var all_attacked := true
		for enemy in pack:
			all_attacked = all_attacked and enemy.attacks_landed > 0 and enemy.attacks_landed <= 4
		check(all_attacked, "%d concurrent zombies detect chase attack with independent cooldowns" % count)
		await capture("phase6_pack%d" % count)
		game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 40)
		mouse(MOUSE_BUTTON_RIGHT, true)
		await frames(10)
		for _shot in 50:
			var closest: NormalZombie
			for enemy in pack:
				if not is_instance_valid(enemy) or enemy.state == NormalZombie.State.DEAD: continue
				if closest == null or enemy.position.distance_to(player.position) < closest.position.distance_to(player.position): closest = enemy
			if closest == null: break
			player.health.heal(100)
			if game.weapons.current.current_magazine == 0:
				key(KEY_R)
				for _part in 5:
					await frames(19)
					player.health.heal(100)
			aim_at(player, closest.global_position + Vector3.UP)
			mouse(MOUSE_BUTTON_LEFT, true)
			mouse(MOUSE_BUTTON_LEFT, false)
			await frames(13)
		mouse(MOUSE_BUTTON_RIGHT, false)
		await frames(80)
		check(spawner.zombies.is_empty(), "%d zombies killed through live rifle and reload loop clean up safely" % count)
		player.health.reset()
	# Existing game-over lifecycle, invalid target and delayed-hit cancellation.
	await place_player(Vector3(12, 0.05, 0))
	zombie = spawner.spawn_at(Vector3(12, 0.05, -1.1))
	player.health.take_damage(90)
	await frames(30)
	check(player.health.is_dead and not player.camera_rig.can_control(), "zombie kills player and existing game over disables controls")
	await frames(100)
	check(zombie.state == NormalZombie.State.IDLE and zombie.attacks_landed == 1, "player death stops chase and attack without repeated hits")
	zombie.bind(null)
	await frames(5)
	check(zombie.state == NormalZombie.State.IDLE, "missing target reference is safe")
	player.health.reset()
	zombie.bind(player)
	await frames(5)
	check(zombie.state == NormalZombie.State.ATTACK, "explicit target rebind reacquires a restored player")
	var hp_at_death := player.health.current_hp
	var deaths := [0]
	zombie.died.connect(func() -> void: deaths[0] += 1)
	zombie.health.take_damage(100)
	zombie.health.take_damage(100)
	await frames(40)
	check(deaths[0] == 1 and player.health.current_hp == hp_at_death, "lethal damage emits death once and cancels pending melee hit")
	var invalid := zombie.data.duplicate() as ZombieData
	invalid.attack_windup = invalid.attack_interval
	check(not invalid.validation_errors().is_empty(), "invalid timing data is rejected")
	print("PHASE_6_ZOMBIE_RESULT failures=", failures)
	quit(1 if failures else 0)
