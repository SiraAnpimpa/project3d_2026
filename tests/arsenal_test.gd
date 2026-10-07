extends "res://tests/special_ammo_test.gd"
## Farm real ingredients and use current workbench/loadout/input owners.
func gather(id: StringName, required: int) -> void:
	if bag.get_item_amount(id) >= required: return
	if not game.gameplay_mode.is_farming(): key(KEY_Q)
	var seed_id := StringName("seed_"+String(id))
	var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(0)
	while bag.get_item_amount(id) < required:
		check(bag.has_item(seed_id),"existing seed supply can gather "+String(id))
		if not bag.has_item(seed_id): return
		bag.select_seed(seed_id)
		await place_player(plot.global_position+Vector3(0,0.03,1.1))
		await frames(8)
		key(KEY_E)
		check(plot.state == FarmPlot.State.PLANTED,"E plants material crop "+String(id))
		game.clock.advance_game_minutes(plot.plant_data.growth_minutes+1)
		await frames(3)
		var before := bag.get_item_amount(id)
		key(KEY_E)
		check(plot.state == FarmPlot.State.EMPTY and bag.get_item_amount(id)>before,"E harvest gathers "+String(id))

func craft_item(id: StringName, screenshot := false) -> void:
	if not game.gameplay_mode.is_farming(): key(KEY_Q)
	var recipe: CraftRecipe = game.recipe_book.get_recipe(id)
	await place_player(game.get_node("MainWorld/Workbench").global_position+Vector3(0,0.03,1.1))
	await frames(8)
	key(KEY_E)
	await frames(10)
	check(game.crafting_ui.is_open,"real E workbench for "+String(id))
	var scroll: ScrollContainer = game.crafting_ui.recipe_list.get_parent()
	scroll.ensure_control_visible(game.crafting_ui._buttons[recipe])
	await frames(3)
	click_button(game.crafting_ui._buttons[recipe])
	await frames(4)
	var before: Dictionary = {}
	for entry in recipe.ingredients: before[entry.item.id] = bag.get_item_amount(entry.item.id)
	var previous := bag.get_item_amount(id)
	check(not game.crafting_ui.craft_button.disabled,"gathered materials allow "+String(id))
	click_button(game.crafting_ui.craft_button)
	await frames(4)
	check(bag.get_item_amount(id)==previous+recipe.outputs[0].quantity,"workbench creates "+String(id))
	for entry in recipe.ingredients:
		check(bag.get_item_amount(entry.item.id)==before[entry.item.id]-entry.quantity,"exact recipe debit "+String(id)+" / "+String(entry.item.id))
	await frames(12)
	check(Rect2(Vector2.ZERO,Vector2(root.size)).encloses(game.crafting_ui._panel.get_global_rect()),"recipe UI fits viewport "+String(id))
	if screenshot: await capture("arsenal_recipe_"+String(id))
	key(KEY_ESCAPE)
	await frames(3)

func equip(id: StringName) -> void:
	mouse(MOUSE_BUTTON_RIGHT,false)
	key(KEY_TAB)
	await frames(5)
	var slots := bag.get_slots()
	for index in slots.size():
		if slots[index].item.id == id:
			var scroll := game.inventory_ui.slot_buttons[index].get_parent().get_parent() as ScrollContainer
			scroll.ensure_control_visible(game.inventory_ui.slot_buttons[index])
			await frames(3)
			click_button(game.inventory_ui.slot_buttons[index])
			break
	await frames(3)
	click_button(game.inventory_ui.equipment_buttons[2])
	check(game.equipment.get_equipped_weapon(2)==game.catalog.get_item(id),"bag UI equips "+String(id))
	key(KEY_TAB)
	await frames(4)
	if game.gameplay_mode.is_farming(): key(KEY_Q)
	for attempt in 3:
		if weapons.current.data.weapon_id == id: break
		mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
		mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
		await frames(4)
	check(weapons.current.data.weapon_id==id and weapons.visual.visible,"real wheel selects crafted "+String(id))
	await frames(12)

func enemy_at(kind: String, distance: float) -> NormalZombie:
	var enemy := load("res://scenes/enemies/%sZombie.tscn"%kind).instantiate() as NormalZombie
	game.get_node("MainWorld").add_child(enemy)
	enemy.global_position = player.global_position+Vector3(0,0,-distance)
	enemy.bind(player)
	enemy.set_physics_process(false)
	return enemy

func exercise_melee(id: StringName) -> void:
	await equip(id)
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*.03)
	player.camera_rig.rotation.y = 0
	player.visual.rotation.y = PI
	var state := weapons.current
	check(not weapons.start_reload() and not weapons.cycle_ammo() and not game.hud._ammo_type_row.visible,"melee has no reload/ammo UI "+String(id))
	var distance := .65 if id==&"knife" else 1.7
	for kind in ["Normal","Runner","Tank"]:
		var enemy := enemy_at(kind,distance)
		await frames(5)
		await frames(int(ceil(60.0/state.data.fire_rate))+2)
		var hp := enemy.health.current_hp
		var hits := weapons.melee_hits
		var ammo := bag.get_item_amount(&"basic_ammo")
		mouse(MOUSE_BUTTON_LEFT,true)
		mouse(MOUSE_BUTTON_LEFT,false)
		check(state.is_swinging and enemy.health.current_hp==hp,"melee windup starts without early damage "+String(id)+" / "+kind)
		check(not weapons.try_swing(),"same cycle rejects rapid click "+String(id))
		await frames(int(ceil(state.data.melee_hit_delay*60.0))+2)
		check(is_equal_approx(enemy.health.current_hp,hp-state.data.damage) and weapons.melee_hits==hits+1,"one configured hit on "+kind+" / "+String(id))
		check(state.swing_hit_committed,"contact recorded once "+String(id))
		await frames(int(ceil(state.data.melee_swing_duration*60.0))+3)
		check(enemy.health.current_hp==hp-state.data.damage and bag.get_item_amount(&"basic_ammo")==ammo,"recovery never repeats damage or spends ammo "+String(id))
		enemy.despawn()
		await frames(4)
	for distance_test in [state.data.range_meters+.5,-.8]:
		var enemy := enemy_at("Normal",distance_test)
		await frames(20)
		check(weapons.try_swing(),"new melee cycle available "+String(id))
		await frames(30)
		check(enemy.health.current_hp==enemy.data.max_health,"range/behind rejects contact "+String(id))
		enemy.despawn()
		await frames(3)
	await capture("arsenal_hold_"+String(id))

func choose_ammo(id: StringName) -> void:
	for attempt in 6:
		if rifle.selected_ammo_type.id==id and rifle.magazine_ammo_type.id==id and not rifle.is_reloading: break
		if not rifle.is_reloading: key(KEY_C)
		await frames(int(ceil(rifle.data.reload_time*60.0))+5)
	check(rifle.selected_ammo_type.id==id and rifle.magazine_ammo_type.id==id,"C selects and completes configured reload "+String(id))

func exercise_gun(id: StringName) -> void:
	await equip(id)
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*.03)
	var state := weapons.current
	check(state.current_magazine==0,"crafted gun begins empty "+String(id))
	key(KEY_R)
	await frames(int(ceil(state.data.reload_time*60.0))+4)
	check(state.current_magazine==state.data.magazine_size and not state.is_reloading,"real timed reload/magazine "+String(id))
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(12)
	for kind in ["Normal","Runner","Tank"]:
		var enemy := enemy_at(kind,4.0)
		await frames(5)
		aim_at(player,enemy.global_position+Vector3.UP)
		var hp := enemy.health.current_hp
		var loaded := state.current_magazine
		check(weapons.try_fire() and weapons.last_hit==enemy,"real muzzle hits "+kind+" / "+String(id))
		check(is_equal_approx(enemy.health.current_hp,maxf(0,hp-state.data.damage)) and state.current_magazine==loaded-1,"configured damage and one round "+String(id))
		await frames(int(ceil(60.0/state.data.fire_rate))+2)
		enemy.despawn()
		await frames(3)
	key(KEY_R)
	await frames(int(ceil(state.data.reload_time*60.0))+4)
	var loaded := state.current_magazine
	var shots := weapons.shots_fired
	mouse(MOUSE_BUTTON_LEFT,true)
	await frames(65)
	mouse(MOUSE_BUTTON_LEFT,false)
	var fired := weapons.shots_fired-shots
	check(fired >= 10 if state.data.automatic else fired==1,"hold uses existing auto/semi cadence "+String(id))
	check(state.current_magazine==loaded-fired,"held firing conserves loaded rounds "+String(id))
	await capture("arsenal_hold_"+String(id))
	mouse(MOUSE_BUTTON_RIGHT,false)

func run() -> void:
	root.size = Vector2i(1280,720)
	await new_game()
	player.health.damage_enabled = false
	check(game.catalog.validation_errors().is_empty() and game.recipe_book.validation_errors(game.catalog).is_empty() and weapons.validation_errors(game.catalog).is_empty(),"all new resources validate")
	check(not game.progression.is_recipe_unlocked(&"smg") and not game.progression.is_recipe_unlocked(&"sword"),"SMG/Sword are gated from Day 1")
	for id in [&"knife",&"pistol",&"sword",&"smg",&"marksman_rifle"]:
		var recipe: CraftRecipe = game.recipe_book.get_recipe(id)
		for day in range(game.clock.current_day+1,recipe.unlock_day+1):
			game.clock.seek(day,6)
			game.progression.apply_day(day)
		check(game.progression.is_recipe_unlocked(id),"existing progression unlocks "+String(id))
		var component_count := 0
		for entry in recipe.ingredients:
			if entry.item.id==&"metal_component": component_count=entry.quantity
		while bag.get_item_amount(&"metal_component")<component_count:
			await gather(&"iron",2)
			await gather(&"copper",1)
			await craft_item(&"metal_component")
		for entry in recipe.ingredients:
			if entry.item.id != &"metal_component": await gather(entry.item.id,entry.quantity)
		await craft_item(id,true)
		check(game.catalog.get_item(id).max_stack==1 and game.catalog.get_item(id).icon != null,"weapon identity/icon/stack "+String(id))
	# Craft ammunition from harvested crops, not free rounds.
	for batch in 8:
		await gather(&"lead",1)
		await gather(&"paper",1)
		await gather(&"copper",1)
		await craft_item(&"basic_ammo")
	await exercise_melee(&"knife")
	await exercise_melee(&"sword")
	for id in [&"pistol",&"smg",&"marksman_rifle"]: await exercise_gun(id)
	# Current SMG owns separate runtime state and accepts real elemental resources.
	await equip(&"smg")
	rifle = weapons.current
	for id in [&"fire_ammo",&"ice_ammo",&"poison_ammo"]:
		bag.add_item(game.catalog.get_item(id),35) # Focused compatibility fixture setup.
		await choose_ammo(id)
		var enemy := await target_zombie()
		await fire_at(enemy,game.catalog.get_item(id))
		mouse(MOUSE_BUTTON_RIGHT,false)
		await frames(4)
	var smg_state := weapons.current
	await equip(&"pistol")
	check(weapons.current != smg_state and weapons.current.magazine_ammo_type.id==&"basic_ammo","new firearm runtimes retain separate ammo")
	await equip(&"smg")
	check(weapons.current==smg_state and smg_state.magazine_ammo_type.id==&"poison_ammo","switch away/back preserves SMG loaded type")
	for item in game.catalog.items:
		if item.item_type != ItemData.ItemType.MATERIAL: continue
		var used := false
		for recipe in game.recipe_book.recipes:
			for ingredient in recipe.ingredients: if ingredient.item==item: used=true
		check(used,"every real material has recipe purpose "+String(item.id))
	root.size = Vector2i(1920,1080)
	await frames(12)
	await capture("arsenal_smg_1080")
	game.queue_free()
	await frames(5)
	print("ARSENAL_RESULT failures=",failures)
	quit(1 if failures else 0)
