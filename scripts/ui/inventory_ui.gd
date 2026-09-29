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

@onready var screen: Control = $Screen
@onready var grid: GridContainer = %Slots
@onready var capacity_label: Label = %Capacity
@onready var selection_label: Label = %Selection


func _ready() -> void:
	screen.hide()
	%Close.pressed.connect(func() -> void: set_open(false))


func bind(target_inventory: Inventory, target_player: PlayerController) -> void:
	inventory = target_inventory
	player = target_player
	inventory.inventory_changed.connect(refresh)
	inventory.selection_changed.connect(refresh)
	player.health.died.connect(func() -> void: set_open(false))
	refresh()


func bind_crafting(menu: CraftingUI) -> void:
	crafting_ui = menu


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("toggle_inventory"):
		if (not get_tree().paused or is_open) and (crafting_ui == null or not crafting_ui.is_open):
			set_open(not is_open)
		get_viewport().set_input_as_handled()
	elif is_open and event.is_action_pressed("pause"):
		set_open(false)
		get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if value == is_open or (value and (player == null or player.health.is_dead)):
		return
	is_open = value
	screen.visible = value
	if value:
		_previous_pause = get_tree().paused
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		refresh()
		for button in slot_buttons:
			if not button.disabled:
				button.grab_focus()
				break
	else:
		get_tree().paused = _previous_pause
		get_viewport().gui_release_focus()
	opened_changed.emit(value)


func refresh() -> void:
	if inventory == null:
		return
	while slot_buttons.size() < inventory.capacity:
		var button := Button.new()
		button.custom_minimum_size = Vector2(142, 75)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 32)
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_color_override("font_disabled_color", Color(0.86, 0.89, 0.85))
		button.add_theme_color_override("icon_disabled_color", Color.WHITE)
		button.pressed.connect(_select_slot.bind(slot_buttons.size()))
		grid.add_child(button)
		slot_buttons.append(button)
	var slots := inventory.get_slots()
	for index in slot_buttons.size():
		var button := slot_buttons[index]
		button.visible = index < inventory.capacity
		button.icon = null
		button.tooltip_text = "Empty slot"
		button.text = "-"
		button.disabled = true
		button.modulate = Color.WHITE
		if index >= slots.size():
			continue
		var slot := slots[index]
		button.icon = slot.item.icon
		button.text = "%s\nx%d" % [slot.item.display_name, slot.quantity]
		if slot.item.item_type == ItemData.ItemType.SEED:
			button.text = "%s\nSeed x%d" % [slot.item.display_name.trim_suffix(" Seed"), slot.quantity]
		button.tooltip_text = "%s\n%s\nStack %d / %d" % [slot.item.display_name, slot.item.description, slot.quantity, slot.item.max_stack]
		if slot.item.item_type == ItemData.ItemType.SEED:
			button.tooltip_text += "\nTier %d / Order %d / %s" % [slot.item.tier, slot.item.display_order, "Plantable" if slot.item.plantable else "Not plantable"]
		button.disabled = not ((slot.item.item_type == ItemData.ItemType.SEED and slot.item.plantable) or slot.item.item_type == ItemData.ItemType.WEAPON)
		if slot.item.id == inventory.selected_seed_id:
			button.modulate = Color(0.78, 1.0, 0.56)
		if slot.item == selected_owned_weapon:
			button.modulate = Color(0.58, 0.86, 1.0)
	capacity_label.text = "%d / %d slots used" % [slots.size(), inventory.capacity]
	var seed := inventory.get_selected_seed()
	selection_label.text = "No plantable seed selected. Use Q for Farming after closing the bag."
	if seed != null:
		selection_label.text = "Selected: %s  (x%d)  |  Farming: close bag, approach a plot, press E." % [seed.display_name, inventory.get_item_amount(seed.id)]
	_refresh_equipment()


func _select_slot(index: int) -> void:
	var slots := inventory.get_slots()
	if index < 0 or index >= slots.size():
		return
	var item := slots[index].item
	if item.item_type == ItemData.ItemType.WEAPON:
		selected_owned_weapon = item
		refresh()
	else:
		inventory.select_seed(item.id)


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
	debug_message = Label.new()
	debug_message.text = "Development only. Changes apply to this run."
	debug_message.add_theme_font_size_override("font_size", 13)
	container.add_child(debug_message)
	container.visible = debug.active
	debug.status_changed.connect(func(active: bool, _summary: String) -> void: container.visible = active)
	debug.message_posted.connect(func(message: String) -> void: debug_message.text = message)


func _exit_tree() -> void:
	if is_open:
		get_tree().paused = _previous_pause


func bind_equipment(loadout: EquipmentLoadout) -> void:
	equipment = loadout
	loadout.equipment_changed.connect(_refresh_equipment)
	_refresh_equipment()


func _refresh_equipment() -> void:
	if equipment == null:
		return
	if selected_owned_weapon != null and not inventory.has_item(selected_owned_weapon.id):
		selected_owned_weapon = null
	%EquipmentHint.text = "EQUIPPED WEAPONS  /  Select an owned weapon above, then a slot."
	if selected_owned_weapon != null:
		%EquipmentHint.text = "EQUIP %s  /  Choose a slot below." % selected_owned_weapon.display_name
	while equipment_buttons.size() < equipment.weapon_slot_count:
		var index := equipment_buttons.size()
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		%EquipmentSlots.add_child(row)
		var equip := Button.new()
		equip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		equip.add_theme_font_size_override("font_size", 14)
		equip.pressed.connect(func() -> void: equipment.equip_weapon(index, selected_owned_weapon))
		row.add_child(equip)
		equipment_buttons.append(equip)
		var clear := Button.new()
		clear.text = "×"
		clear.tooltip_text = "Unequip this slot (keep the weapon in your bag)"
		clear.pressed.connect(func() -> void: equipment.unequip_weapon(index))
		row.add_child(clear)
		unequip_buttons.append(clear)
	for index in equipment_buttons.size():
		var button := equipment_buttons[index]
		button.get_parent().visible = index < equipment.weapon_slot_count
		var weapon := equipment.get_equipped_weapon(index)
		button.text = "[%d] %s" % [index + 1, weapon.display_name if weapon != null else "Empty"]
		button.disabled = selected_owned_weapon == null
		button.tooltip_text = "Equip the selected owned weapon in slot %d" % (index + 1)
		unequip_buttons[index].disabled = weapon == null
