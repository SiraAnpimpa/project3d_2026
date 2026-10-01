extends "res://tests/phase_6_zombie_test.gd"

func check_hold(label: String) -> void:
	var pose: RiflePose=game.weapons.pose_driver
	print("HOLD_ERROR ",label," right=",pose.right_error," left=",pose.left_error)
	check(pose.right_error<0.04 and pose.left_error<0.04,"bounded two-hand grip while "+label)
	check(player.rotation.x==0 and player.rotation.z==0 and game.weapons.get_socket().global_basis.get_scale().distance_to(Vector3.ONE)<0.001,"presentation leaves capsule upright and socket at unit scale")

func run() -> void:
	root.size=Vector2i(1280,720)
	set_meta("normal_play",true)
	game=load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene=game
	await frames(30)
	player=game.player
	game.clock.paused=true
	game.debug_controls.set_active(false)
	game.hud.hide()
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*0.03)
	player.camera_rig.rotation.y=0
	player.visual.rotation.y=PI
	var camera:=Camera3D.new()
	game.add_child(camera)
	camera.fov=42
	camera.current=true
	for action in ["","move_forward","sprint"]:
		if action=="sprint": Input.action_press("move_forward")
		if action!="": Input.action_press(action)
		await frames(30)
		camera.position=player.position+Vector3(2,1.7,-2.6)
		camera.look_at(player.position+Vector3.UP*0.85)
		await capture("character_"+("idle" if action=="" else action))
		check(player.visual.current_state==(&"Idle" if action=="" else (&"Run" if action=="sprint" else &"Walk")),"actual locomotion selects correct existing state")
		for movement in ["move_forward","sprint"]: Input.action_release(movement)
		await frames(15)
	key(KEY_Q)
	for aiming in [false,true]:
		mouse(MOUSE_BUTTON_RIGHT,aiming)
		await frames(20)
		camera.position=player.position+Vector3(2,1.7,-2.6)
		camera.look_at(player.position+Vector3.UP*0.85)
		check_hold("rifle aim" if aiming else "rifle low ready")
		await capture("character_rifle_aim" if aiming else "character_rifle_ready")
	mouse(MOUSE_BUTTON_RIGHT,false)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	await frames(15)
	check_hold("bat ready")
	await capture("character_bat_ready")
	mouse(MOUSE_BUTTON_LEFT,true)
	mouse(MOUSE_BUTTON_LEFT,false)
	await frames(5)
	check_hold("bat windup")
	await capture("character_bat_windup")
	await frames(5)
	check_hold("bat sweep")
	await capture("character_bat_sweep")
	await frames(7)
	check_hold("bat followthrough")
	await capture("character_bat_followthrough")
	await frames(20)
	check_hold("bat recovered")
	check(not game.weapons.current.is_swinging and player.visual.current_clip==&"CharacterArmature|Idle","melee finishes and returns to existing relaxed clip with bat pose")
	# Empty the shared slots; no stale gun/melee visual should remain.
	game.equipment.unequip_weapon(0)
	game.equipment.unequip_weapon(1)
	await frames(4)
	check(game.weapons.visual==null and not player.visual.combat_ready,"unequipping both owned weapons returns unarmed stance")
	print("GAMEPLAY_CHARACTER_CAPTURE_RESULT failures=",failures)
	quit(1 if failures else 0)
