class_name InventoryUI
extends CanvasLayer

signal opened_changed(is_open: bool)

var inventory: Inventory
var player: PlayerController
var slot_buttons: Array[Button] = []
var is_open := false
var _previous_pause := false
var debug_message: Label
var equipment: EquipmentLoadout
var selected_owned_weapon: ItemData
var equipment_buttons: Array[Button] = []
var unequip_buttons: Array[Button] = []
var crafting_ui: CraftingUI
var screen: Control
var grid: GridContainer
var capacity_label: Label
var selection_label: Label
var inspected_item: ItemData
var _detail_icon: TextureRect
var _detail_info: VBoxContainer
var _owned_weapons: GridContainer
var _catalog: ItemCatalog
var _panel: PanelContainer

func _ready() -> void:
	screen = PresentationStyle.screen(self)
	_panel = PresentationStyle.center_panel(screen, Vector2(1008, 672))
	var modal_style := _panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	modal_style.set_content_margin_all(20)
	_panel.add_theme_stylebox_override("panel", modal_style)
	var rows := PresentationStyle.box(_panel, true, 8)
	var header := PresentationStyle.box(rows, false, 12)
	PresentationStyle.icon(header, UiIcons.get_icon("bag"), 26).modulate = PresentationStyle.GOLD
	PresentationStyle.heading(header, "Field inventory", "FIELD KIT / SEEDS, SUPPLIES & EQUIPMENT")
	capacity_label = PresentationStyle.label(header, "", 17)
	capacity_label.modulate = PresentationStyle.MUTED
	var close := PresentationStyle.button(header, "Esc", func() -> void: set_open(false), "close")
	close.theme_type_variation = "QuietButton"
	close.tooltip_text = "Close bag · Tab / Esc"
	rows.add_child(HSeparator.new())
	var content := PresentationStyle.box(rows, false, 16)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var supply_panel := PanelContainer.new()
	content.add_child(supply_panel)
	supply_panel.add_theme_stylebox_override("panel", _section_style())
	var left := PresentationStyle.box(supply_panel, true, 8)
	left.custom_minimum_size.x = 532
	PresentationStyle.label(left, "SEEDS & SUPPLIES", 14).modulate = PresentationStyle.MUTED
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(532, 336)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(scroll)
	grid = GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)
	var detail_panel := PanelContainer.new()
	content.add_child(detail_panel)
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.add_theme_stylebox_override("panel", _section_style())
	var detail := PresentationStyle.box(detail_panel, true, 10)
	detail.custom_minimum_size.x = 304
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var detail_header := PresentationStyle.box(detail, false, 14)
	_detail_icon = PresentationStyle.icon(detail_header, null, 76)
	selection_label = PresentationStyle.label(detail_header, "", 24)
	selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_info = PresentationStyle.box(detail, true, 10) as VBoxContainer
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_child(spacer)
	PresentationStyle.label(detail, "OWNED WEAPONS", 14).modulate = PresentationStyle.MUTED
	var weapon_scroll := ScrollContainer.new()
	weapon_scroll.custom_minimum_size.y = 80
	weapon_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	weapon_scroll.follow_focus = true
	detail.add_child(weapon_scroll)
	_owned_weapons = GridContainer.new()
	_owned_weapons.columns = 3
	_owned_weapons.add_theme_constant_override("h_separation",8)
	_owned_weapons.add_theme_constant_override("v_separation",8)
	weapon_scroll.add_child(_owned_weapons)
	rows.add_child(HSeparator.new())
	var equipment_hint := PresentationStyle.label(rows, "LOADOUT", 14)
	equipment_hint.modulate = PresentationStyle.MUTED
	_named(equipment_hint, "EquipmentHint")
	var equipment_slots := GridContainer.new()
	equipment_slots.columns = 3
	equipment_slots.add_theme_constant_override("h_separation", 14)
	rows.add_child(equipment_slots)
	_named(equipment_slots, "EquipmentSlots")
	var debug_scroll := ScrollContainer.new()
	debug_scroll.custom_minimum_size.y = 0
	rows.add_child(debug_scroll)
	var debug_rows := VBoxContainer.new()
	debug_scroll.add_child(debug_rows)
	_named(debug_rows, "DebugActions")
	debug_rows.visibility_changed.connect(func() -> void: debug_scroll.custom_minimum_size.y = 100 if debug_rows.visible else 0)
	screen.hide()

func _named(node: Node, title: String) -> void:
	node.name = title
	node.owner = self
	node.unique_name_in_owner = true

func bind(target_inventory: Inventory, target_player: PlayerController) -> void:
	inventory = target_inventory
	player = target_player
	_catalog = player.get_parent().get("catalog") as ItemCatalog
	inventory.inventory_changed.connect(refresh)
	inventory.selection_changed.connect(refresh)
	player.health.died.connect(func() -> void: set_open(false))
	refresh()

func bind_crafting(menu: CraftingUI) -> void:
	crafting_ui = menu

func _input(event: InputEvent) -> void:
	if event.is_echo(): return
	if event.is_action_pressed("toggle_inventory"):
		if (not get_tree().paused or is_open) and (crafting_ui == null or not crafting_ui.is_open):
			set_open(not is_open)
		get_viewport().set_input_as_handled()
	elif is_open and event.is_action_pressed("pause"):
		set_open(false)
		get_viewport().set_input_as_handled()

func set_open(value: bool) -> void:
	if value == is_open or (value and (player == null or player.health.is_dead)): return
	is_open = value
	screen.visible = value
	if value:
		_previous_pause = get_tree().paused
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		inspected_item = inventory.get_selected_seed()
		selected_owned_weapon = null
		refresh()
		PresentationStyle.appear(_panel)
		for button in slot_buttons:
			if not button.disabled:
				button.grab_focus()
				break
	else:
		get_tree().paused = _previous_pause
		get_viewport().gui_release_focus()
	opened_changed.emit(value)

func refresh() -> void:
	if inventory == null: return
	while slot_buttons.size() < inventory.capacity:
		var cell := UiItemSlot.new()
		cell.pressed.connect(_select_slot.bind(slot_buttons.size()))
		grid.add_child(cell)
		slot_buttons.append(cell)
	var slots := inventory.get_slots()
	if inspected_item != null and not inventory.has_item(inspected_item.id): inspected_item = null
	if inspected_item == null: inspected_item = inventory.get_selected_seed()
	for index in slot_buttons.size():
		var cell := slot_buttons[index] as UiItemSlot
		cell.visible = index < inventory.capacity
		var item: ItemData = slots[index].item if index < slots.size() else null
		var destination: Node = _owned_weapons if item != null and item.item_type == ItemData.ItemType.WEAPON else grid
		if cell.get_parent() != destination: cell.reparent(destination)
		destination.move_child(cell, -1)
		var plant: PlantData = _catalog.get_plant(item.plant_id) if item != null and item.item_type == ItemData.ItemType.SEED and _catalog != null else null
		cell.display(item, slots[index].quantity if item != null else 0, item != null and item == inspected_item, plant)
	capacity_label.text = "%d / %d" % [slots.size(), inventory.capacity]
	capacity_label.tooltip_text = "Occupied bag slots"
	_refresh_detail()
	_refresh_equipment()

func _refresh_detail() -> void:
	for node in _detail_info.get_children():
		_detail_info.remove_child(node)
		node.queue_free()
	_detail_icon.texture = UiIcons.item_icon(inspected_item)
	selection_label.text = inspected_item.display_name if inspected_item != null else "Empty bag"
	if inspected_item == null:
		PresentationStyle.label(_detail_info, "Harvest materials to fill your bag.", 17)
		return
	var count := inventory.get_item_amount(inspected_item.id)
	PresentationStyle.eyebrow(_detail_info, UiIcons.category(inspected_item))
	PresentationStyle.label(_detail_info, "×%d in bag" % count, 18).modulate = PresentationStyle.MUTED
	_detail_info.add_child(HSeparator.new())
	if inspected_item.item_type == ItemData.ItemType.SEED and _catalog != null:
		var plant := _catalog.get_plant(inspected_item.plant_id)
		if plant == null: return
		var growth := PresentationStyle.box(_detail_info, false, 10)
		PresentationStyle.icon(growth, UiIcons.get_icon("clock"), 22)
		PresentationStyle.label(growth, "%.0f game min" % plant.growth_minutes, 17).tooltip_text = "Growth time in game minutes"
		var harvest := PresentationStyle.box(_detail_info, false, 10)
		PresentationStyle.icon(harvest, UiIcons.item_icon(plant.harvest_item), 30)
		PresentationStyle.label(harvest, "%s  ×%d" % [plant.harvest_item.display_name, plant.harvest_amount], 18)
		PresentationStyle.label(_detail_info, "Plant on an empty plot.", 16).modulate = PresentationStyle.MUTED
		PresentationStyle.label(_detail_info, "Selected for planting", 16).modulate = PresentationStyle.SAGE
	else:
		var copy := PresentationStyle.label(_detail_info, UiIcons.use_text(inspected_item), 17)
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _select_slot(index: int) -> void:
	var slots := inventory.get_slots()
	if index < 0 or index >= slots.size(): return
	var item: ItemData = slots[index].item
	inspected_item = item
	selected_owned_weapon = item if item.item_type == ItemData.ItemType.WEAPON else null
	if item.item_type == ItemData.ItemType.SEED and item.plantable:
		inventory.select_seed(item.id)
	refresh()

func bind_equipment(loadout: EquipmentLoadout) -> void:
	equipment = loadout
	loadout.equipment_changed.connect(_refresh_equipment)
	_refresh_equipment()

func _refresh_equipment() -> void:
	if equipment == null: return
	if selected_owned_weapon != null and not inventory.has_item(selected_owned_weapon.id): selected_owned_weapon = null
	%EquipmentHint.text = "LOADOUT  ·  Choose a weapon, then a slot"
	if selected_owned_weapon != null:
		%EquipmentHint.text = "%s  →  Choose a slot" % selected_owned_weapon.display_name
	while equipment_buttons.size() < equipment.weapon_slot_count:
		var index := equipment_buttons.size()
		var row := PresentationStyle.box(%EquipmentSlots, false, 4)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var equip := PresentationStyle.button(row, "", func() -> void: equipment.equip_weapon(index, selected_owned_weapon))
		equip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		equip.custom_minimum_size = Vector2(242, 44)
		equip.expand_icon = true
		equip.add_theme_constant_override("icon_max_width", 40)
		equipment_buttons.append(equip)
		var clear := PresentationStyle.button(row, "", func() -> void: equipment.unequip_weapon(index), "close")
		clear.custom_minimum_size.x = 40
		clear.theme_type_variation = "QuietButton"
		clear.tooltip_text = "Unequip · keep weapon in bag"
		unequip_buttons.append(clear)
	for index in equipment_buttons.size():
		var button := equipment_buttons[index]
		button.get_parent().visible = index < equipment.weapon_slot_count
		var weapon := equipment.get_equipped_weapon(index)
		button.icon = UiIcons.item_icon(weapon)
		button.text = "Slot %d" % (index + 1) if weapon != null else "Slot %d · Empty" % (index + 1)
		button.disabled = selected_owned_weapon == null
		button.tooltip_text = "%s · Select an owned weapon, then this slot" % (weapon.display_name if weapon != null else "Empty")
		unequip_buttons[index].disabled = weapon == null

func _exit_tree() -> void:
	if is_open: get_tree().paused = _previous_pause


func bind_debug(debug: DebugControls) -> void:
	var container: VBoxContainer = %DebugActions
	var heading := HBoxContainer.new()
	container.add_child(heading)
	var label := Label.new()
	label.text = "DEBUG TOOLS  |  Clock buttons advance time even while this bag is open."
	label.add_theme_font_size_override("font_size", 13)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(label)
	var disable := Button.new()
	disable.text = "Disable tools"
	disable.add_theme_font_size_override("font_size", 13)
	disable.pressed.connect(func() -> void: debug.set_active(false))
	heading.add_child(disable)
	var row := HBoxContainer.new()
	container.add_child(row)
	var labels := ["Give seeds", "Clear farm", "Grow all (+time)", "+1 game hour", "Fill bag", "Clear bag"]
	for index in DebugControls.FARMING_ACTIONS.size():
		var button := Button.new()
		button.name = String(DebugControls.FARMING_ACTIONS[index])
		button.text = labels[index]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 14)
		button.pressed.connect(debug.execute.bind(DebugControls.FARMING_ACTIONS[index]))
		row.add_child(button)
	var ammo_button := Button.new()
	ammo_button.text = "DEBUG: Give Basic Ammo x30"
	ammo_button.pressed.connect(debug.execute.bind(&"debug_give_ammo"))
	container.add_child(ammo_button)
	var enemy_row := HBoxContainer.new()
	container.add_child(enemy_row)
	var enemy_actions := [&"debug_spawn_zombie", &"debug_spawn_three", &"debug_clear_zombies"]
	var enemy_labels := ["Spawn zombie", "Spawn 3 zombies", "Clear zombies"]
	for index in enemy_actions.size():
		var button := Button.new()
		button.name = String(enemy_actions[index])
		button.text = enemy_labels[index]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(debug.execute.bind(enemy_actions[index]))
		enemy_row.add_child(button)
	var wave_row := HBoxContainer.new()
	container.add_child(wave_row)
	var wave_actions := [&"debug_before_night", &"debug_start_night", &"debug_kill_wave", &"debug_before_dawn", &"debug_force_dawn"]
	var wave_labels := ["17:50", "Start night", "Kill active wave", "05:50", "Dawn"]
	for index in wave_actions.size():
		var button := Button.new()
		button.name = String(wave_actions[index])
		button.text = wave_labels[index]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(debug.execute.bind(wave_actions[index]))
		wave_row.add_child(button)
	var progression_tools := MenuButton.new()
	progression_tools.text = "Progression: day jump / unlock tools"
	var popup := progression_tools.get_popup()
	var actions := [&"debug_set_day_1", &"debug_set_day_3", &"debug_set_day_5", &"debug_set_day_7", &"debug_set_day_10", &"debug_unlock_all", &"debug_reset_unlocks"]
	for title in ["Day 1", "Day 3", "Day 5", "Day 7", "Day 10", "Unlock all seeds / recipes", "Reset unlocks to current day"]: popup.add_item(title)
	popup.id_pressed.connect(func(id: int) -> void: debug.execute(actions[id]))
	wave_row.add_child(progression_tools)
	debug_message = Label.new()
	debug_message.text = "Development only. Changes apply to this run."
	debug_message.add_theme_font_size_override("font_size", 13)
	container.add_child(debug_message)
	container.visible = debug.active and OS.is_debug_build()
	debug.status_changed.connect(func(active: bool, _summary: String) -> void: container.visible = active and OS.is_debug_build())
	debug.message_posted.connect(func(message: String) -> void: debug_message.text = message)

func _section_style() -> StyleBoxFlat:
	var style := PresentationStyle.flat(Color("17281f"), Color("384c3b"), 1)
	style.set_content_margin_all(12)
	return style
