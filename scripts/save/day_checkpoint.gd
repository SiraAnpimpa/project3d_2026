extends Node
## A single run, checkpointed at dawn. Midday changes never overwrite the morning.

signal changed
signal save_failed
const VERSION := 1
const FILES := ["user://day_checkpoint_a.json", "user://day_checkpoint_b.json"]
const WEAPONS := ["pistol", "wooden_bat", "knife", "sword", "smg", "basic_rifle", "marksman_rifle"]
var _pending: Dictionary = {}
var _game: Node3D
var _checkpoint_day := 0

func begin_new() -> void:
	_pending.clear()

func request_continue() -> bool:
	_pending = read_checkpoint()
	return not _pending.is_empty()

func has_checkpoint() -> bool:
	return not read_checkpoint().is_empty()

func saved_day() -> int:
	return int(read_checkpoint().get("day", 0))

func prepare_clock(clock: GameClock) -> void:
	if _pending.is_empty(): return
	clock.set_block_signals(true)
	clock.seek(int(_pending.day), 6, 0)
	clock.set_block_signals(false)

func bind(game: Node3D) -> void:
	_game = game
	_checkpoint_day = 0
	if not _pending.is_empty():
		var snapshot := _pending.duplicate(true)
		_pending.clear()
		if not _restore(game, snapshot):
			game.hud.show_message("Unable to load save")
			return
		_checkpoint_day = game.clock.current_day
	else:
		capture_morning(game.clock.current_day)
	game.clock.day_started.connect(_on_dawn.bind(game))
	game.waves.completed.connect(_complete_run.bind(game))

func _on_dawn(day: int, game: Node3D) -> void:
	# Progression, crop growth and rest healing finish their synchronous signals first.
	if day != _checkpoint_day and day <= 10: _capture_dawn.call_deferred(day, game)

func _capture_dawn(day: int, game: Node3D) -> void:
	if is_instance_valid(game) and game == _game and game.clock.current_day == day:
		capture_morning(day)

func capture_morning(day: int) -> bool:
	if not is_instance_valid(_game) or day < 1 or day > 10 or _game.player.health.is_dead: return false
	var game := _game
	var bag: Array = []
	for slot: InventorySlot in game.inventory.get_slots(): bag.append({"id": String(slot.item.id), "quantity": slot.quantity})
	var equipment: Array = []
	for index in game.equipment.weapon_slot_count:
		var item: ItemData = game.equipment.get_equipped_weapon(index)
		equipment.append(String(item.id) if item != null else "")
	var magazines: Array = []
	for id: StringName in game.weapons.runtimes:
		var state: WeaponRuntime = game.weapons.runtimes[id]
		if not game.inventory.has_item(id): continue
		magazines.append({"id": String(id), "rounds": state.current_magazine, "selected": _item_id(state.selected_ammo_type), "loaded": _item_id(state.magazine_ammo_type)})
	var crops: Array = []
	for plot in game.get_node("MainWorld/FarmArea").get_children():
		if plot is FarmPlot: crops.append(plot.checkpoint_state())
	var progression: ProgressionManager = game.progression
	var pending: Array = []
	for id in progression.pending_rewards: pending.append({"id": String(id), "amount": progression.pending_rewards[id]})
	var choices: Array = []
	for reward_day in progression.daily_seed_choices:
		choices.append({"day": reward_day, "amount": progression.seed_reward_amount(reward_day), "options": _strings(progression.seed_reward_options(reward_day))})
	var receipts: Array = []
	for reward_day in progression.daily_seed_receipts: receipts.append({"day": reward_day, "id": String(progression.daily_seed_receipts[reward_day])})
	var snapshot := {"day": day, "bag": bag, "equipment": equipment, "selected_weapon": game.equipment.selected_weapon_slot,
		"selected_seed": String(game.inventory.selected_seed_id), "magazines": magazines, "crops": crops,
		"health": game.player.health.current_hp, "stamina": game.player.stamina.current_stamina, "exhausted": game.player.stamina.exhausted,
		"crafted": _strings(game.crafting_system.crafted_weapon_ids.keys()),
		"progression": {"seeds": _strings(progression.unlocked_seed_ids.keys()), "recipes": _strings(progression.unlocked_recipe_ids.keys()),
			"rewarded": _strings(progression.rewarded_seed_ids.keys()), "reached": progression.reached_days.keys(),
			"pending": pending, "choices": choices, "receipts": receipts}}
	if not _valid_snapshot(snapshot) or not _write(snapshot):
		save_failed.emit()
		game.hud.show_message("Unable to save progress")
		return false
	_checkpoint_day = day
	return true

func _complete_run(game: Node3D) -> void:
	if game == _game:
		_pending.clear()
		if not _write({"complete": true}): save_failed.emit()

func read_checkpoint() -> Dictionary:
	var record := _latest()
	if record.is_empty() or record.data.get("complete", false): return {}
	return record.data.duplicate(true)

func _latest() -> Dictionary:
	var newest: Dictionary = {}
	for path in FILES:
		var record := _read_slot(path)
		if not record.is_empty() and int(record.sequence) > int(newest.get("sequence", 0)): newest = record
	return newest

func _read_slot(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 262144: return {}
	var text := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK: return {}
	var decoded: Variant = parser.data
	if not decoded is Dictionary or decoded.get("version") != VERSION or not _integer(decoded.get("sequence"), 1, 9007199254740990): return {}
	var payload: Variant = decoded.get("payload")
	if not payload is String or decoded.get("checksum") != payload.sha256_text(): return {}
	var state_parser := JSON.new()
	if state_parser.parse(payload) != OK: return {}
	var data: Variant = state_parser.data
	if not data is Dictionary or not _valid_snapshot(data): return {}
	return {"sequence": int(decoded.sequence), "data": data}

func _write(snapshot: Dictionary) -> bool:
	var last := _latest()
	var sequence := int(last.get("sequence", 0)) + 1
	# Alternate slots: an interrupted write leaves the preceding dawn recoverable.
	var path: String = FILES[sequence % 2]
	var payload := JSON.stringify(snapshot)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify({"version": VERSION, "sequence": sequence, "payload": payload, "checksum": payload.sha256_text()}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK or _read_slot(path).get("sequence", 0) != sequence: return false
	changed.emit()
	return true

func _restore(game: Node3D, snapshot: Dictionary) -> bool:
	if not _valid_snapshot(snapshot) or snapshot.get("complete", false): return false
	var plots := {}
	for plot in game.get_node("MainWorld/FarmArea").get_children():
		if plot is FarmPlot: plots[String(plot.name)] = plot
	if plots.size() != snapshot.crops.size(): return false
	for crop in snapshot.crops:
		if not plots.has(crop.name): return false
	var progression: ProgressionManager = game.progression
	# Seek without replaying dawn rewards; restore their receipts from the checkpoint.
	game.clock.set_block_signals(true)
	game.clock.seek(int(snapshot.day), 6, 0)
	game.clock.set_block_signals(false)
	var saved: Dictionary = snapshot.progression
	progression.unlocked_seed_ids = _id_set(saved.seeds)
	progression.unlocked_recipe_ids = _id_set(saved.recipes)
	progression.rewarded_seed_ids = _id_set(saved.rewarded)
	progression.reached_days.clear()
	for day in saved.reached: progression.reached_days[int(day)] = true
	progression.pending_rewards.clear()
	for reward in saved.pending: progression.pending_rewards[StringName(reward.id)] = int(reward.amount)
	progression.daily_seed_choices.clear()
	for choice in saved.choices:
		var options: Array[StringName] = []
		for id in choice.options: options.append(StringName(id))
		progression.daily_seed_choices[int(choice.day)] = {"amount": int(choice.amount), "options": options}
	progression.daily_seed_receipts.clear()
	for receipt in saved.receipts: progression.daily_seed_receipts[int(receipt.day)] = StringName(receipt.id)
	progression.current = progression.data.get_day(int(snapshot.day))
	progression.summary = ""
	progression._granting = true
	game.inventory.clear()
	for slot in snapshot.bag: game.inventory.add_item(game.catalog.get_item(StringName(slot.id)), int(slot.quantity))
	progression._granting = false
	game.inventory.select_seed(StringName(snapshot.selected_seed))
	game.equipment.configure_slots(snapshot.equipment.size())
	for index in snapshot.equipment.size():
		game.equipment.unequip_weapon(index)
		if not snapshot.equipment[index].is_empty(): game.equipment.equip_weapon(index, game.catalog.get_item(StringName(snapshot.equipment[index])))
	game.equipment.selected_weapon_slot = int(snapshot.selected_weapon)
	game.weapons.runtimes.clear()
	game.weapons.current = null
	for magazine in snapshot.magazines:
		var definition := _weapon(magazine.id)
		var state := WeaponRuntime.new(definition)
		state.current_magazine = int(magazine.rounds)
		state.selected_ammo_type = game.catalog.get_item(StringName(magazine.selected)) if not magazine.selected.is_empty() else null
		state.magazine_ammo_type = game.catalog.get_item(StringName(magazine.loaded)) if not magazine.loaded.is_empty() else null
		game.weapons.runtimes[definition.weapon_id] = state
	game.crafting_system.crafted_weapon_ids.clear()
	for id in snapshot.crafted: game.crafting_system.crafted_weapon_ids[StringName(id)] = true
	for crop in snapshot.crops: plots[crop.name].restore_checkpoint(crop)
	game.player.health._set_hp(float(snapshot.health))
	game.player.stamina._set_stamina(float(snapshot.stamina))
	game.player.stamina.exhausted = snapshot.exhausted
	game.waves.data = progression.current.wave
	game.waves._last_started_day = int(snapshot.day) - 1
	game.equipment.equipment_changed.emit()
	game.weapons.state_changed.emit()
	game.clock.time_changed.emit(int(snapshot.day), 6, 0, true)
	progression.changed.emit()
	game.inventory.refresh_seed_selection()
	return true

func _valid_snapshot(data: Dictionary) -> bool:
	if data.size() == 1 and data.get("complete") == true: return true
	if not _integer(data.get("day"), 1, 10): return false
	for key in ["bag", "equipment", "magazines", "crops", "crafted"]:
		if not data.get(key) is Array: return false
	if not data.get("progression") is Dictionary or not data.get("exhausted") is bool or not _number(data.get("health"), 0.001, 100) or not _number(data.get("stamina"), 0, 100): return false
	var catalog := load("res://resources/catalog.tres") as ItemCatalog
	var book := load("res://resources/recipes/book.tres") as RecipeBook
	if data.bag.size() > 24 or data.equipment.size() != 3 or not _integer(data.get("selected_weapon"), -1, 2): return false
	var owned := {}
	for slot in data.bag:
		if not slot is Dictionary or not slot.get("id") is String: return false
		var item := catalog.get_item(StringName(slot.id))
		if item == null or not _integer(slot.get("quantity"), 1, item.max_stack): return false
		owned[slot.id] = true
	var equipped := {}
	for id in data.equipment:
		if not id is String: return false
		if id.is_empty(): continue
		if id not in WEAPONS or not owned.has(id) or equipped.has(id): return false
		equipped[id] = true
	if int(data.selected_weapon) >= 0 and data.equipment[int(data.selected_weapon)].is_empty(): return false
	if int(data.selected_weapon) == -1 and not equipped.is_empty(): return false
	if not data.get("selected_seed") is String: return false
	if not data.selected_seed.is_empty():
		var seed := catalog.get_item(StringName(data.selected_seed))
		if seed == null or not seed.plantable or not owned.has(data.selected_seed): return false
	var seen := {}
	for magazine in data.magazines:
		if not magazine is Dictionary or magazine.get("id") not in WEAPONS or seen.has(magazine.id) or not owned.has(magazine.id): return false
		seen[magazine.id] = true
		var definition := _weapon(magazine.id)
		if not _integer(magazine.get("rounds"), 0, definition.magazine_size): return false
		for key in ["selected", "loaded"]:
			if not magazine.get(key) is String: return false
			if definition.is_melee():
				if not magazine[key].is_empty(): return false
			elif not definition.supports_ammo(catalog.get_item(StringName(magazine[key]))): return false
	seen.clear()
	for crop in data.crops:
		if not crop is Dictionary or not crop.get("name") is String or seen.has(crop.name) or not crop.get("plant") is String: return false
		seen[crop.name] = true
		if crop.plant.is_empty(): continue
		var plant := catalog.get_plant(StringName(crop.plant))
		if plant == null or not _number(crop.get("age"), 0, plant.growth_minutes): return false
	for id in data.crafted:
		if not id is String or id not in WEAPONS: return false
	var p: Dictionary = data.progression
	for key in ["seeds", "recipes", "rewarded", "reached", "pending", "choices", "receipts"]:
		if not p.get(key) is Array: return false
	for key in ["seeds", "rewarded"]:
		for id in p[key]:
			if not id is String: return false
			var item := catalog.get_item(StringName(id))
			if item == null or item.item_type != ItemData.ItemType.SEED: return false
	for id in p.recipes:
		if not id is String or book.get_recipe(StringName(id)) == null: return false
	for day in p.reached:
		if not _integer(day, 1, 10): return false
	for reward in p.pending:
		if not reward is Dictionary or not reward.get("id") is String or catalog.get_item(StringName(reward.id)) == null or not _integer(reward.get("amount"), 1, 9999): return false
	seen.clear()
	for choice in p.choices:
		if not choice is Dictionary or not _integer(choice.get("day"), 1, 10) or seen.has(int(choice.day)) or not _integer(choice.get("amount"), 1, 99) or not choice.get("options") is Array or choice.options.is_empty(): return false
		seen[int(choice.day)] = true
		for id in choice.options:
			if not id is String or StringName(id) not in ProgressionManager.SPECIAL_SEED_IDS or id not in p.seeds: return false
	for receipt in p.receipts:
		if not receipt is Dictionary or not _integer(receipt.get("day"), 1, 10) or seen.has(int(receipt.day)) or not receipt.get("id") is String or StringName(receipt.id) not in ProgressionManager.SPECIAL_SEED_IDS: return false
		seen[int(receipt.day)] = true
	return true

func _weapon(id: String) -> WeaponData:
	return load("res://resources/weapons/%s.tres" % id) as WeaponData

func _item_id(item: ItemData) -> String:
	return String(item.id) if item != null else ""

func _strings(values: Array) -> Array:
	var result: Array = []
	for value in values: result.append(String(value))
	return result

func _id_set(values: Array) -> Dictionary:
	var result := {}
	for value in values: result[StringName(value)] = true
	return result

func _number(value: Variant, minimum: float, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) >= minimum and float(value) <= maximum

func _integer(value: Variant, minimum: int, maximum: int) -> bool:
	return _number(value, minimum, maximum) and float(value) == floorf(float(value))
