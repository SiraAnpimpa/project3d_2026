extends "res://tests/phase_9_presentation_test.gd"
## Render real catalog art at 24/48/64 px and verify unique item presentations.

func run() -> void:
	if not capture_directory.is_empty(): DirAccess.make_dir_recursive_absolute(capture_directory)
	root.size = Vector2i(1280, 720)
	await load_menu()
	await start_play()
	var hashes: Dictionary = {}
	for item: ItemData in game.catalog.items:
		var texture := UiIcons.item_icon(item)
		check(texture != null and texture.get_width() >= 64, "catalog icon loads: " + String(item.id))
		if texture == null: continue
		var digest := hash(texture.get_image().get_data())
		check(not hashes.has(digest), "distinct item artwork: " + String(item.id))
		hashes[digest] = item.id
	check(hashes.size() == 24, "all 24 catalog items have distinct illustrations")
	game.inventory.clear()
	for item: ItemData in game.catalog.items:
		game.inventory.add_item(item, 1 if item.item_type == ItemData.ItemType.WEAPON else mini(99, item.max_stack))
	game.equipment.equip_weapon(0, game.catalog.get_item(&"basic_rifle"))
	game.equipment.equip_weapon(1, game.catalog.get_item(&"wooden_bat"))
	key(KEY_TAB)
	await frames(15)
	check(game.inventory_ui.capacity_label.text == "24 / 24", "full catalog fits existing bag capacity")
	check(game.inventory_ui.slot_buttons[0].selection_mark.texture != null, "selection indicator loads as portable SVG art")
	var ids: Dictionary = {}
	for slot: InventorySlot in game.inventory.get_slots(): ids[slot.item.id] = true
	check(ids.size() == game.catalog.items.size(), "full bag contains all 24 item IDs, with one stack each")
	await capture("catalog_all_items_bag")
	# Walk every real item through the existing selection/inspection input route.
	for index in game.inventory.get_slots().size():
		await click_scaled(game.inventory_ui.slot_buttons[index])
		await frames(2)
		check(game.inventory_ui.inspected_item == game.inventory.get_slots()[index].item, "item inspection input: " + String(game.inventory_ui.inspected_item.id))
	await capture("catalog_weapon_details")
	key(KEY_ESCAPE)
	key(KEY_Q)
	await frames(5)
	check(game.hud.ammo_label.modulate == PresentationStyle.RED and game.hud._slot_label.text == "R  Reload", "empty rifle shows actionable reload state")
	await capture("catalog_empty_rifle_hud")
	game.player.camera_rig.set_menu_open(true)
	var layer := CanvasLayer.new()
	layer.layer = 100
	game.add_child(layer)
	var page := PresentationStyle.screen(layer)
	var backdrop := ColorRect.new()
	backdrop.color = PresentationStyle.INK
	page.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	page.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 20)
	var rows := PresentationStyle.box(margin, true, 14)
	PresentationStyle.label(rows, "SOMCHAI’S FIELD KIT / ALL 24 ITEM ICONS", 25)
	PresentationStyle.label(rows, "Original SVG art · 64 / 48 / 24 px · dark and light contrast", 16).modulate = PresentationStyle.MUTED
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	rows.add_child(grid)
	for item: ItemData in game.catalog.items:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(199, 143)
		card.add_theme_stylebox_override("panel", PresentationStyle.flat(Color("22362a"), Color("516348"), 1))
		grid.add_child(card)
		var content := PresentationStyle.box(card, true, 8)
		var name_label := PresentationStyle.label(content, item.display_name, 13)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var samples := PresentationStyle.box(content, false, 8)
		samples.alignment = BoxContainer.ALIGNMENT_CENTER
		var texture := UiIcons.item_icon(item)
		PresentationStyle.icon(samples, texture, 64)
		PresentationStyle.icon(samples, texture, 48)
		var light := PanelContainer.new()
		light.add_theme_stylebox_override("panel", PresentationStyle.flat(PresentationStyle.PAPER))
		light.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		samples.add_child(light)
		PresentationStyle.icon(light, texture, 24)
	await frames(15)
	await capture("catalog_icon_sheet")
	print("UI_CATALOG_RESULT failures=", failures)
	quit(1 if failures else 0)
