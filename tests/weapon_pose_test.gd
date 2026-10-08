extends "res://tests/phase_6_zombie_test.gd"
## Production timers plus final modified bone samples. Each weapon must move both
## arms, keep its grasp, recover continuously, and preserve firing/reload rules.
var bone_points: Dictionary = {}

func frames(count: int) -> void:
	for _i in count:
		# Rendered fixtures can lose OS focus when another test window is created.
		if is_instance_valid(player): player.camera_rig._window_focused = true
		await physics_frame

func final_pose() -> void:
	var skeleton: Skeleton3D = game.weapons.pose_driver.get_skeleton()
	for name in ["Torso","Middle1.R","Middle1.L","Middle2.R","Middle3.R","LowerArm.L","Middle2.L"]:
		bone_points[name] = skeleton.global_transform*skeleton.get_bone_global_pose(skeleton.find_bone(name)).origin

func free_wrist_alignment() -> float:
	var forearm: Vector3 = (bone_points["Middle1.L"]-bone_points["LowerArm.L"]).normalized()
	var hand: Vector3 = (bone_points["Middle2.L"]-bone_points["Middle1.L"]).normalized()
	return forearm.dot(hand)

func equip_pose_weapon(id: StringName) -> void:
	mouse(MOUSE_BUTTON_RIGHT,false)
	for slot in game.equipment.weapon_slot_count: game.equipment.unequip_weapon(slot)
	var item: ItemData = game.catalog.get_item(id)
	game.inventory.add_item(item)
	check(game.equipment.equip_weapon(0,item),"owned weapon equips: "+String(id))
	player.camera_rig.pitch_pivot.rotation.x = 0
	player.camera_rig.rotation.y = 0
	player.visual.rotation.y = PI
	await frames(30)

func run() -> void:
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	player = game.player
	game.clock.paused = true
	game.waves.enabled = false
	game.debug_controls.set_active(false)
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*.03)
	if game.gameplay_mode.is_farming(): key(KEY_Q)
	var pose: RiflePose = game.weapons.pose_driver
	pose.modification_processed.connect(final_pose)
	var spans := {}
	for id in [&"wooden_bat",&"sword",&"knife"]:
		await equip_pose_weapon(id)
		var state: WeaponRuntime = game.weapons.current
		var tip: Node3D = game.weapons.visual.get_node("HitTip")
		var ready_right: Vector3 = bone_points["Middle1.R"]-bone_points["Torso"]
		var ready_left: Vector3 = bone_points["Middle1.L"]-bone_points["Torso"]
		var previous := tip.global_position
		var max_step := 0.0
		var max_right := 0.0
		var max_left := 0.0
		var max_grip := 0.0
		var committed_at := -1.0
		var min_wrist_alignment := 1.0
		var max_free_height := -10.0
		if not state.data.two_handed:
			check(ready_left.y < -0.15,"free arm rests beside waist rather than floating at chest: "+String(id))
			check(free_wrist_alignment() > .82,"resting free hand follows forearm rather than a grip frame: "+String(id))
		check(game.weapons.try_fire(),"production swing starts: "+String(id))
		for frame in int(ceil(state.data.melee_swing_duration*60))+12:
			await frames(1)
			max_step = maxf(max_step,previous.distance_to(tip.global_position))
			previous = tip.global_position
			max_right = maxf(max_right,ready_right.distance_to(bone_points["Middle1.R"]-bone_points["Torso"]))
			max_left = maxf(max_left,ready_left.distance_to(bone_points["Middle1.L"]-bone_points["Torso"]))
			max_grip = maxf(max_grip,maxf(pose.right_error,pose.left_error))
			if state.swing_hit_committed and committed_at<0: committed_at=state.swing_elapsed
			if not state.data.two_handed:
				min_wrist_alignment = minf(min_wrist_alignment,free_wrist_alignment())
				max_free_height = maxf(max_free_height,bone_points["Middle1.L"].y-bone_points["Torso"].y)
		spans[id] = max_right
		print("WEAPON_SWING ",id," hand_movement=",max_right,"/",max_left," tip_step=",max_step," grip_error=",max_grip," commit=",committed_at)
		check(max_right>.10 and max_left>.035,"both arms participate in the swing: "+String(id))
		check(max_grip<.05,"grasp and free guard remain reachable: "+String(id))
		check(max_step<.60,"windup/contact/recovery have no pose teleport: "+String(id))
		check(absf(committed_at-state.data.melee_hit_delay)<.018,"contact uses unchanged damage timer: "+String(id))
		check(not state.is_swinging and player.visual.action_weight==0,"recovers by original completion: "+String(id))
		if not state.data.two_handed:
			check(min_wrist_alignment > .82,"free wrist retains natural alignment through attack: "+String(id))
			check(max_free_height < -.05,"counterbalance stays below chest through attack: "+String(id))
		await capture("pose_"+String(id)+"_ready")
	check(absf(float(spans[&"sword"])-float(spans[&"knife"]))>.08,"sword sweep and compact knife action have distinct hand travel")
	for id in [&"basic_rifle",&"pistol",&"smg",&"marksman_rifle"]:
		await equip_pose_weapon(id)
		var state: WeaponRuntime = game.weapons.current
		check(state.data.two_handed,"ranged stance uses a support hand: "+String(id))
		mouse(MOUSE_BUTTON_RIGHT,true)
		for pitch in [-60,0,44]:
			player.camera_rig.pitch_pivot.rotation.x = deg_to_rad(pitch)
			await frames(30)
			var direction: Vector3 = (player.aim_ray.aim_point-game.weapons.muzzle.global_position).normalized()
			check(pose.right_error<.04 and pose.left_error<.04,"both grips reachable at pitch "+str(pitch)+": "+String(id))
			print("WEAPON_AIM ",id," pitch=",pitch," dot=",game.weapons.get_socket().global_basis.z.dot(direction)," stock_error=",pose.shoulder_error)
			check(game.weapons.get_socket().global_basis.z.dot(direction)>.95,"barrel follows crosshair at pitch "+str(pitch)+": "+String(id))
			if id!=&"pistol": check(pose.shoulder_error<.03,"stock rests on shoulder at pitch "+str(pitch)+": "+String(id))
		player.camera_rig.pitch_pivot.rotation.x = 0
		await frames(30)
		await capture("pose_"+String(id)+"_shoulder")
		game.inventory.add_item(state.data.ammo_type,state.data.magazine_size)
		var reserve_before: int = game.weapons.reserve_ammo()
		check(game.weapons.start_reload(),"original reload starts: "+String(id))
		await frames(int(ceil(state.data.reload_time*30)))
		check(state.current_magazine==0 and pose.reload_hand_weight>.95 and pose.left_error<.06,"magazine hand moves without early ammo: "+String(id))
		await frames(int(ceil(state.data.reload_time*30))+2)
		check(not state.is_reloading and state.current_magazine==state.data.magazine_size and game.weapons.reserve_ammo()==reserve_before-state.data.magazine_size,"original reload transfer completes: "+String(id))
		var local_muzzle: Transform3D = game.weapons.muzzle.transform
		var rounds := state.current_magazine
		check(game.weapons.try_fire() and state.current_magazine==rounds-1,"unchanged shot consumes one round: "+String(id))
		await frames(3)
		check(game.weapons.muzzle.transform==local_muzzle and pose.right_error<.05 and pose.left_error<.05,"recoil retains grip and canonical muzzle: "+String(id))
		await frames(25)
	print("WEAPON_POSE_RESULT failures=",failures)
	quit(1 if failures else 0)
