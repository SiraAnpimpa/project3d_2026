extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, description: String) -> void:
	if ok:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func run() -> void:
	var item: ItemData = load("res://resources/items/lead.tres")
	var seed: ItemData = load("res://resources/items/seed_lead.tres")
	check(item != null and seed != null and item.validation_errors().is_empty(), "item Resources load and validate")
	var inventory := Inventory.new()
	inventory.capacity = 2
	check(inventory.add_item(item, 110), "add spans multiple stacks")
	var slots := inventory.get_slots()
	check(slots.size() == 2 and slots[0].quantity == 99 and slots[1].quantity == 11, "stack limits respected")
	slots[0].quantity = 0
	check(inventory.get_item_amount(item.id) == 110, "slot snapshots cannot mutate inventory")
	check(not inventory.add_item(seed, 1) and inventory.get_item_amount(seed.id) == 0, "full inventory rejects new type atomically")
	check(inventory.add_item(item, 88) and inventory.get_item_amount(item.id) == 198, "full slot count still accepts existing stack space")
	check(not inventory.add_item(item, 1) and inventory.get_item_amount(item.id) == 198, "full stacks reject overflow without loss")
	check(not inventory.remove_item(item.id, 199) and inventory.get_item_amount(item.id) == 198, "over-removal does not partially remove")
	check(not inventory.add_item(item, -1) and not inventory.remove_item(item.id, -1), "negative requests rejected")
	check(not inventory.add_item(item, 0) and not inventory.has_item(item.id, 0), "zero requests rejected")
	check(inventory.remove_item(item.id, 100) and inventory.get_slots().size() == 1 and inventory.get_item_amount(item.id) == 98, "removal spans stacks and releases empty slots")
	check(inventory.add_item(seed, 3) and inventory.select_seed(seed.id), "seed selection only uses owned seed")
	check(not inventory.select_seed(item.id), "materials cannot become selected seed")
	check(inventory.remove_item(seed.id, 3) and not inventory.has_item(seed.id), "seed amount reaches zero without going negative")
	check(inventory.get_selected_seed() == null and not inventory.select_seed(seed.id), "last exhausted seed clears selection and cannot be reselected")
	var bad := ItemData.new()
	bad.max_stack = 0
	check(not bad.validation_errors().is_empty() and not inventory.add_item(bad), "invalid definition rejected safely")
	var duplicate := item.duplicate() as ItemData
	duplicate.max_stack = 1000
	check(not inventory.add_item(duplicate), "conflicting definition for same id rejected")
	var loadout: InventoryLoadout = load("res://resources/inventory/starter_loadout.tres")
	check(not loadout.give_to(inventory) and inventory.get_item_amount(item.id) == 98, "entire starter bundle rejects atomically when too large")
	inventory.clear()
	inventory.capacity = 24
	check(loadout.give_to(inventory) and inventory.get_slots().size() == 5, "all five starter seed types granted")
	check(inventory.get_item_amount(&"seed_lead") == 3, "starter quantities come from data")
	inventory.free()
	print("PHASE_3_INVENTORY_RESULT failures=", failures)
	quit(failures)
