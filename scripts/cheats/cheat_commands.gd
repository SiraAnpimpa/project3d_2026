class_name CheatCommands
extends Node
## Deliberate player commands, available in release/Web as well as the editor.
## Use the normal inventory, spawn validation, progression and ending paths.

const ZOMBIES := [preload("res://scenes/enemies/NormalZombie.tscn"), preload("res://scenes/enemies/RunnerZombie.tscn"), preload("res://scenes/enemies/TankZombie.tscn")]
const ZOMBIE_NAMES := ["Normal", "Runner", "Tank"]
const MAX_ZOMBIES := 12
signal feedback(message: String)
var game: Node3D
var spawned: Array[NormalZombie] = []

func bind(root_game: Node3D) -> void:
	game = root_game

func available() -> bool:
	return game != null and game.preparation_complete and not game.player.health.is_dead and game.waves.state not in [NightWaveManager.State.GAME_OVER, NightWaveManager.State.GAME_COMPLETED] and not game.presentation.ending_started

func execute(action: StringName, value: int = 0) -> void:
	if not available(): return
	match action:
		&"day": _jump_day(clampi(value, 1, 10))
		&"next_day":
			if game.clock.current_day >= 10: _say("Already on the final day. Use Show ending to finish.")
			else: _jump_day(game.clock.current_day + 1)
		&"final_day": _jump_day(10)
		&"night":
			game.clock.skip_to_night()
			_say("Day %d · Night started" % game.clock.current_day)
		&"final_night":
			_jump_day(10)
			game.clock.skip_to_night()
			_say("Final night started · Original final wave")
		&"ending":
			# Dusk of Day 10 followed by dawn uses the real completion signal,
			# cleanup, rescue sequence and end screen. No invented terminal state.
			_jump_day(10)
			game.clock.skip_to_night()
			game.clock.skip_to_day()
		&"unlock_all":
			game.progression.unlock_all()
			_say("All seeds and recipes unlocked. Rewards wait if your bag is full.")
		&"weapons": _give_category(ItemData.ItemType.WEAPON, 1)
		&"materials": _give_category(ItemData.ItemType.MATERIAL, 25)
		&"seeds":
			game.progression.unlock_all()
			_give_category(ItemData.ItemType.SEED, 10)
		&"ammo": _give_category(ItemData.ItemType.AMMO, 100)
		&"heal":
			game.player.health.reset()
			game.player.stamina.reset()
			_say("HP and stamina restored")
		&"clear_zombies":
			clear_spawned()
			game.get_node("MainWorld/ZombieTestSpawner").clear_zombies()
			game.waves.debug_clear_wave()
			_say("All zombies cleared, including the current wave")

func _jump_day(day: int) -> void:
	clear_spawned()
	game.get_node("MainWorld/ZombieTestSpawner").clear_zombies()
	game.waves.debug_set_day(day)
	_say("Moved to Day %d · 06:00 · Current wave cleared" % day)

func give_item(item: ItemData, amount: int) -> bool:
	if not available() or item == null: return false
	if item.item_type == ItemData.ItemType.WEAPON:
		if game.inventory.has_item(item.id):
			_say("Already owned: " + item.display_name)
			return false
		amount = 1
	amount = clampi(amount, 1, 999)
	if not game.inventory.add_item(item, amount):
		_say("Bag full · Nothing added. Make room in Inventory.")
		return false
	if item.item_type == ItemData.ItemType.SEED:
		game.progression.unlocked_seed_ids[item.id] = true
		game.inventory.refresh_seed_selection()
		game.progression.changed.emit()
	_say("Added %s ×%d" % [item.display_name, amount])
	return true

func _give_category(category: int, amount: int) -> void:
	var added := 0
	var skipped := 0
	for item: ItemData in game.catalog.items:
		if item == null or item.item_type != category: continue
		if category == ItemData.ItemType.WEAPON and game.inventory.has_item(item.id): continue
		if game.inventory.add_item(item, amount): added += 1
		else: skipped += 1
	_say("Added %d item types%s" % [added, " · %d did not fit; make bag space" % skipped if skipped > 0 else ""])

func spawn_zombies(kind: int, count: int) -> int:
	if not available() or kind < 0 or kind >= ZOMBIES.size(): return 0
	var added := 0
	var target_count := mini(clampi(count, 1, MAX_ZOMBIES), MAX_ZOMBIES - spawned.size())
	# Search a ring around the player. The normal factory projects to navigation
	# and rejects obstacles, occupied space and points too close to the player.
	for attempt in 48:
		if added >= target_count: break
		var angle := float(attempt % 16) * TAU / 16.0
		var radius := 8.0 + float(attempt / 16) * 4.0
		var point: Vector3 = game.player.global_position + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		point.y = SceneryGrounding.surface_height(Vector2(point.x, point.z))
		var zombie := ZombieSpawnFactory.spawn(game.get_node("MainWorld"), ZOMBIES[kind], game.player, point, 6.0)
		if zombie == null: continue
		zombie.pursue_target = true
		spawned.append(zombie)
		zombie.tree_exiting.connect(func() -> void: spawned.erase(zombie))
		added += 1
	_say("Spawned %s ×%d · Cheat zombies %d / %d%s" % [ZOMBIE_NAMES[kind], added, spawned.size(), MAX_ZOMBIES, " · Limit reached or no safe space" if added < count else ""])
	return added

func clear_spawned() -> void:
	for zombie in spawned.duplicate():
		if is_instance_valid(zombie): zombie.despawn()
	spawned.clear()

func _say(message: String) -> void:
	feedback.emit(message)
