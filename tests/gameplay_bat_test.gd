extends "res://tests/phase_6_zombie_test.gd"
## Frozen real zombie scenes isolate range/timing/ownership; live AI is tested at night separately.

func click_swing() -> void:
	mouse(MOUSE_BUTTON_LEFT,true)
	mouse(MOUSE_BUTTON_LEFT,false)

func ready_swing() -> void:
	await frames(55)

func target_at(kind: String, offset: Vector3) -> NormalZombie:
	var enemy := load("res://scenes/enemies/%sZombie.tscn" % kind).instantiate() as NormalZombie
	game.get_node("MainWorld").add_child(enemy)
	enemy.global_position = player.global_position+offset
	enemy.bind(player)
	enemy.set_physics_process(false)
	return enemy

func remove_target(enemy: NormalZombie) -> void:
	enemy.despawn()
	await frames(3)

func run() -> void:
	root.size = Vector2i(1280,720)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	player = game.player
	game.clock.paused = true
	game.debug_controls.set_active(false)
	player.health.damage_enabled = false
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*0.03)
	player.camera_rig.rotation.y=0
	player.visual.rotation.y=PI
	await frames(15)
	var weapons: WeaponController = game.weapons
	var rifle := weapons.current
	check(weapons.validation_errors(game.catalog).is_empty(),"both ranged and melee definitions validate in catalog")
	check(game.inventory.has_item(&"wooden_bat") and game.equipment.get_equipped_weapon(1).id==&"wooden_bat" and game.equipment.selected_weapon_slot==0,"Day 1 owns bat in shared slot two; rifle remains selected")
	check(not weapons.try_swing(),"Farming cannot melee")
	key(KEY_Q)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	await frames(10)
	check(weapons.current.data.is_melee() and not player.camera_rig.is_aiming,"real Combat wheel equips bat without RMB")
	check(weapons.current.data.damage==10 and weapons.current.current_magazine==0 and weapons.reserve_ammo()==0 and not weapons.start_reload(),"bat damage10 needs neither ammunition nor magazine nor reload")
	check(game.hud.ammo_label.text == "Swing" and game.hud._selected_icon.texture == UiIcons.item_icon(game.equipment.get_selected_weapon()) and weapons.muzzle==null,"bat HUD and scene do not pretend to be a gun")
	await capture("bat_ready")
	var enemy := target_at("Normal",Vector3(0,0,-1.2))
	await frames(3)
	var cues: int = game.audio.cues_played
	var contact_frames: Array[int]=[]
	enemy.health.changed.connect(func(hp: float,_maximum: float) -> void:
		if hp<100: contact_frames.append(Engine.get_physics_frames()))
	var attack_started:=Engine.get_physics_frames()
	click_swing()
	check(weapons.swings_started==1 and enemy.health.current_hp==100,"LMB starts immediately but damage waits for sweep")
	await frames(5)
	check(enemy.health.current_hp==100 and player.visual.current_clip==&"CharacterArmature|Slash","real imported Slash presents windup without early damage")
	await capture("bat_windup")
	await frames(8)
	check(enemy.health.current_hp==90 and weapons.melee_hits==1 and enemy._flash_time>0,"one sweep deals10 through existing Health and zombie hit flash")
	var contact_seconds:=float(contact_frames[0]-attack_started)/60.0 if not contact_frames.is_empty() else -1.0
	check(contact_seconds>=0.16 and contact_seconds<=0.22,"runtime contact occurs near the configured0.18s visual sweep")
	print("BAT_CONTACT seconds=",contact_seconds)
	check(game.audio.cues_played>=cues+2 and game.hud.get_node("Root/Crosshair").hit_time>0,"swing/hit cues and existing hit confirmation are connected")
	await capture("bat_contact")
	check(not weapons.try_swing(),"swing/cooldown rejects immediate spam")
	await frames(20)
	check(enemy.health.current_hp==90,"one swing never damages every physics frame")
	await ready_swing()
	mouse(MOUSE_BUTTON_LEFT,true)
	await frames(100)
	mouse(MOUSE_BUTTON_LEFT,false)
	check(enemy.health.current_hp==80,"holding LMB does not create an automatic melee loop")
	check(rifle.current_magazine==0 and game.inventory.get_item_amount(&"basic_ammo")==0 and player.stamina.current_stamina==100,"melee leaves ammo and emergency stamina untouched")
	await remove_target(enemy)
	# Finite spatial volume: out of range, behind, and blocked by a thin wall.
	for offset in [Vector3(0,0,-2.1),Vector3(0,0,1.1)]:
		enemy=target_at("Normal",offset)
		await ready_swing()
		click_swing()
		await frames(20)
		check(enemy.health.current_hp==100,"bat cannot hit outside its short forward volume: %s" % offset)
		await remove_target(enemy)
	enemy=target_at("Normal",Vector3(0,0,-1.2))
	var wall := wall_at(player.position+Vector3(0,1,-0.6),Vector3(2,2,0.12))
	await ready_swing()
	click_swing()
	await frames(20)
	check(enemy.health.current_hp==100,"short-range shape contact cannot damage through cover")
	wall.queue_free()
	await remove_target(enemy)
	var other := target_at("Normal",Vector3(0.24,0,-1.2))
	enemy=target_at("Normal",Vector3(-0.24,0,-1.2))
	await ready_swing()
	click_swing()
	await frames(35)
	check(enemy.health.current_hp+other.health.current_hp==190,"one swing damages at most one target even with overlapping colliders")
	await remove_target(enemy)
	await remove_target(other)
	# Switching, mode changes and inventory pauses cancel pending contact.
	for cancellation in ["switch","mode","menu"]:
		enemy=target_at("Normal",Vector3(0,0,-1.2))
		await ready_swing()
		click_swing()
		await frames(4)
		if cancellation=="switch":
			mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
			mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
		elif cancellation=="mode": key(KEY_Q)
		else: game.inventory_ui.set_open(true)
		await frames(25)
		check(enemy.health.current_hp==100,"pending swing cancels on "+cancellation)
		if cancellation=="switch":
			mouse(MOUSE_BUTTON_WHEEL_UP,true)
			mouse(MOUSE_BUTTON_WHEEL_UP,false)
			check(not weapons.try_swing(),"switching away/back cannot reset bat cooldown")
		elif cancellation=="mode": key(KEY_Q)
		else: game.inventory_ui.set_open(false)
		await remove_target(enemy)
	# All real variant Health values, with zero ammo, through actual click input.
	for kind in ["Normal","Runner","Tank"]:
		enemy=target_at(kind,Vector3(0,0,-1.2))
		var required := ceili(enemy.health.max_hp/10.0)
		var started := Engine.get_physics_frames()
		for index in required:
			await ready_swing()
			click_swing()
			await frames(12)
			check(enemy.health.current_hp==maxf(0,enemy.health.max_hp-(index+1)*10),"%s swing %d applies exactly10" % [kind,index+1])
			if index < 2: check(not enemy.health.is_dead,"%s does not die in one/two swings" % kind)
		check(enemy.health.is_dead and weapons.shots_fired==0,"zero-ammo bat eventually kills "+kind)
		print("BAT_VARIANT kind=",kind," hp=",enemy.health.max_hp," swings=",required," tested_seconds=",float(Engine.get_physics_frames()-started)/60)
		await capture("bat_"+kind.to_lower()+"_death")
		await remove_target(enemy)
	# Existing per-weapon runtime survives equipment cycling.
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),12)
	check(weapons.current==rifle and weapons.start_reload(),"switch back resumes the same ranged runtime and normal reload")
	await frames(95)
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(15)
	click_swing()
	mouse(MOUSE_BUTTON_RIGHT,false)
	check(rifle.current_magazine==9 and weapons.reserve_ammo()==2 and weapons.shots_fired==1,"rifle still fires immediately and consumes exactly one round")
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	await ready_swing()
	click_swing()
	await frames(35)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	check(weapons.current==rifle and rifle.current_magazine==9 and weapons.reserve_ammo()==2,"rifle magazine/reserve persist through a bat swing")
	# Removal of owned equipment and player death invalidate the pending attack.
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	enemy=target_at("Normal",Vector3(0,0,-1.2))
	await ready_swing()
	click_swing()
	await frames(4)
	game.inventory.remove_item(&"wooden_bat",1)
	await frames(25)
	check(enemy.health.current_hp==100 and not weapons.runtimes.has(&"wooden_bat") and weapons.current==rifle,"removing owned bat cancels contact and removes its runtime")
	game.inventory.add_item(game.catalog.get_item(&"wooden_bat"),1)
	game.equipment.equip_weapon(1,game.catalog.get_item(&"wooden_bat"))
	game.equipment.cycle_weapon(1)
	await frames(3)
	click_swing()
	await frames(4)
	player.health.damage_enabled=true
	player.health.take_damage(1000)
	await frames(25)
	check(enemy.health.current_hp==100 and not weapons.current.is_swinging and not weapons.try_swing(),"death cancels windup and blocks new swings")
	await remove_target(enemy)
	print("GAMEPLAY_BAT_RESULT failures=",failures)
	quit(1 if failures else 0)
