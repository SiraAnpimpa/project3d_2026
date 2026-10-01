extends "res://tests/phase_6_zombie_test.gd"
## Live, damaging AI in actual night lighting. Scene/clock placement isolates three threats;
## ordinary earned farming/crafting/wave/rest progression is a separate regression.

func click_attack() -> void:
	mouse(MOUSE_BUTTON_LEFT,true)
	mouse(MOUSE_BUTTON_LEFT,false)

func spawn_live(kind: String, point: Vector3) -> NormalZombie:
	var enemy := ZombieSpawnFactory.spawn(game.get_node("MainWorld"),load("res://scenes/enemies/%sZombie.tscn" % kind),player,point)
	check(enemy!=null,"live "+kind+" spawns safely on current navigation")
	if enemy!=null: enemy.pursue_target=true
	return enemy

func run() -> void:
	root.size=Vector2i(1280,720)
	set_meta("normal_play",true)
	game=load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene=game
	await frames(30)
	player=game.player
	game.debug_controls.set_active(false)
	game.waves.enabled=false
	game.clock.seek(2,18,0)
	game.clock.paused=true
	var map:=game.get_world_3d().navigation_map
	for tick in 600:
		if NavigationServer3D.map_get_iteration_id(map)>0: break
		await frames(1)
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*0.03)
	player.camera_rig.rotation.y=0
	await frames(15)
	key(KEY_Q)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),3)
	key(KEY_R)
	await frames(95)
	check(not game.clock.is_daytime and player.health.damage_enabled and game.weapons.current.current_magazine==3,"night starts with live damage and exactly three loaded crafted-ammo-type rounds")
	var enemy:=spawn_live("Normal",RuralTerrain.ground_point(14,2))
	if enemy==null: quit(1); return
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(15)
	for index in 3:
		aim_at(player,enemy.global_position+Vector3.UP)
		var hp:=enemy.health.current_hp
		click_attack()
		check(enemy.health.current_hp==hp-20,"live night rifle hit applies immediately")
		await frames(13)
	check(enemy.health.current_hp==40 and game.weapons.current.current_magazine==0 and game.weapons.reserve_ammo()==0,"live gun combat really exhausts all ammunition")
	await capture("night_empty_rifle")
	mouse(MOUSE_BUTTON_RIGHT,false)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	check(game.weapons.current.data.is_melee() and not player.camera_rig.is_aiming,"actual wheel switches empty rifle to bat without RMB")
	Input.action_press("move_forward")
	for tick in 180:
		if player.position.distance_to(enemy.position)<1.3: break
		await frames(1)
	Input.action_release("move_forward")
	await frames(6)
	check(player.position.distance_to(enemy.position)<1.6,"actual movement closes into short bat range")
	for index in 4:
		var hp:=enemy.health.current_hp
		click_attack()
		await frames(12)
		check(enemy.health.current_hp==hp-10,"live night bat contact applies exactly10")
		if index==0:
			check(enemy._meshes[0].material_overlay!=null,"live zombie renderer displays existing damage flash")
			await capture("night_bat_hit")
		await frames(40)
	check(enemy.health.is_dead and player.health.current_hp>0 and player.health.current_hp<100,"ammo-exhausted player survives damaging close combat and kills Normal with bat")
	await capture("night_bat_fallback_kill")
	enemy.despawn()
	await frames(3)
	# Runner pursuit: sprint creates space; finite stamina remains a decision.
	await place_player(RuralTerrain.ground_point(14,8)+Vector3.UP*0.03)
	player.camera_rig.rotation.y=0
	await frames(15)
	var runner:=spawn_live("Runner",RuralTerrain.ground_point(14,3))
	if runner==null: quit(1); return
	await frames(3)
	var distance_before:=player.position.distance_to(runner.position)
	var start:=player.position
	player.stamina.reset()
	Input.action_press("move_backward")
	Input.action_press("sprint")
	var sprint_ticks:=0
	for tick in 180:
		await frames(1)
		if player.is_sprinting: sprint_ticks+=1
	Input.action_release("move_backward")
	Input.action_release("sprint")
	check(sprint_ticks>160 and player.position.distance_to(start)>19 and player.position.distance_to(runner.position)>distance_before+4,"actual night sprint outruns live4.5m/s Runner over terrain")
	var remaining:=player.stamina.current_stamina
	check(remaining>45 and remaining<65,"Runner escape spends meaningful but bounded stamina")
	await capture("night_runner_escape")
	await frames(45)
	check(player.stamina.current_stamina>remaining and player.health.current_hp>0,"night stamina starts recovering promptly while Runner is still pursuing")
	print("NIGHT_RUNNER sprint_ticks=",sprint_ticks," travelled=",player.position.distance_to(start)," stamina_after=",remaining)
	# Reorient through movement, then face the returning Runner without a lock-on system.
	player.camera_rig.rotation.y=0
	Input.action_press("move_forward")
	for tick in 500:
		if player.position.distance_to(runner.position)<1.3: break
		await frames(1)
	Input.action_release("move_forward")
	await frames(6)
	for index in 6:
		click_attack()
		await frames(12)
		check(runner.health.current_hp==maxf(0,60-(index+1)*10),"live Runner receives one bat hit per attack")
		await frames(40)
	check(runner.health.is_dead and not player.health.is_dead,"live Runner can eventually be killed with emergency bat")
	await capture("night_runner_bat_kill")
	runner.despawn()
	await frames(3)
	var tank:=spawn_live("Tank",player.position+Vector3(0,0,-1.3))
	if tank==null: quit(1); return
	await frames(3)
	click_attack()
	await frames(12)
	check(tank.health.current_hp==290 and not tank.health.is_dead,"live Tank takes10 but remains a severe melee threat")
	await capture("night_tank_bat_hit")
	Input.action_press("move_backward")
	Input.action_press("sprint")
	await frames(60)
	Input.action_release("move_backward")
	Input.action_release("sprint")
	check(not player.health.is_dead,"player can reposition after the Tank hit")
	var out:=FileAccess.open("user://gameplay_night_result.json",FileAccess.WRITE)
	out.store_string(JSON.stringify({"failures":failures,"final_hp":player.health.current_hp,"ammo":game.inventory.get_item_amount(&"basic_ammo"),"shots":game.weapons.shots_fired,"melee_hits":game.weapons.melee_hits,"runner_sprint_ticks":sprint_ticks,"runner_stamina_after":remaining},"  "))
	print("GAMEPLAY_NIGHT_RESULT failures=",failures," final_hp=",player.health.current_hp)
	quit(1 if failures else 0)
