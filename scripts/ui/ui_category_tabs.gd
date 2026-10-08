class_name UiCategoryTabs
extends PanelContainer
## Shared category navigation. TabContainer still owns page visibility and state.

const ICONS := {
	"time": preload("res://assets/ui/icons/nav_time.svg"),
	"items": preload("res://assets/ui/icons/nav_items.svg"),
	"zombies": preload("res://assets/ui/icons/nav_zombies.svg"),
	"general": preload("res://assets/ui/icons/nav_general.svg"),
	"graphics": preload("res://assets/ui/icons/nav_graphics.svg"),
}

var buttons: Array[Button] = []
var _tabs: TabContainer

func bind(content: TabContainer, icon_keys: Array[String]) -> void:
	name = "Categories"
	theme_type_variation = "CategoryRail"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs = content
	_tabs.tabs_visible = false
	# Replace the engine's dark page background; align content with the panel edges.
	var page_style := StyleBoxEmpty.new()
	page_style.content_margin_top = 4
	_tabs.add_theme_stylebox_override("panel", page_style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	add_child(row)
	var group := ButtonGroup.new()
	for index in _tabs.get_tab_count():
		var button := Button.new()
		button.name = "Category%d" % index
		button.text = _tabs.get_tab_title(index)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.icon = ICONS[icon_keys[index]]
		button.expand_icon = true
		button.theme_type_variation = "CategoryTab"
		button.custom_minimum_size.y = 44
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.button_group = group
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_choose.bind(index))
		button.gui_input.connect(_tab_input.bind(index))
		row.add_child(button)
		buttons.append(button)
	var widest := 0.0
	for button in buttons: widest = maxf(widest, button.get_combined_minimum_size().x)
	for button in buttons: button.custom_minimum_size.x = widest
	# Explicit neighbors avoid jumping into page controls when moving along the rail.
	for index in buttons.size():
		buttons[index].focus_neighbor_left = buttons[(index - 1 + buttons.size()) % buttons.size()].get_path()
		buttons[index].focus_neighbor_right = buttons[(index + 1) % buttons.size()].get_path()
	_tabs.tab_changed.connect(_sync_selection)
	_sync_selection(_tabs.current_tab)

func _choose(index: int) -> void:
	_tabs.current_tab = index

func _sync_selection(index: int) -> void:
	for i in buttons.size(): buttons[i].set_pressed_no_signal(i == index)
	if _tabs.is_visible_in_tree(): PresentationStyle.appear(_tabs.get_current_tab_control())

func _tab_input(event: InputEvent, index: int) -> void:
	if event.is_echo(): return
	var direction := 0
	if event.is_action_pressed("ui_left"): direction = -1
	elif event.is_action_pressed("ui_right"): direction = 1
	if direction == 0: return
	var next := (index + direction + buttons.size()) % buttons.size()
	buttons[next].grab_focus()
	_choose(next)
	buttons[index].accept_event()
