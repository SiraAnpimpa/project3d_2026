extends "res://tests/phase_6_zombie_test.gd"

func run() -> void:
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	player = game.player
	game.clock.paused = true
	game.debug_controls.set_active(false)
	var skeleton := player.visual.find_child("Skeleton3D",true,false) as Skeleton3D
	var foot := skeleton.find_bone("Foot.L")
	var rows: Array = []
	var settings: Array = [{"tag":"current","walk":player.visual.walk_cycle_speed,"run":player.visual.run_cycle_speed}]
	if "--cadence-audit" in OS.get_cmdline_user_args():
		settings = []
		for speed in [7.0,6.0,5.5,5.0,4.5,4.0,3.5,3.24]:
			settings.append({"tag":"candidate_"+str(speed),"walk":4.0 if speed==7.0 else 1.31,"run":speed})
	for setting in settings:
		player.visual.walk_cycle_speed = setting.walk
		player.visual.run_cycle_speed = setting.run
		await sample_stride(skeleton,foot,setting.tag,rows)
	var file := FileAccess.open("user://gameplay_stride_measure.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(rows,"  "))
	print("STRIDE_MEASURE ",JSON.stringify(rows))
	print("GAMEPLAY_STRIDE_MEASURE_RESULT failures=",failures)
	quit(1 if failures else 0)

func sample_stride(skeleton: Skeleton3D, foot: int, tag: String, rows: Array) -> void:
	for sprinting in [false,true]:
		await place_player(RuralTerrain.ground_point(14,20)+Vector3.UP*0.03)
		player.camera_rig.rotation.y = 0
		await frames(20)
		player.stamina.reset()
		Input.action_press("move_forward")
		if sprinting: Input.action_press("sprint")
		await frames(45)
		var points: Array[Vector3] = []
		var floor_y: Array[float] = []
		var rates: Array[float] = []
		var speeds: Array[float] = []
		for i in 120:
			await frames(1)
			points.append(skeleton.global_transform*skeleton.get_bone_global_pose(foot).origin)
			floor_y.append(player.position.y)
			rates.append(player.visual.animation_player.speed_scale)
			speeds.append(Vector2(player.velocity.x,player.velocity.z).length())
		for action in ["move_forward","sprint"]: Input.action_release(action)
		var minimum := INF
		for i in points.size(): minimum=minf(minimum,points[i].y-floor_y[i])
		var count := 0
		var sliding := 0.0
		for i in points.size()-1:
			if points[i].y-floor_y[i] < minimum+0.07 and points[i+1].y-floor_y[i+1] < minimum+0.07:
				var change := points[i+1]-points[i]
				sliding += Vector2(change.x,change.z).length()*60
				count += 1
		var minimum_speed := INF
		for speed in speeds: minimum_speed=minf(minimum_speed,speed)
		rows.append({"tag":tag,"clip":"Run" if sprinting else "Walk","nominal_actor_speed":player.sprint_speed if sprinting else player.walk_speed,"minimum_measured_actor_speed":minimum_speed,"playback_rate":rates.back(),"near_ground_samples":count,"mean_ground_foot_drift_mps":sliding/maxi(1,count)})
		check(minimum_speed > (6.9 if sprinting else 3.9),"movement sample stays at full speed without props blocking it")
		check(count>10,"sampled actual stance feet while moving")
