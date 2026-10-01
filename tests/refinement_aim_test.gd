extends "res://tests/phase_6_zombie_test.gd"

func run() -> void:
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	game.clock.paused = true
	game.debug_controls.set_active(false)
	await place_player(Vector3(12,0.05,7))
	key(KEY_Q)
	mouse(MOUSE_BUTTON_RIGHT,true)
	var driver: RiflePose = game.weapons.pose_driver
	for pitch in [-60,-30,0,30,44]:
		player.camera_rig.pitch_pivot.rotation.x = deg_to_rad(pitch)
		player.camera_rig.update_pose(0)
		await frames(30)
		var direction: Vector3 = (player.aim_ray.aim_point-game.weapons.muzzle.global_position).normalized()
		var aligned: float = game.weapons.get_socket().global_basis.z.dot(direction)
		print("POSE_AIM pitch=",pitch," dot=",aligned," errors=",driver.right_error,"/",driver.left_error)
		check(player.rotation.x == 0 and player.rotation.z == 0, "vertical aim leaves physics capsule upright")
		check(driver.right_error < 0.04 and driver.left_error < 0.04, "bounded vertical pose keeps hands on grips")
		check(aligned > 0.95, "visible barrel follows crosshair direction within constrained range")
	player.camera_rig.pitch_pivot.rotation.x = 0
	for action in ["move_left","move_right","move_backward"]:
		Input.action_press(action)
		await frames(45)
		check(player.visual.global_basis.z.dot(-player.camera_rig.global_basis.z)>0.99, "upper body faces target during " + action)
		check(absf(driver.leg_yaw) > 0.8 if action != "move_backward" else player.visual.animation_player.speed_scale < 0, "lower-body pose matches " + action)
		check(driver.left_error < 0.04 and driver.right_error < 0.04, "moving aim keeps both grips")
		Input.action_release(action)
	await frames(20)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),20)
	check(game.weapons.start_reload(), "reload starts with existing production timer")
	await frames(44)
	check(driver.reload_weight > 0.9 and game.weapons.current.current_magazine == 0, "procedural magazine hand dip follows reload midpoint without early ammo")
	await capture("pose_reload")
	await frames(50)
	check(not game.weapons.current.is_reloading and game.weapons.current.current_magazine == 10 and driver.reload_weight == 0, "reload pose and ammo finish together at1.5s")
	var before: int = game.weapons.shots_fired
	check(game.weapons.try_fire() and game.weapons.shots_fired == before+1 and driver.recoil == 1, "shot applies immediately and starts presentation recoil")
	await frames(2)
	await capture("pose_shot")
	await frames(15)
	check(driver.recoil == 0, "visual recoil recovers before next5Hz shot")
	# Synthetic point inside the barrel: presentation holds forward, never folds back.
	player.aim_ray.aim_point = player.position + Vector3(0,0.8,0)
	driver.update_socket()
	check(game.weapons.get_socket().global_basis.z.dot(-player.camera_rig.global_basis.z)>0.8, "close target has a bounded forward weapon pose")
	print("REFINEMENT_AIM_RESULT failures=",failures)
	quit(1 if failures else 0)
