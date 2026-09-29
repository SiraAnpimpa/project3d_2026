class_name EquipmentLoadout
extends Node

signal equipment_changed

@export_range(1, 12) var weapon_slot_count: int = 3
var selected_weapon_slot: int = -1
var _slots: Array[ItemData] = []
var _inventory: Inventory


func _ready() -> void:
	configure_slots(weapon_slot_count)


func bind(inventory: Inventory) -> void:
	_inventory = inventory
	inventory.inventory_changed.connect(_reconcile_owned)
	_reconcile_owned()


func configure_slots(count: int) -> bool:
	if count < 1:
		return false
	weapon_slot_count = count
	_slots.resize(count)
	_repair_selection()
	equipment_changed.emit()
	return true


func equip_weapon(slot: int, weapon: ItemData) -> bool:
	if not _valid_slot(slot) or weapon == null or weapon.item_type != ItemData.ItemType.WEAPON:
		return false
	if _inventory == null or not _inventory.has_item(weapon.id) or _inventory.get_item_definition(weapon.id) != weapon:
		return false
	# Equipment references owned items. Moving a weapon does not consume it.
	var previous := _slots.find(weapon)
	if previous >= 0 and previous != slot:
		_slots[previous] = null
		if selected_weapon_slot == previous:
			selected_weapon_slot = slot
	_slots[slot] = weapon
	_repair_selection()
	equipment_changed.emit()
	return true


func unequip_weapon(slot: int) -> bool:
	if not _valid_slot(slot) or _slots[slot] == null:
		return false
	_slots[slot] = null
	_repair_selection()
	equipment_changed.emit()
	return true


func get_equipped_weapon(slot: int) -> ItemData:
	return _slots[slot] if _valid_slot(slot) else null


func get_selected_weapon() -> ItemData:
	return get_equipped_weapon(selected_weapon_slot)


func cycle_weapon(direction: int) -> bool:
	var occupied := _occupied_slots()
	if occupied.is_empty() or direction == 0:
		return false
	var index := occupied.find(selected_weapon_slot)
	selected_weapon_slot = occupied[posmod(index + direction, occupied.size())]
	equipment_changed.emit()
	return true


func _valid_slot(slot: int) -> bool:
	return slot >= 0 and slot < _slots.size()


func _occupied_slots() -> Array[int]:
	var result: Array[int] = []
	for index in _slots.size():
		if _slots[index] != null:
			result.append(index)
	return result


func _repair_selection() -> void:
	if get_selected_weapon() != null:
		return
	var occupied := _occupied_slots()
	for index in occupied:
		if index > selected_weapon_slot:
			selected_weapon_slot = index
			return
	selected_weapon_slot = occupied[0] if not occupied.is_empty() else -1


func _reconcile_owned() -> void:
	if _inventory == null:
		return
	var changed := false
	for index in _slots.size():
		var weapon := _slots[index]
		if weapon != null and (not _inventory.has_item(weapon.id) or _inventory.get_item_definition(weapon.id) != weapon):
			_slots[index] = null
			changed = true
	var previous := selected_weapon_slot
	_repair_selection()
	if changed or previous != selected_weapon_slot:
		equipment_changed.emit()
