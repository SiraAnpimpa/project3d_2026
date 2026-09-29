class_name Inventory
extends Node

signal inventory_changed
signal selection_changed

@export_range(1, 100) var capacity: int = 24

var selected_seed_id: StringName
var _slots: Array[InventorySlot] = []
var _definitions: Dictionary[StringName, ItemData] = {}


func get_slots() -> Array[InventorySlot]:
	# Callers can inspect a snapshot without mutating live quantities.
	var snapshot: Array[InventorySlot] = []
	for slot in _slots:
		snapshot.append(InventorySlot.new(slot.item, slot.quantity))
	return snapshot


func get_item_amount(item_id: StringName) -> int:
	var amount := 0
	for slot in _slots:
		if slot.item.id == item_id:
			amount += slot.quantity
	return amount


func has_item(item_id: StringName, amount: int = 1) -> bool:
	return amount > 0 and get_item_amount(item_id) >= amount


func can_add_item(item: ItemData, amount: int = 1) -> bool:
	if not _valid_item(item) or amount <= 0:
		return false
	var space := maxi(0, capacity - _slots.size()) * item.max_stack
	for slot in _slots:
		if slot.item.id == item.id:
			space += maxi(0, item.max_stack - slot.quantity)
	return space >= amount


func add_item(item: ItemData, amount: int = 1) -> bool:
	# Atomic: rejected requests never partially add items.
	if not can_add_item(item, amount):
		return false
	_definitions[item.id] = item
	var remaining := amount
	for slot in _slots:
		if slot.item.id == item.id:
			var moved := mini(item.max_stack - slot.quantity, remaining)
			slot.quantity += moved
			remaining -= moved
			if remaining == 0:
				break
	while remaining > 0:
		var moved := mini(item.max_stack, remaining)
		_slots.append(InventorySlot.new(item, moved))
		remaining -= moved
	_repair_seed_selection()
	inventory_changed.emit()
	return true


func remove_item(item_id: StringName, amount: int = 1) -> bool:
	if not has_item(item_id, amount):
		return false
	var remaining := amount
	for index in range(_slots.size() - 1, -1, -1):
		var slot := _slots[index]
		if slot.item.id != item_id:
			continue
		var removed := mini(remaining, slot.quantity)
		slot.quantity -= removed
		remaining -= removed
		if slot.quantity == 0:
			_slots.remove_at(index)
		if remaining == 0:
			break
	_repair_seed_selection()
	inventory_changed.emit()
	return true


func can_exchange_items(removals: Dictionary, additions: Dictionary) -> bool:
	return _simulate_exchange(removals, additions).get("ok", false)


func exchange_items(removals: Dictionary, additions: Dictionary) -> bool:
	# Stage every stack mutation first. Publish a single committed inventory change.
	var result := _simulate_exchange(removals, additions)
	if not result.get("ok", false):
		return false
	_slots = result["slots"]
	_definitions = result["definitions"]
	_repair_seed_selection()
	inventory_changed.emit()
	return true


func _simulate_exchange(removals: Dictionary, additions: Dictionary) -> Dictionary:
	var staged: Array[InventorySlot] = get_slots()
	var definitions: Dictionary[StringName, ItemData] = _definitions.duplicate()
	for group in [removals, additions]:
		if group.is_empty():
			return {"ok": false}
		for item in group:
			var amount: Variant = group[item]
			if not item is ItemData or not amount is int or amount <= 0:
				return {"ok": false}
			var data := item as ItemData
			if not data.validation_errors().is_empty():
				return {"ok": false}
			if definitions.has(data.id) and definitions[data.id] != data:
				return {"ok": false}
			definitions[data.id] = data
	for item in removals:
		var remaining: int = removals[item]
		if get_item_amount(item.id) < remaining:
			return {"ok": false}
		for index in range(staged.size() - 1, -1, -1):
			var slot := staged[index]
			if slot.item.id != item.id:
				continue
			var removed := mini(slot.quantity, remaining)
			slot.quantity -= removed
			remaining -= removed
			if slot.quantity == 0:
				staged.remove_at(index)
			if remaining == 0:
				break
	for item in additions:
		var remaining: int = additions[item]
		for slot in staged:
			if slot.item.id != item.id:
				continue
			var moved := mini(item.max_stack - slot.quantity, remaining)
			slot.quantity += moved
			remaining -= moved
			if remaining == 0:
				break
		while remaining > 0 and staged.size() < capacity:
			var moved := mini(item.max_stack, remaining)
			staged.append(InventorySlot.new(item, moved))
			remaining -= moved
		if remaining > 0:
			return {"ok": false}
	return {"ok": true, "slots": staged, "definitions": definitions}


func select_seed(item_id: StringName) -> bool:
	var item: ItemData = _definitions.get(item_id)
	if item == null or not _is_selectable_seed(item) or not has_item(item_id):
		return false
	selected_seed_id = item_id
	selection_changed.emit()
	return true


func get_selected_seed() -> ItemData:
	var item: ItemData = _definitions.get(selected_seed_id)
	return item if _is_selectable_seed(item) and has_item(selected_seed_id) else null


func clear() -> void:
	_slots.clear()
	_definitions.clear()
	selected_seed_id = &""
	inventory_changed.emit()
	selection_changed.emit()


func _valid_item(item: ItemData) -> bool:
	if item == null or not item.validation_errors().is_empty():
		return false
	# A single ID must keep one definition during this inventory's lifetime.
	return not _definitions.has(item.id) or _definitions[item.id] == item


func get_item_definition(item_id: StringName) -> ItemData:
	return _definitions.get(item_id)


func get_selectable_seeds() -> Array[ItemData]:
	# One entry per item ID, independent of stack count or bag slot positions.
	var result: Array[ItemData] = []
	var seen: Dictionary = {}
	for slot in _slots:
		if slot.quantity > 0 and _is_selectable_seed(slot.item) and not seen.has(slot.item.id):
			result.append(slot.item)
			seen[slot.item.id] = true
	result.sort_custom(_seed_before)
	return result


func cycle_seed(direction: int) -> bool:
	var seeds := get_selectable_seeds()
	if seeds.is_empty() or direction == 0:
		return false
	var current := seeds.find(get_selected_seed())
	return select_seed(seeds[posmod(current + direction, seeds.size())].id)


func _is_selectable_seed(item: ItemData) -> bool:
	return item != null and item.item_type == ItemData.ItemType.SEED and item.plantable


func _seed_before(a: ItemData, b: ItemData) -> bool:
	if a.tier != b.tier:
		return a.tier < b.tier
	if a.display_order != b.display_order:
		return a.display_order < b.display_order
	# IDs provide a deterministic tie-break, never a name-based progression rule.
	return String(a.id) < String(b.id)


func _repair_seed_selection() -> void:
	if get_selected_seed() != null:
		return
	var previous: ItemData = _definitions.get(selected_seed_id)
	var seeds := get_selectable_seeds()
	var next_id: StringName = &""
	if not seeds.is_empty():
		next_id = seeds[0].id
		for seed in seeds:
			if previous != null and _seed_before(previous, seed):
				next_id = seed.id
				break
	if selected_seed_id != next_id:
		selected_seed_id = next_id
		selection_changed.emit()
