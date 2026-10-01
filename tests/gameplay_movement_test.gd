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
	await place_player(RuralTerrain.ground_point(0,6)+Vector3.UP*0.03)
	player.camera_rig.rotation.y = 0
	await frames(15)
	player.stamina.drain(100)
	Input.action_press("sprint")
	Input.action_press("move_right")
	await frames(60)
	check(not player.is_sprinting and player.stamina.current_stamina < 25,"empty stamina cannot restart before 25 percent threshold")
	var resumed := false
	for i in 60:
		await frames(1)
		if player.is_sprinting:
			resumed = true
			break
	check(resumed and player.stamina.current_stamina < 35,"partial recovery restarts sprint at existing threshold")
	Input.action_release("sprint")
	Input.action_release("move_right")
	await frames(20)
	await place_player(RuralTerrain.ground_point(0,6)+Vector3.UP*0.03)
	await frames(15)
	player.stamina.reset()
	Input.action_press("sprint")
	var sprint_ticks := 0
	var walk_ticks := 0
	var bounded := true
	for i in 1200:
		var right := int(i/60)%2 == 0
		Input.action_release("move_left" if right else "move_right")
		Input.action_press("move_right" if right else "move_left")
		await frames(1)
		if player.is_sprinting: sprint_ticks += 1
		else: walk_ticks += 1
		bounded = bounded and player.stamina.current_stamina >= 0 and player.stamina.current_stamina <= 100
	for action in ["sprint","move_right","move_left"]: Input.action_release(action)
	check(sprint_ticks > 400 and walk_ticks > 100 and bounded,"20 seconds held sprint has finite recovery periods and bounded stamina")
	# Actual hill physics, both ways; no floor/velocity overrides during input.
	var changes: Array = []
	for pair in [[Vector2(-10,-34),"move_forward"],[Vector2(-10,-42),"move_backward"]]:
		var point: Vector2 = pair[0]
		await place_player(RuralTerrain.ground_point(point.x,point.y)+Vector3.UP*0.03)
		await frames(15)
		player.stamina.reset()
		var start := player.position
		Input.action_press(pair[1])
		Input.action_press("sprint")
		var grounded := 0
		for i in 45:
			await frames(1)
			if player.is_on_floor(): grounded += 1
		Input.action_release(pair[1])
		Input.action_release("sprint")
		var rise := player.position.y-start.y
		changes.append(rise)
		print("SLOPE_TRAVEL start=",start," end=",player.position," rise=",rise," grounded=",grounded)
		check(player.position.distance_to(start)>2 and grounded>32 and player.stamina.current_stamina<96,"actual sprint traverses slope, pays stamina and stays grounded")
	check(float(changes[0])>0.15 and float(changes[1]) < -0.15,"both uphill and downhill were exercised")
	check(player.rotation.x==0 and player.rotation.z==0,"slope locomotion leaves physics root upright")
	print("GAMEPLAY_MOVEMENT_RESULT failures=",failures)
	quit(1 if failures else 0)
