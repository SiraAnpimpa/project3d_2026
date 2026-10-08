extends "res://tests/phase_6_zombie_test.gd"
## Production input plus pose bounds. No visual callback is allowed to advance gameplay.
var samples: Array = []

func run() -> void:
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	player = game.player
	# This presentation regression exercises the automatic Assault Rifle explicitly.
	game.inventory.add_item(game.catalog.get_item(&"basic_rifle"))
	game.equipment.equip_weapon(0,game.catalog.get_item(&"basic_rifle"))
	game.clock.paused = true
	game.waves.enabled = false
	game.debug_controls.set_active(false)
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*0.03)
	player.camera_rig.rotation.y = 0
	player.visual.rotation.y = PI
	var visual: PlayerVisual = player.visual
	var pose: RiflePose = game.weapons.pose_driver
	check(visual.animation_tree.active and not visual.animation_player.is_playing(),"AnimationTree exclusively owns imported clip playback")
	var graph := visual.animation_tree.tree_root as AnimationNodeBlendTree
	var slash := visual.animation_player.get_animation("CharacterArmature|Slash")
	var filter := graph.get_node("Action") as AnimationNodeBlend2
	var lower_filtered := 0
	var upper_filtered := 0
	for i in slash.get_track_count():
		var path := slash.track_get_path(i)
		if not filter.is_path_filtered(path): continue
		var bone := String(path.get_subname(0))
		if bone.begins_with("Foot") or bone.begins_with("Body") or "Leg" in bone: lower_filtered += 1
		else: upper_filtered += 1
	check(upper_filtered > 5 and lower_filtered == 0,"bat action filters upper rotations and leaves locomotion legs/root intact")
	Input.action_press("move_forward")
	await frames(30)
	check(player.velocity.length()>3.9 and visual.locomotion_speed>3.8,"walk blending follows actual4m/s movement without changing speed")
	Input.action_press("sprint")
	await frames(30)
	check(player.is_sprinting and player.velocity.length()>6.9 and visual.locomotion_speed>6.8,"run blend follows original7m/s controller")
	for action in ["move_forward","sprint"]: Input.action_release(action)
	await frames(30)
	check(visual.locomotion_speed<0.05 and visual.current_state==&"Idle","deceleration blend settles to idle")
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*0.03)
	key(KEY_Q)
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(20)
	check(pose.hold_weight==1 and pose.right_error<0.025 and pose.left_error<0.025,"two-arm pose reaches ready/aim grips after a bounded raise")
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),40)
	check(game.weapons.start_reload(),"original reload timer starts")
	await frames(44)
	check(game.weapons.current.current_magazine==0 and pose.reload_hand_weight>0.95,"support hand reaches magazine without granting early ammunition")
	await frames(50)
	check(game.weapons.current.current_magazine==25 and game.weapons.reserve_ammo()==15 and not game.weapons.current.is_reloading,"reload remains1.5s and transfers exactly25 rounds")
	var muzzle_local: Transform3D = game.weapons.muzzle.transform
	var camera_yaw := player.camera_rig.rotation
	var camera_pitch := player.camera_rig.pitch_pivot.rotation
	var count: int = game.weapons.shots_fired
	check(game.weapons.try_fire() and game.weapons.shots_fired==count+1,"shot still commits immediately through unchanged controller")
	await frames(3)
	check(pose.visual_recoil>0.01 and pose.visual_recoil<0.10,"visual recoil spring produces a bounded shoulder impulse")
	check(game.weapons.muzzle.transform==muzzle_local and player.camera_rig.rotation==camera_yaw and player.camera_rig.pitch_pivot.rotation==camera_pitch,"extra presentation recoil changes neither muzzle marker nor aim camera")
	await frames(24)
	check(absf(pose.visual_recoil)<0.0002 and pose.recoil==0,"shot spring and existing kick settle without drift")
	# A sustained burst must keep the original five-shot cadence.
	count = game.weapons.shots_fired
	mouse(MOUSE_BUTTON_LEFT,true)
	await frames(54)
	mouse(MOUSE_BUTTON_LEFT,false)
	check(game.weapons.shots_fired-count==5,"automatic burst still fires five shots in0.9s")
	await frames(24)
	check(absf(pose.visual_recoil)<0.001,"repeated shot feedback cannot accumulate permanent recoil")
	mouse(MOUSE_BUTTON_RIGHT,false)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	await frames(20)
	var start_tip := game.weapons.visual.get_node("HitTip") as Node3D
	var previous := start_tip.global_position
	var max_tip_step := 0.0
	var max_grip := 0.0
	var weights: Array = []
	mouse(MOUSE_BUTTON_LEFT,true)
	mouse(MOUSE_BUTTON_LEFT,false)
	for i in 34:
		await frames(1)
		var tip: Vector3 = start_tip.global_position
		max_tip_step = maxf(max_tip_step,previous.distance_to(tip))
		max_grip = maxf(max_grip,maxf(pose.left_error,pose.right_error))
		weights.append(visual.action_weight)
		samples.append({"frame":i,"elapsed":game.weapons.current.swing_elapsed,"tip":[tip.x,tip.y,tip.z],"action_weight":visual.action_weight,"left_error":pose.left_error,"right_error":pose.right_error})
		previous = tip
	check(max_tip_step<0.44,"bat windup/contact/recovery has no initial or final teleport")
	check(max_grip<0.04,"both hands remain on bat through the entire sweep")
	check(weights.max()>0.95 and visual.action_weight==0 and not game.weapons.current.is_swinging,"upper action blends out by the original0.48s completion")
	print("BAT_POSE_BOUNDS max_tip_step_m=",max_tip_step," max_grip_error_m=",max_grip)
	# Moving action leaves both legs in the original continuous locomotion graph.
	await frames(30)
	Input.action_press("move_forward")
	await frames(20)
	mouse(MOUSE_BUTTON_LEFT,true)
	mouse(MOUSE_BUTTON_LEFT,false)
	await frames(8)
	check(game.weapons.current.is_swinging and visual.locomotion_speed>3.8 and player.velocity.length()>3.9,"bat animation layers over movement without a root-motion lock")
	Input.action_release("move_forward")
	game.inventory_ui.set_open(true)
	await frames(4)
	check(not game.weapons.current.is_swinging and visual.action_weight==0,"bag cancellation clears pending visual action with the production runtime")
	game.inventory_ui.set_open(false)
	await frames(20)
	var hp := player.health.current_hp
	player.health.take_damage(10)
	await frames(4)
	check(player.health.current_hp==hp-10 and visual.hurt_weight>0.2 and Engine.time_scale==1.0,"nonfatal damage triggers upper hit reaction without stun or time scaling")
	check(pose.left_error<0.04 and pose.right_error<0.04,"hit reaction keeps both hands on equipped grips")
	await frames(30)
	check(visual.hurt_weight==0,"hit reaction returns fully to locomotion/ready")
	player.health.heal(10)
	await frames(2)
	check(visual.hurt_weight==0,"healing cannot trigger a damage flinch")
	# Both slots removed: no stale arm hold or action remains.
	game.equipment.unequip_weapon(0)
	game.equipment.unequip_weapon(1)
	await frames(15)
	check(game.weapons.visual==null and pose.hold_weight==0 and not visual.combat_ready,"unequip blends back to unarmed without a stale weapon pose")
	player.health.take_damage(1000)
	await frames(4)
	check(visual.current_state==&"Death" and visual.hurt_weight==0 and not game.weapons.try_fire(),"death overrides action/hurt and gameplay remains blocked")
	var file := FileAccess.open("user://animation_feel_samples.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(samples,"  "))
	print("ANIMATION_FEEL_RESULT failures=",failures)
	quit(1 if failures else 0)
