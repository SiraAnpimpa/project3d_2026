extends "res://tests/phase_7_lifecycle_test.gd"

func frames(count: int) -> void:
	for _tick in count:
		if is_instance_valid(player): player.camera_rig._window_focused = true
		await physics_frame

func settle_choice(id: StringName) -> void:
	for _tick in 30:
		if game.seed_rewards.is_open: break
		await process_frame
	check(game.seed_rewards.is_open and paused, "earned morning choice opens and owns pause")
	game.seed_rewards._select(id)
	await click_button(game.seed_rewards.confirm_button)
	await frames(2)
	check(not game.seed_rewards.is_open and not paused, "claim button returns to gameplay")

func run() -> void:
	root.size = Vector2i(1280, 720)
	await fresh()
	check(game.starter_weapon.id == &"pistol" and game.weapons.current.data.weapon_id == &"pistol" and game.inventory.has_item(&"pistol") and not game.inventory.has_item(&"basic_rifle"), "new game starts with owned/equipped Pistol; Assault Rifle must be crafted")
	check(game.inventory.has_item(&"wooden_bat") and game.weapons.current.current_magazine == 0, "existing empty magazine and backup bat are preserved")
	check(game.recipe_book.validation_errors(game.catalog).is_empty() and game.progression.data.validation_errors(game.catalog, game.recipe_book).is_empty(), "recipes/catalog/ten-day progression validate")
	for row in [["pistol",20,12,60.0], ["basic_rifle",40,25,60.0], ["smg",25,30,35.0], ["marksman_rifle",100,5,85.0], ["knife",15,0,1.9], ["sword",50,0,3.0]]:
		var weapon: WeaponData = load("res://resources/weapons/%s.tres" % row[0])
		check(weapon.damage == row[1] and weapon.magazine_size == row[2] and (row[0] == "pistol" or is_equal_approx(weapon.range_meters,row[3])), "requested damage/capacity/reach: " + row[0])
		check(weapon.validation_errors().is_empty(), "balanced weapon remains valid: " + row[0])
	check(load("res://resources/weapons/basic_rifle.tres").display_name == "Assault Rifle" and game.catalog.get_item(&"basic_rifle").display_name == "Assault Rifle", "Assault Rifle name is consistent in inventory and HUD")
	# Every weapon is actually craftable on Day 1, with real material debits.
	var crafted := 0
	for recipe: CraftRecipe in game.recipe_book.recipes:
		if recipe.category != CraftRecipe.Category.WEAPON: continue
		game.inventory.clear()
		check(game.crafting_system.is_unlocked(recipe) and recipe.unlock_day == 1 and game.progression.is_recipe_unlocked(recipe.recipe_id), "weapon recipe available on Day 1: " + String(recipe.recipe_id))
		check(not game.crafting_system.failure_reason(recipe).is_empty(), "weapon still requires materials: " + String(recipe.recipe_id))
		for entry in recipe.ingredients: game.inventory.add_item(entry.item, entry.quantity)
		check(game.crafting_system.craft(recipe).begins_with("Crafted"), "Day 1 material transaction crafts " + String(recipe.recipe_id))
		for entry in recipe.ingredients: check(game.inventory.get_item_amount(entry.item.id) == 0, "craft consumes exact " + entry.item.display_name)
		check(game.inventory.has_item(recipe.outputs[0].item.id), "craft produces owned " + recipe.display_name)
		crafted += 1
	check(crafted == 7 and not game.crafting_system.is_unlocked(game.recipe_book.get_recipe(&"fire_ammo")), "all seven weapons craftable; elemental ammunition progression stays locked")
	# Real reload transfers 25 rounds; all four ranged weapons apply their new damage.
	game.inventory.clear()
	for id in [&"basic_rifle", &"pistol", &"smg", &"marksman_rifle", &"knife", &"sword"]: game.inventory.add_item(game.catalog.get_item(id))
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"), 100)
	game.equipment.equip_weapon(0, game.catalog.get_item(&"basic_rifle"))
	check(game.equipment.selected_weapon_slot == 0, "crafted Assault Rifle selects first equipped slot")
	game.gameplay_mode.set_mode(GameplayModeController.Mode.COMBAT)
	check(game.weapons.start_reload(), "Assault Rifle reload starts")
	await frames(100)
	check(game.weapons.current.current_magazine == 25 and game.weapons.reserve_ammo() == 75, "Assault Rifle really reloads 25 rounds with matching reserve debit")
	player.position = Vector3(3,0.1,2)
	player.velocity = Vector3.ZERO
	await frames(6)
	var dummy: TargetDummy = game.get_node("MainWorld/TargetDummy")
	dummy.position = Vector3(3,0.1,-6)
	dummy.health.max_hp = 1000
	for id in [&"pistol", &"basic_rifle", &"smg", &"marksman_rifle"]:
		game.equipment.equip_weapon(0,game.catalog.get_item(id))
		await frames(3)
		var state: WeaponRuntime = game.weapons.current
		state.current_magazine = 1
		state.fire_cooldown = 0
		dummy.health.reset()
		mouse(MOUSE_BUTTON_RIGHT,true)
		await frames(20)
		aim_at(player,dummy.global_position + Vector3.UP)
		check(game.weapons.try_fire() and game.weapons.last_hit == dummy and is_equal_approx(dummy.health.current_hp,1000-state.data.damage), "actual ranged hit applies balanced damage: " + String(id))
		mouse(MOUSE_BUTTON_RIGHT,false)
	# Long blade reach must not introduce a dead zone beside the player.
	player.visual.rotation.y = PI
	player.set_physics_process(false)
	for row in [[&"knife",0.6,true], [&"knife",1.7,true], [&"knife",2.1,false], [&"sword",0.6,true], [&"sword",2.8,true], [&"sword",3.2,false]]:
		game.equipment.equip_weapon(0,game.catalog.get_item(row[0]))
		await frames(3)
		dummy.position = player.position + Vector3(0,0,-row[1])
		dummy.health.reset()
		await frames(3)
		var state: WeaponRuntime = game.weapons.current
		state.swing_direction = Vector3.FORWARD
		game.weapons._resolve_melee_hit(state)
		check(is_equal_approx(dummy.health.current_hp, 1000-state.data.damage if row[2] else 1000.0), "melee reach/close contact %s at %.1fm" % [row[0],row[1]])
	# Zombie health and damage are exercised through their real attack windup.
	for row in [["NormalZombie",150,15], ["RunnerZombie",100,10], ["TankZombie",400,30]]:
		var zombie: NormalZombie = load("res://scenes/enemies/%s.tscn" % row[0]).instantiate()
		game.add_child(zombie)
		zombie.position = player.position + Vector3(0,0,1.0)
		zombie.bind(player)
		player.health.reset()
		check(zombie.health.max_hp == row[1] and zombie.health.current_hp == row[1], "spawned zombie health: " + row[0])
		for _tick in 50:
			await frames(1)
			if zombie.attacks_landed > 0: break
		check(zombie.attacks_landed == 1 and player.health.current_hp == 100-row[2], "real zombie attack damage: " + row[0])
		if row[0] == "TankZombie":
			var collider: CollisionShape3D = zombie.get_node("CollisionShape3D")
			check(zombie.data.visual_scale == 1.65 and is_equal_approx(collider.position.y,collider.shape.height/2) and collider.shape.radius == zombie.agent.radius, "larger Tank has grounded collider and matching navigation radius")
			var red_material := false
			for mesh: MeshInstance3D in zombie._meshes:
				var material := mesh.get_active_material(0) as StandardMaterial3D
				if material != null and material.albedo_color.r > material.albedo_color.g * 2: red_material = true
			check(red_material, "Tank has red rendered material overrides")
		zombie.queue_free()
		await frames(3)
	# Fire automatically repeats every dawn, exactly matching basic seed supplies.
	await fresh()
	game.progression.apply_day(3)
	await frames(3)
	check(game.inventory.get_item_amount(&"seed_fire_pepper") == 4 and not game.seed_rewards.is_open and game.progression.daily_seed_receipts[3] == &"seed_fire_pepper", "Day 3 Fire reward is four, with no duplicate unlock gift or dialog")
	game.progression.apply_day(4)
	check(game.inventory.get_item_amount(&"seed_fire_pepper") == 8, "Day 4 repeats Fire reward, four seeds")
	game.progression.apply_day(4)
	check(game.inventory.get_item_amount(&"seed_fire_pepper") == 8, "duplicate dawn cannot duplicate daily seeds")
	# Use real clock dawns for two-choice UI, pause, locked poison, clicks and focus.
	game.clock.seek(4,18)
	game.clock.skip_to_day()
	await frames(6)
	var dialog: SeedRewardDialog = game.seed_rewards
	check(dialog.is_open and paused and dialog.reward_day == 5 and not player.camera_rig.can_control() and not game.weapons.try_fire(), "Day 5 natural dawn presents modal choice and blocks movement/fire")
	check(not dialog.cards[0].disabled and not dialog.cards[1].disabled and dialog.cards[2].disabled and dialog.badges[2].text == "Lock · Day 7", "Fire/Ice available; unearned Poison visible and locked")
	check(game.inventory.get_item_amount(&"seed_ice_plant") == 0 and game.progression.seed_reward_amount(5) == 5, "unlocking Ice awaits choice; no extra one-time gift")
	check(not game.progression.choose_daily_seed(5,&"seed_poison_plant"), "locked seed choice rejected without consuming reward")
	key(KEY_TAB)
	key(KEY_ESCAPE)
	check(dialog.is_open and not game.inventory_ui.is_open and not game.pause_menu.is_open, "reward modal owns Tab/Esc; other menus do not overlap")
	check(root.gui_get_focus_owner() == dialog.cards[1], "Tab navigates to Ice without being swallowed by the closed bag")
	key(KEY_SPACE)
	check(dialog.selected_seed == &"seed_ice_plant", "keyboard accept selects the focused seed card")
	dialog._select(&"seed_fire_pepper")
	for size in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(1152,648)]:
		root.size = size
		await frames(4)
		check(Rect2(Vector2.ZERO,Vector2(size)).encloses(dialog.panel.get_global_rect()) and dialog.confirm_button.get_global_rect().end.y <= size.y, "choice cards and confirmation fit viewport %s" % size)
	root.size = Vector2i(1280,720)
	await frames(6)
	await capture("seed_choice_fire_ice")
	await click_button(dialog.cards[1])
	check(dialog.selected_seed == &"seed_ice_plant" and dialog.confirm_button.text.contains("Ice Seeds ×5"), "clicking Ice card updates selection and count")
	await click_button(dialog.confirm_button)
	await frames(3)
	check(game.inventory.get_item_amount(&"seed_ice_plant") == 5 and game.inventory.get_item_amount(&"seed_fire_pepper") == 8 and not paused and player.camera_rig.can_control(), "one chosen Ice supply delivered and gameplay restored")
	dialog.confirm_selection()
	check(game.inventory.get_item_amount(&"seed_ice_plant") == 5 and game.progression.daily_seed_receipts.size() == 3, "repeated confirm cannot grant a second reward")
	# The next morning after resting also asks, after RestSystem releases its pause.
	game.clock.skip_to_night()
	waves.pending.clear()
	waves._cleanup()
	waves.state = NightWaveManager.State.CLEARED
	check(game.rest.request_rest(player), "rest starts before repeat daily choice")
	await frames(30)
	check(game.clock.current_day == 6 and not game.rest.is_resting and dialog.is_open and paused, "rest completes into a fresh, still-paused Day 6 choice")
	await settle_choice(&"seed_fire_pepper")
	check(game.inventory.get_item_amount(&"seed_fire_pepper") == 13, "Day 6 can choose Fire instead of Ice, receiving five")
	game.clock.skip_to_night()
	game.clock.skip_to_day()
	await frames(6)
	check(dialog.is_open and not dialog.cards[2].disabled and game.progression.seed_reward_amount(7) == 6, "Day 7 Poison unlock joins three-way daily choice")
	await capture("seed_choice_all_unlocked")
	# Full bag: choice receipt is committed once; reward remains queued until room exists.
	game.debug_controls.set_active(true)
	game.debug_controls.execute(&"debug_fill_inventory")
	await settle_choice(&"seed_poison_plant")
	check(game.inventory.get_item_amount(&"seed_poison_plant") == 0 and game.progression.pending_rewards.get(&"seed_poison_plant",0) == 6, "full bag retains exactly six chosen Poison seeds")
	game.inventory.clear()
	await frames(2)
	check(game.inventory.get_item_amount(&"seed_poison_plant") == 6 and game.progression.pending_rewards.is_empty(), "freeing bag delivers saved choice once")
	game.progression.apply_day(7)
	check(game.inventory.get_item_amount(&"seed_poison_plant") == 6 and game.progression.next_seed_reward_day() == 0, "delivery/repeated dawn cannot duplicate choice")
	# Dawn while another menu owns pause waits, then opens without unpausing that menu.
	game.inventory_ui.set_open(true)
	game.clock.seek(8,6)
	await frames(4)
	check(game.inventory_ui.is_open and paused and not dialog.is_open, "existing bag retains pause when a reward arrives")
	game.inventory_ui.set_open(false)
	for _tick in 30:
		if dialog.is_open: break
		await process_frame
	check(dialog.is_open and paused and dialog.reward_day == 8, "queued reward opens after bag closes")
	await settle_choice(&"seed_ice_plant")
	game.clock.seek(10,6)
	await settle_choice(&"seed_poison_plant")
	var receipts: int = game.progression.daily_seed_receipts.size()
	game.clock.skip_to_night()
	game.clock.skip_to_day()
	await frames(6)
	check(game.clock.current_day == 11 and waves.state == NightWaveManager.State.GAME_COMPLETED and not dialog.is_open and game.progression.daily_seed_receipts.size() == receipts, "final dawn completes game without Day 11 seed prompt/reward")
	# Death dismisses the modal and releases its pause for the existing death menu.
	await fresh()
	game.clock.seek(5,6)
	await frames(5)
	check(game.seed_rewards.is_open, "death fixture has active choice")
	player.health.take_damage(1000)
	await frames(3)
	check(not game.seed_rewards.is_open and not paused and not player.camera_rig.can_control(), "death closes choice safely, keeping player control disabled")
	print("BALANCE_SEED_REWARDS_RESULT failures=",failures)
	quit(1 if failures else 0)
