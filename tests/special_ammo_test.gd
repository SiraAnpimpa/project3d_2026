extends "res://tests/phase_6_zombie_test.gd"

var weapons: WeaponController
var bag: Inventory
var rifle: WeaponRuntime

func new_game() -> void:
	if is_instance_valid(current_scene):
		current_scene.queue_free()
		await frames(3)
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var menu: Control = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(5)
	click_button(menu.play_button)
	await frames(25)
	await wait_for_gameplay()
	game = current_scene
	player = game.player
	weapons = game.weapons
	bag = game.inventory
	rifle = weapons.current
	game.clock.paused = true
	game.waves.enabled = false
	check(not game.debug_controls.active, "Main Menu Play starts normal game, no debug grants")

func craft_ammo(id: StringName) -> void:
	if not game.gameplay_mode.is_farming(): key(KEY_Q)
	var recipe: CraftRecipe = game.recipe_book.get_recipe(id)
	for entry in recipe.ingredients:
		check(bag.add_item(entry.item, entry.quantity), "fixture supplies real recipe ingredient " + String(entry.item.id))
	await place_player(game.get_node("MainWorld/Workbench").global_position + Vector3(0,0.05,1.1))
	await frames(10)
	key(KEY_E)
	await frames(15)
	check(game.crafting_ui.is_open, "E opens real workbench for " + String(id))
	var scroll: ScrollContainer = game.crafting_ui.recipe_list.get_parent()
	scroll.ensure_control_visible(game.crafting_ui._buttons[recipe])
	await frames(3)
	click_button(game.crafting_ui._buttons[recipe])
	await frames(3)
	var before := bag.get_item_amount(id)
	click_button(game.crafting_ui.craft_button)
	await frames(3)
	check(bag.get_item_amount(id) == before + 10 and game.crafting_ui.feedback.text.begins_with("Crafted"), "actual workbench crafts ten " + String(id))
	for entry in recipe.ingredients: check(not bag.has_item(entry.item.id), "craft consumes ingredient " + String(entry.item.id))
	await frames(15)
	check(Rect2(Vector2.ZERO,Vector2(root.size)).encloses(game.crafting_ui._panel.get_global_rect()), "special ammo workbench fits 720p")
	await capture("craft_" + String(id))
	key(KEY_ESCAPE)
	await frames(3)

func choose_ammo(id: StringName) -> void:
	for _i in 6:
		if rifle.selected_ammo_type.id == id: break
		key(KEY_C)
		await frames(100)
	check(rifle.selected_ammo_type.id == id and rifle.magazine_ammo_type.id == id, "C selects and reloads " + String(id))

func target_zombie() -> NormalZombie:
	mouse(MOUSE_BUTTON_RIGHT, false)
	await place_player(RuralTerrain.ground_point(14,6) + Vector3.UP * 0.03)
	var enemy := ZombieSpawnFactory.spawn(game.get_node("MainWorld"), load("res://scenes/enemies/TankZombie.tscn"), player, RuralTerrain.ground_point(14,2))
	enemy.set_physics_process(false)
	enemy.health.max_hp = 1000
	enemy.health.reset()
	mouse(MOUSE_BUTTON_RIGHT, true)
	await frames(15)
	aim_at(player, enemy.global_position + Vector3.UP)
	await frames(3)
	return enemy

func fire_at(enemy: NormalZombie, ammo: ItemData) -> void:
	var hp := enemy.health.current_hp
	var rounds := rifle.current_magazine
	var normal := bag.get_item_amount(&"basic_ammo")
	var reserve := bag.get_item_amount(ammo.id)
	aim_at(player, enemy.global_position + Vector3.UP)
	check(weapons.try_fire() and weapons.last_hit == enemy, "real muzzle shot hits zombie with " + ammo.display_name)
	check(is_equal_approx(enemy.health.current_hp, hp - rifle.data.damage) and rifle.current_magazine == rounds - 1, "shot keeps base damage and consumes exactly one loaded round")
	check(bag.get_item_amount(ammo.id) == reserve and bag.get_item_amount(&"basic_ammo") == normal, "shooting spends loaded rounds without deducting reserve twice")
	var impacts: Array[Node] = game.find_children("*", "GPUParticles3D", false, false)
	var impact: GPUParticles3D
	for node in impacts:
		if node.scene_file_path == ammo.impact_vfx.resource_path: impact = node
	check(impact != null and impact.global_position.is_equal_approx(weapons.last_shot_end), "impact scene and position match loaded " + ammo.display_name)
	check(enemy.ammo_effects.has(ammo.ammo_effect) if ammo.ammo_effect != ItemData.AmmoEffect.NONE else enemy.ammo_effects.is_empty(), "zombie status matches magazine ammo, not weapon default")
	# Tick the production status owner with AI disabled for exact bounded proof.
	if ammo.ammo_effect != ItemData.AmmoEffect.NONE:
		var after := enemy.health.current_hp
		enemy.apply_ammo_effect(ammo)
		check(enemy.ammo_effects.size() == 1, "repeated same status refreshes without stacking")
		enemy._tick_ammo_effects(1.0)
		check(is_equal_approx(enemy.health.current_hp, after - ammo.effect_damage_per_second), "one second uses data-defined DOT through existing Health")
		check(is_equal_approx(enemy.ammo_speed_multiplier(), ammo.effect_speed_multiplier), "status movement multiplier matches ammo data")
		if ammo.ammo_effect == ItemData.AmmoEffect.SLOW:
			enemy._chase(1.0)
			check(is_equal_approx(Vector2(enemy.velocity.x,enemy.velocity.z).length(), enemy.data.move_speed * 0.5), "Ice halves actual chase velocity")
		enemy._physics_process(1.0 / 60.0)
		check(enemy._meshes[0].material_overlay != null, "active status reuses zombie material feedback")
		await frames(4)
		await capture("loaded_" + String(ammo.id))
		enemy._tick_ammo_effects(ammo.effect_duration + 1)
		check(enemy.ammo_effects.is_empty() and enemy.ammo_speed_multiplier() == 1.0, "status expires and restores movement")
		check(is_equal_approx(enemy.health.current_hp, after - ammo.effect_damage_per_second * ammo.effect_duration), "DOT is bounded by its duration")
	else:
		await capture("loaded_basic_ammo")
	enemy.despawn()
	await frames(15)

func run() -> void:
	root.size = Vector2i(1280,720)
	await new_game()
	check(weapons.validation_errors(game.catalog).is_empty(), "production weapon and all compatible ammo validate in catalog")
	check(rifle.data.get_compatible_ammo().size() == 4 and game.catalog.get_item(&"electric_ammo") == null, "only four existing ammo definitions; no invented Electric")
	game.progression.apply_day(7)
	bag.add_item(game.catalog.get_item(&"basic_ammo"),40)
	await craft_ammo(&"fire_ammo")
	key(KEY_C)
	check(rifle.selected_ammo_type.id == &"basic_ammo" and not rifle.is_reloading, "Farming C cannot change ammo")
	key(KEY_Q)
	check(game.hud._equipment_hint.text.contains("C") and game.hud._equipment_hint.text.contains("SWITCH AMMO"), "first compatible special ammo gives contextual C hint")
	key(KEY_R)
	await frames(100)
	check(rifle.current_magazine == 10 and bag.get_item_amount(&"basic_ammo") == 30, "normal reload retains existing quantities")
	key(KEY_C)
	check(rifle.selected_ammo_type.id == &"fire_ammo" and rifle.is_reloading and rifle.magazine_ammo_type.id == &"basic_ammo", "C selects Fire and starts original timed reload while old magazine remains Basic")
	check(bag.get_item_amount(&"fire_ammo") == 10 and bag.get_item_amount(&"basic_ammo") == 30, "swap deducts nothing before reload completion")
	check(game.hud.ammo_type_label.text == "Basic Ammo" and game.hud._count_caption.text.contains("Fire"), "HUD separates loaded ammo from swap target")
	for _i in 10:
		key(KEY_C)
		key(KEY_R)
	await frames(30)
	check(rifle.current_magazine == 10 and rifle.is_reloading and not weapons.try_fire(), "spam cannot shorten reload or shoot during swap")
	await capture("ammo_swap_720p")
	await frames(70)
	check(rifle.current_magazine == 10 and rifle.magazine_ammo_type.id == &"fire_ammo" and bag.get_item_amount(&"fire_ammo") == 0 and bag.get_item_amount(&"basic_ammo") == 40, "Fire reload deducts only Fire and returns all old Normal rounds")
	check(game.hud.ammo_type_label.text == "Fire Ammo" and game.hud._ammo_icon.texture == rifle.magazine_ammo_type.icon, "HUD displays actual loaded Fire icon and count")
	var enemy := await target_zombie()
	await fire_at(enemy, rifle.magazine_ammo_type)
	check(not weapons.start_reload() and rifle.selected_ammo_type.id == &"fire_ammo" and rifle.current_magazine == 9, "no fallback while Fire magazine has rounds, even with zero reserve")
	key(KEY_C)
	await frames(100)
	check(rifle.magazine_ammo_type.id == &"basic_ammo" and bag.get_item_amount(&"fire_ammo") == 9, "switch back Normal returns unused Fire, no mixed magazine")
	enemy = await target_zombie()
	await fire_at(enemy, rifle.magazine_ammo_type)
	await craft_ammo(&"ice_ammo")
	await craft_ammo(&"poison_ammo")
	key(KEY_Q)
	for id in [&"fire_ammo", &"ice_ammo", &"poison_ammo"]:
		await choose_ammo(id)
		var normal := bag.get_item_amount(&"basic_ammo")
		enemy = await target_zombie()
		await fire_at(enemy, rifle.magazine_ammo_type)
		check(bag.get_item_amount(&"basic_ammo") == normal, "special shots never spend Normal reserve")
		print("AMMO_KIND_RESULT ", id, " failures=", failures)
	# Runtime memory and melee UI; real wheel action remains weapon selection.
	var saved_ammo := rifle.magazine_ammo_type
	var saved_rounds := rifle.current_magazine
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	check(weapons.current.data.is_melee() and not game.hud.ammo_label.visible and not game.hud._ammo_type_row.visible and not game.hud._equipment_hint.text.contains("SWITCH AMMO"), "wheel selects Wooden Bat; all ammo UI and selector hidden")
	check(not weapons.cycle_ammo() and not weapons.start_reload(), "bat rejects ammo selection/reload")
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	check(weapons.current == rifle and rifle.magazine_ammo_type == saved_ammo and rifle.current_magazine == saved_rounds, "rifle-bat-rifle retains loaded and selected ammo per runtime")
	# Cancelled swaps leave quantities unchanged and pending selection is explicit.
	var before := bag.get_slots()
	key(KEY_C)
	await frames(20)
	key(KEY_ESCAPE)
	check(not rifle.is_reloading and rifle.current_magazine == saved_rounds and rifle.magazine_ammo_type == saved_ammo, "Pause cancels timed swap and keeps loaded magazine")
	check(bag.get_slots().size() == before.size(), "cancel preserves inventory stacks")
	key(KEY_ESCAPE)
	check(game.hud._count_caption.text.begins_with("NEXT:"), "cancelled selection shows next ammo, loaded ammo still displayed")
	key(KEY_R)
	await frames(20)
	key(KEY_TAB)
	check(not rifle.is_reloading and not weapons.cycle_ammo(), "Inventory cancels swap and blocks C")
	key(KEY_TAB)
	key(KEY_R)
	await frames(20)
	key(KEY_Q)
	check(not rifle.is_reloading and rifle.magazine_ammo_type == saved_ammo, "Farming cancels swap without changing loaded type")
	key(KEY_Q)
	key(KEY_R)
	await frames(100)
	check(rifle.magazine_ammo_type == rifle.selected_ammo_type, "R resumes pending ammo through standard timed commit")
	# Data-only Normal firearm proves compatibility and independent mutable state.
	var item := ItemData.new()
	item.id = &"test_normal_pistol"
	item.display_name = "Test Normal Pistol"
	item.item_type = ItemData.ItemType.WEAPON
	item.max_stack = 1
	var pistol := rifle.data.duplicate() as WeaponData
	pistol.weapon_id = item.id
	pistol.weapon_item = item
	pistol.display_name = item.display_name
	pistol.compatible_ammo_types = []
	pistol.magazine_size = 6
	game.catalog.items.append(item)
	weapons.definitions.append(pistol)
	bag.add_item(item)
	game.equipment.equip_weapon(2,item)
	game.equipment.cycle_weapon(-1)
	check(weapons.current.data == pistol and not weapons.cycle_ammo() and weapons.available_ammo().size() <= 1, "Normal-only firearm cannot select any owned special ammo")
	check(not game.hud._equipment_hint.text.contains("SWITCH AMMO") and weapons.current.selected_ammo_type.id == &"basic_ammo", "Normal-only firearm hides selector hint")
	key(KEY_R)
	await frames(100)
	check(weapons.current.current_magazine == 6 and weapons.current.magazine_ammo_type.id == &"basic_ammo", "second firearm uses own Normal magazine")
	game.equipment.cycle_weapon(1)
	check(weapons.current == rifle and rifle.magazine_ammo_type == rifle.selected_ammo_type, "different guns keep independent runtime state")
	var same_definition := WeaponRuntime.new(rifle.data)
	check(same_definition.selected_ammo_type == rifle.data.ammo_type and same_definition.current_magazine == 0 and rifle.data.ammo_type.id == &"basic_ammo", "shared WeaponData carries no mutable selection or magazine")
	# Exhaust actual loaded rounds; fallback is announced on next R, not silently.
	await choose_ammo(&"fire_ammo")
	var fire_reserve := bag.get_item_amount(&"fire_ammo")
	if fire_reserve > 0: bag.remove_item(&"fire_ammo", fire_reserve)
	enemy = await target_zombie()
	var remaining := rifle.current_magazine
	for _i in remaining:
		aim_at(player, enemy.global_position + Vector3.UP)
		check(weapons.try_fire() and rifle.magazine_ammo_type.id == &"fire_ammo", "Fire magazine stays Fire to its final round")
		await frames(13)
	check(rifle.current_magazine == 0 and not weapons.try_fire(), "empty Fire cannot shoot free rounds or go negative")
	key(KEY_R)
	check(rifle.selected_ammo_type.id == &"basic_ammo" and game.hud.toast_label.text.contains("Switched to Basic Ammo"), "empty exhausted special explicitly falls back to Normal on reload")
	await frames(100)
	check(rifle.magazine_ammo_type.id == &"basic_ammo" and rifle.current_magazine > 0, "fallback reload consumes Normal only")
	enemy.despawn()
	await frames(3)
	# Production tick pauses DOT with the scene tree, then resumes and cleans death.
	enemy = await target_zombie()
	enemy.set_physics_process(true)
	enemy.apply_ammo_effect(game.catalog.get_item(&"poison_ammo"))
	var poisoned_hp := enemy.health.current_hp
	paused = true
	await create_timer(0.15,true).timeout
	check(enemy.health.current_hp == poisoned_hp, "Pause freezes status damage")
	paused = false
	await frames(30)
	check(enemy.health.current_hp < poisoned_hp, "unpause resumes production status tick")
	enemy.health.take_damage(10000)
	check(enemy.ammo_effects.is_empty() and enemy.state == NormalZombie.State.DEAD, "death clears status and existing zombie lifecycle")
	enemy.despawn()
	root.size = Vector2i(1920,1080)
	await frames(15)
	await capture("ammo_hud_1080p")
	var screen := Rect2(Vector2.ZERO,Vector2(root.size))
	check(screen.encloses(game.hud._equipment_panel.get_global_rect()), "ammo HUD fits 1080p")
	player.health.die()
	check(not weapons.cycle_ammo() and not weapons.start_reload(), "death blocks selector and reload")
	root.size = Vector2i(1280,720)
	await frames(5)
	await new_game()
	check(rifle.selected_ammo_type.id == &"basic_ammo" and rifle.current_magazine == 0, "new game resets runtime selection; no weapon save feature added")
	print("SPECIAL_AMMO_RESULT failures=", failures)
	game.queue_free()
	await frames(3)
	quit(failures)
