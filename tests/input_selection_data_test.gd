extends SceneTree

var failures := 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func item(id: String, type: ItemData.ItemType, tier: int = 1, order: int = 0) -> ItemData:
	var data := ItemData.new()
	data.id = StringName(id)
	data.display_name = id
	data.item_type = type
	data.tier = tier
	data.display_order = order
	if type == ItemData.ItemType.SEED:
		data.plantable = true
		data.plant_id = StringName("plant_" + id)
	return data

func ids(inventory: Inventory) -> Array[StringName]:
	var result: Array[StringName] = []
	for seed in inventory.get_selectable_seeds(): result.append(seed.id)
	return result

func run() -> void:
	var inventory := Inventory.new()
	inventory.capacity = 64
	root.add_child(inventory)
	var loadout := EquipmentLoadout.new()
	root.add_child(loadout)
	loadout.bind(inventory)
	check(inventory.get_selectable_seeds().is_empty() and not inventory.cycle_seed(1), "empty seed list handles scroll safely")
	check(loadout.weapon_slot_count == 3 and loadout.selected_weapon_slot == -1 and not loadout.cycle_weapon(1), "three empty weapon slots have no selected weapon and safely ignore wheel")
	var late := item("late", ItemData.ItemType.SEED, 3, 5)
	var first := item("first", ItemData.ItemType.SEED, 1, 10)
	var middle := item("middle", ItemData.ItemType.SEED, 1, 20)
	first.display_name = "ZZZ First by progression"
	middle.display_name = "AAA Later by progression"
	inventory.add_item(late, 1)
	inventory.add_item(middle, 2)
	inventory.add_item(first, 101)
	check(ids(inventory) == [&"first", &"middle", &"late"], "selector orders by tier then display_order, independent of name or insertion")
	check(inventory.get_selectable_seeds().size() == 3 and inventory.get_item_amount(first.id) == 101, "multiple stacks aggregate as one selectable seed")
	var blocked := item("blocked", ItemData.ItemType.SEED)
	blocked.plantable = false
	var material := item("material", ItemData.ItemType.MATERIAL)
	material.plantable = true
	inventory.add_item(blocked)
	inventory.add_item(material)
	check(ids(inventory) == [&"first", &"middle", &"late"] and not inventory.select_seed(blocked.id), "nonplantable seeds and other types are excluded")
	inventory.select_seed(first.id)
	check(inventory.cycle_seed(-1) and inventory.selected_seed_id == late.id, "wheel up wraps to last seed")
	check(inventory.cycle_seed(1) and inventory.selected_seed_id == first.id, "wheel down wraps to first seed")
	inventory.remove_item(first.id, 100)
	check(inventory.selected_seed_id == first.id and inventory.get_item_amount(first.id) == 1, "partial depletion preserves selection")
	inventory.remove_item(first.id)
	check(inventory.selected_seed_id == middle.id and ids(inventory) == [&"middle", &"late"], "depleting selected seed removes it and chooses next progression entry")
	inventory.select_seed(late.id)
	inventory.remove_item(late.id)
	check(inventory.selected_seed_id == middle.id, "depleting last sorted seed wraps to first valid seed")
	inventory.remove_item(middle.id, 2)
	check(inventory.get_selected_seed() == null and inventory.selected_seed_id == &"" and not inventory.cycle_seed(-1), "depleting final seed clears selection without invalid indices")
	inventory.add_item(first)
	check(inventory.get_selected_seed() == first, "newly acquired seed auto-selects when list was empty")
	var tie_b := item("tie_b", ItemData.ItemType.SEED, 4, 1)
	var tie_a := item("tie_a", ItemData.ItemType.SEED, 4, 1)
	inventory.add_item(tie_b)
	inventory.add_item(tie_a)
	check(ids(inventory).slice(-2) == [&"tie_a", &"tie_b"], "equal tier/order uses stable ID tie-break")
	for index in 30:
		inventory.add_item(item("additional_%02d" % index, ItemData.ItemType.SEED, 5, index))
	check(inventory.get_selectable_seeds().size() == 33, "dynamic selector exceeds both three equipment slots and a 24-slot hotbar")
	var bad := item("bad", ItemData.ItemType.SEED, 0, -1)
	check(not inventory.add_item(bad), "invalid tier and display order fail data validation")
	var weapons: Array[ItemData] = []
	for index in 5:
		var weapon := item("weapon_%d" % index, ItemData.ItemType.WEAPON)
		weapon.max_stack = 1
		weapons.append(weapon)
		inventory.add_item(weapon)
	check(not loadout.equip_weapon(-1, weapons[0]) and not loadout.equip_weapon(3, weapons[0]), "out-of-range equipment slots fail safely")
	check(not loadout.equip_weapon(0, material) and not loadout.equip_weapon(0, item("unowned", ItemData.ItemType.WEAPON)), "only owned weapon items can be equipped")
	check(loadout.equip_weapon(0, weapons[0]) and loadout.equip_weapon(2, weapons[2]), "owned weapons equip into chosen slots")
	check(loadout.selected_weapon_slot == 0 and loadout.get_selected_weapon() == weapons[0], "first equipped weapon becomes selected")
	check(loadout.cycle_weapon(1) and loadout.selected_weapon_slot == 2 and loadout.cycle_weapon(1) and loadout.selected_weapon_slot == 0, "combat cycle skips empty slots and excludes unequipped owned weapons")
	check(inventory.get_item_amount(weapons[0].id) == 1 and inventory.get_item_amount(weapons[2].id) == 1, "equipping and cycling never consume inventory quantities")
	loadout.equip_weapon(1, weapons[0])
	check(loadout.get_equipped_weapon(0) == null and loadout.get_equipped_weapon(1) == weapons[0] and loadout.selected_weapon_slot == 1, "moving an equipped weapon preserves its selection without duplicates")
	loadout.equip_weapon(1, weapons[3])
	check(loadout.get_selected_weapon() == weapons[3] and inventory.has_item(weapons[0].id), "replacing slot leaves previous weapon owned")
	loadout.unequip_weapon(1)
	check(loadout.selected_weapon_slot == 2 and inventory.has_item(weapons[3].id), "unequip selected slot advances to next occupied slot without removing ownership")
	inventory.remove_item(weapons[2].id)
	check(loadout.get_equipped_weapon(2) == null and loadout.selected_weapon_slot == -1, "losing ownership clears equipment and repairs selection")
	loadout.configure_slots(5)
	check(loadout.equip_weapon(4, weapons[4]) and loadout.weapon_slot_count == 5, "slot count is configurable beyond the demo default")
	loadout.configure_slots(2)
	check(loadout.selected_weapon_slot == -1 and loadout.get_equipped_weapon(4) == null and inventory.has_item(weapons[4].id), "shrinking slots keeps inventory ownership and repairs selected index")
	check(not loadout.configure_slots(0), "invalid slot count is rejected")
	loadout.equip_weapon(0, weapons[1])
	inventory.clear()
	check(loadout.get_selected_weapon() == null and inventory.get_selected_seed() == null, "clearing inventory reconciles both selectors")
	print("INPUT_SELECTION_DATA_RESULT failures=", failures)
	loadout.queue_free()
	inventory.queue_free()
	await process_frame
	quit(failures)
