extends "res://tests/phase_6_zombie_test.gd"

func run() -> void:
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	# This older fixture exercises a rifle-only loadout; Day 1 now also owns a bat.
	game.equipment.unequip_weapon(1)
	game.clock.paused = true
	game.debug_controls.set_active(false)
	await place_player(Vector3(13,0.05,6))
	check(not game.weapons.visual.visible, "Farming stows rifle without forcing seed/medicine hand models")
	key(KEY_Q)
	for action in ["", "move_forward", "move_left", "move_backward"]:
		if not action.is_empty(): Input.action_press(action)
		await frames(25)
		var driver: RiflePose = game.weapons.pose_driver
		print("POSE_GRIP errors=",driver.right_error,"/",driver.left_error)
		check(driver.right_error < 0.025 and driver.left_error < 0.025, "both wrists reach rifle grips while " + action)
		check(game.weapons.get_socket().global_basis.get_scale().distance_to(Vector3.ONE) < 0.001, "socket excludes imported110x skeleton scale")
		if not action.is_empty(): Input.action_release(action)
	await frames(20)
	var old: Node3D = game.weapons.visual
	game.equipment.unequip_weapon(0)
	await frames(4)
	check(not is_instance_valid(old) and game.weapons.visual == null and not player.visual.combat_ready, "unequip removes old visual and returns unarmed stance")
	game.equipment.equip_weapon(1,game.catalog.get_item(&"basic_rifle"))
	game.equipment.cycle_weapon(1)
	await frames(10)
	check(is_instance_valid(game.weapons.visual) and game.weapons.visual.visible, "owned rifle attaches in newly selected slot without delay")
	key(KEY_Q)
	await frames(12)
	check(not game.weapons.visual.visible and not player.visual.combat_ready, "mode switch restores ordinary farming pose")
	print("REFINEMENT_HOLDING_RESULT failures=",failures)
	quit(1 if failures else 0)
