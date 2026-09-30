class_name PauseMenu
extends CanvasLayer

signal opened_changed(is_open: bool)

var is_open := false
var guide: Label
var help_button: Button
var _inventory_ui: InventoryUI
var _health: HealthComponent
var _crafting_ui: CraftingUI
var _previous_pause := false


func _ready() -> void:
	$Screen.hide()
	%Resume.pressed.connect(func() -> void: set_open(false))
	var panel: PanelContainer = $Screen/Panel
	panel.offset_top = -265
	panel.offset_bottom = 265
	panel.offset_left = -450
	panel.offset_right = 450
	var rows: VBoxContainer = $Screen/Panel/Rows
	rows.add_theme_constant_override("separation", 10)
	guide = PresentationStyle.label(rows, PresentationStyle.GUIDE, 17)
	guide.hide()
	help_button = PresentationStyle.button(rows, "HOW TO PLAY", _toggle_guide)
	PresentationStyle.button(rows, "RESTART", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn")).name = "Restart"
	PresentationStyle.button(rows, "MAIN MENU", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/MainMenu.tscn")).name = "MainMenu"
	PresentationStyle.button(rows, "QUIT", func() -> void: get_tree().quit()).name = "Quit"


func bind(inventory_ui: InventoryUI, health: HealthComponent) -> void:
	_inventory_ui = inventory_ui
	_health = health
	health.died.connect(func() -> void: set_open(false))


func bind_crafting(menu: CraftingUI) -> void:
	_crafting_ui = menu


func _input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed("pause"):
		return
	if is_open and guide.visible:
		_toggle_guide()
		get_viewport().set_input_as_handled()
		return
	# An open bag owns Esc. Do not open two paused screens with one key event.
	if _inventory_ui == null or _inventory_ui.is_open or _health.is_dead or (_crafting_ui != null and _crafting_ui.is_open):
		return
	if get_tree().paused and not is_open:
		return
	set_open(not is_open)
	get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if value == is_open:
		return
	if value and (_inventory_ui == null or _inventory_ui.is_open or _health.is_dead or (_crafting_ui != null and _crafting_ui.is_open)):
		return
	is_open = value
	$Screen.visible = value
	if value:
		_previous_pause = get_tree().paused
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		%Resume.grab_focus()
	else:
		get_tree().paused = _previous_pause
		get_viewport().gui_release_focus()
	opened_changed.emit(value)


func _exit_tree() -> void:
	if is_open:
		get_tree().paused = _previous_pause

func _toggle_guide() -> void:
	guide.visible = not guide.visible
	help_button.text = "BACK" if guide.visible else "HOW TO PLAY"
	for name in ["Resume", "Hint", "Restart", "MainMenu", "Quit"]:
		$Screen/Panel/Rows.get_node(name).visible = not guide.visible
