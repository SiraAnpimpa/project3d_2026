class_name InventoryLoadout
extends Resource

@export var items: Array[ItemData] = []
@export var quantities: PackedInt32Array = PackedInt32Array()


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if items.size() != quantities.size():
		errors.append("Starter loadout: items and quantities must have equal length.")
		return errors
	for index in items.size():
		if items[index] == null:
			errors.append("Starter loadout: item %d is missing." % index)
		else:
			errors.append_array(items[index].validation_errors())
		if quantities[index] <= 0:
			errors.append("Starter loadout: quantity %d must be positive." % index)
	return errors


func give_to(inventory: Inventory) -> bool:
	if inventory == null or not validation_errors().is_empty():
		return false
	# Preflight the entire loadout, including interactions between its stacks.
	var trial := Inventory.new()
	trial.capacity = inventory.capacity
	for slot in inventory.get_slots():
		trial.add_item(slot.item, slot.quantity)
	var fits := true
	for index in items.size():
		if not trial.add_item(items[index], quantities[index]):
			fits = false
			break
	trial.free()
	if not fits:
		return false
	for index in items.size():
		inventory.add_item(items[index], quantities[index])
	return true
