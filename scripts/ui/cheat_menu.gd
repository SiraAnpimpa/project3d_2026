class_name CheatMenu
extends CanvasLayer

signal opened_changed(is_open: bool)
var game: Node3D
var is_open := false
var screen: Control
var panel: PanelContainer
var tabs: TabContainer
var categories: UiCategoryTabs
var day_spin: SpinBox
var item_option: OptionButton
var amount_spin: SpinBox
var zombie_option: OptionButton
var zombie_count: SpinBox
var status: Label
var context: Label
var close_button: Button
var buttons: Dictionary = {}
var _previous_pause := false
var _shown_day := 0
var _items: Array[ItemData] = []

func bind(root_game: Node3D) -> void:
	game = root_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 32
	screen = PresentationStyle.screen(self)
	panel = PresentationStyle.center_panel(screen, Vector2(900, 620))
	var rows := PresentationStyle.box(panel, true, 10)
	PresentationStyle.heading(rows, "Cheat commands")
	context = PresentationStyle.label(rows, "", 16)
	context.modulate = PresentationStyle.MUTED
	rows.add_child(HSeparator.new())
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(tabs)
	_build_game_tab()
	_build_item_tab()
	_build_zombie_tab()
	categories = UiCategoryTabs.new()
	rows.add_child(categories)
	rows.move_child(categories, tabs.get_index())
	categories.bind(tabs, ["time", "items", "zombies"])
	status = PresentationStyle.label(rows, "", 16)
	status.custom_minimum_size.y = 44
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.modulate = PresentationStyle.SAGE
	close_button = PresentationStyle.button(rows, "Back  ·  Esc", _close_from_button, "close")
	close_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	game.cheats.feedback.connect(func(message: String) -> void: status.text = message; _refresh())
	game.inventory.inventory_changed.connect(_refresh)
	game.player.health.died.connect(func() -> void: set_open(false))
	screen.hide()

func _tab(title: String) -> VBoxContainer:
	var rows := VBoxContainer.new()
	rows.name = title
	rows.add_theme_constant_override("separation", 12)
	tabs.add_child(rows)
	return rows

func _command(parent: Node, title: String, action: StringName) -> Button:
	var button := PresentationStyle.button(parent, title, func() -> void: game.cheats.execute(action))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons[action] = button
	return button

func _build_game_tab() -> void:
	var rows := _tab("Time & unlocks")
	var day_row := PresentationStyle.box(rows, false, 12)
	PresentationStyle.label(day_row, "Jump to day", 18).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	day_spin = _number(day_row, 1, 10)
	buttons[&"day"] = PresentationStyle.button(day_row, "Go to morning", func() -> void: game.cheats.execute(&"day", roundi(day_spin.value)))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	rows.add_child(grid)
	_command(grid, "Next day  ·  06:00", &"next_day")
	_command(grid, "Start tonight  ·  18:00", &"night")
	_command(grid, "Final day  ·  Day 10", &"final_day")
	_command(grid, "Start the final night", &"final_night")
	_command(grid, "Unlock all seeds & recipes", &"unlock_all")
	_command(grid, "Restore HP & stamina", &"heal")
	var ending := _command(rows, "Show ending  ·  Rescue arrives", &"ending")
	ending.theme_type_variation = "PrimaryButton"
	PresentationStyle.label(rows, "Ends the current run.", 14).modulate = PresentationStyle.MUTED

func _build_item_tab() -> void:
	var rows := _tab("Items")
	PresentationStyle.label(rows, "Choose an item and quantity", 20)
	var selection := PresentationStyle.box(rows, false, 12)
	item_option = OptionButton.new()
	item_option.custom_minimum_size = Vector2(460, 44)
	item_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_option.add_theme_constant_override("icon_max_width", 28)
	for item: ItemData in game.catalog.items:
		if item == null: continue
		_items.append(item)
		item_option.add_icon_item(item.icon, item.display_name)
	selection.add_child(item_option)
	amount_spin = _number(selection, 1, 999)
	buttons[&"give_item"] = PresentationStyle.button(rows, "Give selected item", func() -> void: game.cheats.give_item(_items[item_option.selected], roundi(amount_spin.value)))
	item_option.item_selected.connect(_select_item)
	_select_item(0)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	rows.add_child(grid)
	_command(grid, "All weapons", &"weapons")
	_command(grid, "Give materials  ·  ×25 each", &"materials")
	_command(grid, "Seeds  ·  ×10", &"seeds")
	_command(grid, "Give ammunition  ·  ×100 each", &"ammo")

func _build_zombie_tab() -> void:
	var rows := _tab("Zombies")
	PresentationStyle.label(rows, "Spawn zombies near the player", 20)
	var selection := PresentationStyle.box(rows, false, 12)
	zombie_option = OptionButton.new()
	zombie_option.custom_minimum_size = Vector2(460, 44)
	zombie_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for title in ["Normal  ·  150 HP", "Runner  ·  100 HP", "Tank  ·  400 HP"]: zombie_option.add_item(title)
	selection.add_child(zombie_option)
	zombie_count = _number(selection, 1, CheatCommands.MAX_ZOMBIES)
	buttons[&"spawn"] = PresentationStyle.button(rows, "Spawn selected zombie", func() -> void: game.cheats.spawn_zombies(zombie_option.selected, roundi(zombie_count.value)))
	_command(rows, "Clear all zombies & current wave", &"clear_zombies")

func _number(parent: Node, minimum: int, maximum: int) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = 1
	spin.value = minimum
	spin.custom_minimum_size = Vector2(100, 44)
	parent.add_child(spin)
	return spin

func _select_item(index: int) -> void:
	if index < 0 or index >= _items.size(): return
	var weapon := _items[index].item_type == ItemData.ItemType.WEAPON
	amount_spin.editable = not weapon
	if weapon: amount_spin.value = 1

func _refresh() -> void:
	if game == null or not is_open: return
	context.text = "Day %d / 10  ·  %02d:%02d  ·  Bag %d / %d" % [game.clock.current_day, game.clock.current_hour, game.clock.current_minute, game.inventory.get_slots().size(), game.inventory.capacity]
	if _shown_day != game.clock.current_day:
		_shown_day = game.clock.current_day
		day_spin.set_value_no_signal(clampi(_shown_day, 1, 10))

func _input(event: InputEvent) -> void:
	if game == null or not game.preparation_complete or game.process_mode == Node.PROCESS_MODE_DISABLED or event.is_echo(): return
	if event.is_action_pressed("toggle_cheats"):
		set_open(not is_open)
		get_viewport().set_input_as_handled()
	elif is_open and event.is_action_pressed("pause"):
		set_open(false)
		get_viewport().set_input_as_handled()

func set_open(value: bool) -> void:
	if value == is_open: return
	if value:
		if not game.cheats.available() or game.rest.is_resting or game.seed_rewards.is_open or game.skip_night.is_open: return
		# Transfer ownership from the existing modal, never stack paused screens.
		if game.pause_menu._web_capture_waiting: game.pause_menu._finish_web_capture_wait()
		game.inventory_ui.set_open(false)
		game.crafting_ui.set_open(false)
		game.pause_menu.set_open(false)
		if get_tree().paused: return
		_previous_pause = get_tree().paused
		is_open = true
		get_tree().paused = true
		screen.show()
		_refresh()
		PresentationStyle.appear(panel)
		close_button.grab_focus()
	else:
		is_open = false
		screen.hide()
		get_tree().paused = _previous_pause
		get_viewport().gui_release_focus()
	opened_changed.emit(value)

func _close_from_button() -> void:
	set_open(false)
	game.player.camera_rig.capture_mouse_from_gesture()

func _exit_tree() -> void:
	if is_open: get_tree().paused = _previous_pause
