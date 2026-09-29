extends "res://tests/phase_3_integration_test.gd"


func mouse(button: MouseButton, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = down
	root.push_input(event)


func aim_at(player: PlayerController, point: Vector3) -> void:
	var rig := player.camera_rig
	for _i in 15:
		var offset := point - rig.camera.global_position
		rig.rotation.y = atan2(-offset.x, -offset.z)
		rig.pitch_pivot.rotation.x = atan2(offset.y, Vector2(offset.x, offset.z).length())
		rig.update_pose(1.0)
	player.aim_ray.update_aim()


func wall_at(position: Vector3, size: Vector3) -> StaticBody3D:
	var wall := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	wall.add_child(collider)
	root.add_child(wall)
	wall.position = position
	return wall


func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	var player: PlayerController = game.player
	var inventory: Inventory = game.inventory
	var weapons: WeaponController = game.weapons
	var equipment: EquipmentLoadout = game.equipment
	var mode: GameplayModeController = game.gameplay_mode
	var rifle := weapons.current
	var dummy: TargetDummy = game.get_node("MainWorld/TargetDummy")
	game.debug_controls.set_active(false)
	game.clock.set_process(false)
	check(weapons.validation_errors(game.catalog).is_empty() and rifle != null and equipment.selected_weapon_slot == 0, "starter rifle data validates and equips slot one")
	check(inventory.has_item(&"basic_rifle") and rifle.current_magazine == 0 and weapons.reserve_ammo() == 0, "owned starter rifle begins empty with no free reserve ammo")
	check(weapons.visual != null and weapons.muzzle != null and not weapons.visual.visible, "weapon visual and muzzle load, stowed in Farming")
	mouse(MOUSE_BUTTON_LEFT, true)
	mouse(MOUSE_BUTTON_LEFT, false)
	check(weapons.shots_fired == 0, "Farming LMB cannot shoot")
	# Full production resource loop with E planting, E harvesting and UI crafting.
	var ids := [&"seed_lead", &"seed_paper", &"seed_copper"]
	for index in ids.size():
		var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(index)
		inventory.select_seed(ids[index])
		player.position = plot.position + Vector3(0, 0.05, 1.1)
		player.velocity = Vector3.ZERO
		await frames(8)
		key(KEY_E)
		check(plot.state == FarmPlot.State.PLANTED, "E plants ammunition crop %d" % index)
	game.clock.advance_game_minutes(50)
	for index in ids.size():
		var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(index)
		player.position = plot.position + Vector3(0, 0.05, 1.1)
		player.velocity = Vector3.ZERO
		await frames(8)
		key(KEY_E)
		check(plot.state == FarmPlot.State.EMPTY, "E harvests ammunition crop %d" % index)
	player.position = Vector3(-2, 0.05, 0.7)
	await frames(10)
	key(KEY_E)
	await frames(2)
	click_button(game.crafting_ui.craft_button)
	check(inventory.get_item_amount(&"basic_ammo") == 10, "Workbench UI crafts ten Basic Ammo from harvested materials")
	key(KEY_ESCAPE)
	key(KEY_Q)
	player.position = Vector3(3, 0.05, 2)
	player.velocity = Vector3.ZERO
	await frames(10)
	check(weapons.visual.visible and not mode.is_farming(), "Combat displays equipped rifle")
	key(KEY_R)
	await frames(30)
	check(rifle.is_reloading and rifle.current_magazine == 0 and weapons.reserve_ammo() == 10 and game.hud.ammo_label.text.contains("RELOADING"), "R starts timed reload and HUD; ammo remains in inventory until completion")
	for _i in 10: key(KEY_R)
	await frames(70)
	check(not rifle.is_reloading and rifle.current_magazine == 10 and weapons.reserve_ammo() == 0, "reload spam completes once and transfers exactly ten crafted rounds")
	check(not weapons.start_reload(), "full magazine rejects reload")
	mouse(MOUSE_BUTTON_LEFT, true)
	mouse(MOUSE_BUTTON_LEFT, false)
	check(weapons.shots_fired == 0, "Combat requires RMB aim before firing")
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(30)
	aim_at(player, dummy.global_position + Vector3.UP)
	await frames(3)
	check(player.camera_rig.is_aiming and player.aim_ray.hit_collider == dummy, "existing camera center ray aims at dummy")
	game.hud.show_message("")
	await capture("phase5_aim")
	mouse(MOUSE_BUTTON_LEFT, true)
	mouse(MOUSE_BUTTON_LEFT, false)
	check(dummy.health.current_hp == 80 and rifle.current_magazine == 9 and weapons.shots_fired == 1, "LMB muzzle hitscan applies twenty damage and consumes one magazine round")
	for _i in 10:
		mouse(MOUSE_BUTTON_LEFT, true)
		mouse(MOUSE_BUTTON_LEFT, false)
	check(weapons.shots_fired == 1 and dummy.health.current_hp == 80, "rapid LMB presses cannot bypass fire cooldown")
	check(weapons.last_shot_origin.is_equal_approx(weapons.muzzle.global_position) and weapons.last_shot_origin.distance_to(player.camera_rig.camera.global_position) > 1, "shot originates at weapon muzzle")
	check(game.hud.get_node("Root/Crosshair").hit_time > 0 and dummy._flash_remaining > 0, "damage produces hit marker and dummy flash")
	await capture("phase5_hit")
	for _i in 4:
		await frames(13)
		mouse(MOUSE_BUTTON_LEFT, true)
		mouse(MOUSE_BUTTON_LEFT, false)
	await frames(2)
	check(not is_instance_valid(dummy) and rifle.current_magazine == 5, "five shots destroy the hundred-HP dummy")
	await capture("phase5_destroyed")
	check(rifle.data.magazine_size == 10 and rifle.data.damage == 20, "runtime magazine never modifies WeaponData")
	# Partial reload, cancellation and empty feedback.
	rifle.current_magazine = 0
	inventory.add_item(rifle.data.ammo_type, 3)
	key(KEY_R)
	await frames(95)
	check(rifle.current_magazine == 3 and weapons.reserve_ammo() == 0, "partial reserve reload transfers only available rounds")
	check(not weapons.start_reload(), "zero reserve rejects reload")
	inventory.add_item(rifle.data.ammo_type, 10)
	key(KEY_R)
	await frames(20)
	key(KEY_Q)
	await frames(95)
	check(not rifle.is_reloading and rifle.current_magazine == 3 and weapons.reserve_ammo() == 10, "switching to Farming cancels reload without consuming ammo")
	key(KEY_Q)
	key(KEY_R)
	await frames(95)
	check(rifle.current_magazine == 10 and weapons.reserve_ammo() == 3, "reload tops up only missing magazine capacity")
	# A second data definition exercises semi-auto, slot switching and per-gun memory.
	var pistol_item := ItemData.new()
	pistol_item.id = &"test_pistol"
	pistol_item.display_name = "Test Pistol"
	pistol_item.item_type = ItemData.ItemType.WEAPON
	pistol_item.max_stack = 1
	var pistol := rifle.data.duplicate() as WeaponData
	pistol.weapon_id = pistol_item.id
	pistol.weapon_item = pistol_item
	pistol.display_name = pistol_item.display_name
	pistol.automatic = false
	pistol.magazine_size = 6
	game.catalog.items.append(pistol_item)
	weapons.definitions.append(pistol)
	inventory.add_item(pistol_item)
	equipment.equip_weapon(1, pistol_item)
	rifle.current_magazine = 4
	weapons.start_reload()
	equipment.cycle_weapon(1)
	await frames(2)
	check(weapons.current.data == pistol and not rifle.is_reloading and weapons.reserve_ammo() == 3, "switching weapon cancels previous reload and selects second data definition")
	weapons.current.current_magazine = 2
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(20)
	mouse(MOUSE_BUTTON_LEFT, true)
	await frames(40)
	check(weapons.current.current_magazine == 1, "semi-auto held LMB fires once")
	mouse(MOUSE_BUTTON_LEFT, false)
	equipment.cycle_weapon(1)
	check(weapons.current == rifle and rifle.current_magazine == 4, "switch back remembers rifle magazine")
	equipment.cycle_weapon(1)
	check(weapons.current.current_magazine == 1, "second weapon retains its own magazine")
	equipment.cycle_weapon(1)
	# Menus stop held fire and cancel reload; close does not resume stale input.
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(20)
	mouse(MOUSE_BUTTON_LEFT, true)
	key(KEY_TAB)
	var shots := weapons.shots_fired
	await frames(30)
	mouse(MOUSE_BUTTON_LEFT, false)
	key(KEY_TAB)
	await frames(30)
	check(weapons.shots_fired == shots and not weapons._fire_held and not player.camera_rig.is_aiming, "inventory blocks shooting and closing does not resume held fire")
	key(KEY_R)
	key(KEY_ESCAPE)
	await frames(95)
	check(not rifle.is_reloading and weapons.reserve_ammo() == 3, "Pause cancels reload without moving reserve ammo")
	key(KEY_ESCAPE)
	player.position = Vector3(-2, 0.05, 0.7)
	player.velocity = Vector3.ZERO
	await frames(10)
	key(KEY_E)
	mouse(MOUSE_BUTTON_RIGHT, true)
	mouse(MOUSE_BUTTON_LEFT, true)
	key(KEY_R)
	await frames(10)
	mouse(MOUSE_BUTTON_LEFT, false)
	check(game.crafting_ui.is_open and weapons.shots_fired == shots and not rifle.is_reloading and not player.camera_rig.is_aiming, "Workbench blocks aim, fire and reload")
	key(KEY_ESCAPE)
	# Test true muzzle occlusion, including barrel penetrating a close wall.
	player.position = Vector3(3, 0.05, 2)
	player.velocity = Vector3.ZERO
	dummy = load("res://scenes/combat/TargetDummy.tscn").instantiate()
	game.add_child(dummy)
	dummy.position = Vector3(3, 0, -8)
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(30)
	aim_at(player, dummy.position + Vector3.UP)
	await frames(5)
	rifle.current_magazine = 10
	var wall := wall_at(Vector3(3, 1.5, -2), Vector3(4, 3, 0.2))
	await frames(3)
	weapons.try_fire()
	check(weapons.last_hit == wall and dummy.health.current_hp == 100, "wall between muzzle and target receives hit")
	wall.queue_free()
	await frames(15)
	aim_at(player, dummy.position + Vector3.UP)
	weapons.update_weapon_pose()
	var safety_origin := player.global_position + Vector3.UP * 1.2
	wall = wall_at(safety_origin.lerp(weapons.muzzle.global_position, 0.55), Vector3(0.2, 0.6, 0.12))
	await frames(3)
	player.aim_ray.update_aim()
	check(player.aim_ray.hit_collider == dummy, "camera offset sees dummy past close muzzle obstruction")
	weapons.try_fire()
	check(weapons.last_hit == wall and dummy.health.current_hp == 100, "body-to-muzzle safety ray stops barrel-through-wall shooting")
	wall.queue_free()
	await frames(15)
	aim_at(player, dummy.position + Vector3.UP)
	weapons.update_weapon_pose()
	wall = wall_at(weapons.muzzle.global_position.lerp(dummy.position + Vector3.UP, 0.2), Vector3(0.18, 0.18, 0.12))
	await frames(3)
	player.aim_ray.update_aim()
	check(player.aim_ray.hit_collider == dummy, "camera sees target while a separate obstacle blocks the muzzle ray")
	weapons.try_fire()
	check(weapons.last_hit == wall and dummy.health.current_hp == 100, "muzzle-to-target ray hits offset obstruction")
	wall.queue_free()
	await frames(15)
	for z in [-0.5, -18.0]:
		dummy.position.z = z
		await frames(3)
		aim_at(player, dummy.position + Vector3.UP)
		var hp := dummy.health.current_hp
		weapons.try_fire()
		check(dummy.health.current_hp == hp - 20, "muzzle converges on crosshair target at z=%.1f" % z)
		await frames(15)
	var original_data := rifle.data
	var short_range := original_data.duplicate() as WeaponData
	short_range.range_meters = 2.0
	rifle.data = short_range
	var hp_before := dummy.health.current_hp
	weapons.try_fire()
	check(dummy.health.current_hp == hp_before and weapons.last_shot_origin.distance_to(weapons.last_shot_end) <= 2.001, "weapon range is measured from muzzle and limits distant damage")
	rifle.data = original_data
	await frames(15)
	# Nonintegral cadence must agree at different update rates.
	weapons.set_physics_process(false)
	var rate_data := rifle.data.duplicate() as WeaponData
	rate_data.fire_rate = 7.0
	rate_data.magazine_size = 100
	var counts: Array[int] = []
	for rate in [30, 120]:
		rifle.data = rate_data
		rifle.current_magazine = 100
		rifle.fire_cooldown = 0
		weapons._fire_held = true
		var before := weapons.shots_fired
		weapons.try_fire()
		for _i in int(rate * 0.9): weapons._physics_process(1.0 / rate)
		counts.append(weapons.shots_fired - before)
	check(counts == [7, 7], "automatic fire rate agrees at 30 and 120 updates per second")
	weapons._fire_held = false
	weapons.set_physics_process(true)
	rifle.current_magazine = 0
	rifle.fire_cooldown = 0
	check(not weapons.try_fire() and game.hud.toast_label.text.contains("Empty magazine"), "empty magazine provides feedback and cannot go negative")
	var invalid := WeaponData.new()
	invalid.fire_rate = 0
	check(not invalid.validation_errors().is_empty(), "invalid weapon data reports actionable errors")
	var reserve_before := weapons.reserve_ammo()
	game.debug_controls.execute(&"debug_give_ammo")
	check(weapons.reserve_ammo() == reserve_before, "disabled debug cannot grant ammunition")
	game.debug_controls.set_active(true)
	game.debug_controls.execute(&"debug_give_ammo")
	check(weapons.reserve_ammo() == reserve_before + 30, "enabled debug grants a finite thirty-round stack")
	game.debug_controls.set_active(false)
	equipment.unequip_weapon(0)
	equipment.unequip_weapon(1)
	await frames(2)
	check(weapons.current == null and weapons.visual == null and not weapons.try_fire(), "unequipping all slots removes weapon visual and safely disables fire")
	equipment.equip_weapon(0, game.starter_weapon)
	check(weapons.current == rifle and rifle.current_magazine == 0, "reequip restores existing runtime without refilling magazine")
	player.health.die()
	check(not weapons.try_fire() and not weapons.start_reload(), "death blocks weapon actions")
	key(KEY_R)
	await frames(15)
	game = current_scene as Node3D
	check(game.weapons.current.current_magazine == 0 and game.equipment.selected_weapon_slot == 0 and not paused, "R still restarts after death with a fresh starter rifle")
	print("PHASE_5_WEAPON_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
