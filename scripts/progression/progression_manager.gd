class_name ProgressionManager
extends Node

signal changed
signal feedback(message: String)
@export var data: DayProgressionData
var unlocked_seed_ids: Dictionary = {}
var unlocked_recipe_ids: Dictionary = {}
var pending_rewards: Dictionary = {}
var rewarded_seed_ids: Dictionary = {}
var reached_days: Dictionary = {}
var summary: String = ""
var current: DayConfig
var inventory: Inventory
var catalog: ItemCatalog
var clock: GameClock
var _granting := false

func bind(time: GameClock, bag: Inventory, definitions: ItemCatalog, book: RecipeBook) -> void:
	clock = time
	inventory = bag
	catalog = definitions
	var errors := data.validation_errors(catalog, book) if data != null else PackedStringArray(["Missing progression data"])
	if not errors.is_empty():
		for error in errors: push_error(error)
		return
	inventory.progression = self
	inventory.inventory_changed.connect(claim_rewards)
	clock.day_started.connect(apply_day)
	apply_day(clock.current_day)

func apply_day(day: int) -> void:
	if day > 10: return # Dawn after Night 10 belongs to the terminal wave state.
	current = data.get_day(day)
	if current == null:
		push_error("Missing DayConfig for Day %d" % day)
		return
	var notices := PackedStringArray()
	# A forward debug jump grants missed unlocks once; backward seeks never revoke them.
	for number in range(1, day + 1):
		var config := data.get_day(number)
		if config == null:
			push_error("Missing DayConfig for Day %d" % number)
			return
		var already_reached := reached_days.has(number)
		reached_days[number] = true
		for id in config.seed_unlocks:
			if unlocked_seed_ids.has(id): continue
			unlocked_seed_ids[id] = true
			_grant_seed_once(id, config.starter_quantity)
			notices.append("NEW SEED: " + catalog.get_item(id).display_name)
		for id in config.recipe_unlocks:
			if unlocked_recipe_ids.has(id): continue
			unlocked_recipe_ids[id] = true
			notices.append("NEW RECIPE: " + String(id).replace("_", " ").capitalize())
		# Debug jumps do not accumulate skipped daily supplies.
		if number == day and not already_reached:
			for id in config.supply_seed_ids:
				if unlocked_seed_ids.has(id): _queue_reward(id, config.supply_quantity)
			if config.supply_quantity > 0: notices.append("Daily basic seeds x%d each" % config.supply_quantity)
			if not config.message.is_empty(): notices.append(config.message)
	claim_rewards()
	inventory.refresh_seed_selection()
	if not notices.is_empty():
		summary = "DAY %d / 10\n%s" % [day, "\n".join(notices)]
		feedback.emit.call_deferred(summary)
	changed.emit()

func _queue_reward(id: StringName, amount: int) -> void:
	if amount > 0: pending_rewards[id] = int(pending_rewards.get(id, 0)) + amount

func claim_rewards() -> void:
	if _granting: return
	_granting = true
	for id in pending_rewards.keys():
		var amount: int = pending_rewards[id]
		if inventory.add_item(catalog.get_item(id), amount): pending_rewards.erase(id)
	_granting = false
	changed.emit()

func is_seed_unlocked(id: StringName) -> bool:
	return unlocked_seed_ids.has(id)

func is_recipe_unlocked(id: StringName) -> bool:
	return unlocked_recipe_ids.has(id)

func reset_unlocks() -> void:
	# Debug reset does not reset reward receipts, preventing repeated free seed grants.
	unlocked_seed_ids.clear()
	unlocked_recipe_ids.clear()
	for config in data.days:
		if config.day > clock.current_day: continue
		for id in config.seed_unlocks: unlocked_seed_ids[id] = true
		for id in config.recipe_unlocks: unlocked_recipe_ids[id] = true
	inventory.refresh_seed_selection()
	changed.emit()

func unlock_all() -> void:
	for config in data.days:
		for id in config.seed_unlocks:
			if not unlocked_seed_ids.has(id):
				unlocked_seed_ids[id] = true
				_grant_seed_once(id, config.starter_quantity)
		for id in config.recipe_unlocks: unlocked_recipe_ids[id] = true
	claim_rewards()
	inventory.refresh_seed_selection()
	changed.emit()


func _grant_seed_once(id: StringName, amount: int) -> void:
	if rewarded_seed_ids.has(id): return
	rewarded_seed_ids[id] = true
	_queue_reward(id, amount)
