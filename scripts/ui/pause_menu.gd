class_name PauseMenu
extends CanvasLayer

signal opened_changed(is_open: bool)

var is_open := false
var _inventory_ui: InventoryUI
var _health: HealthComponent
var _previous_pause := false


func _ready() -> void:
	$Screen.hide()
	%Resume.pressed.connect(func() -> void: set_open(false))


func bind(inventory_ui: InventoryUI, health: HealthComponent) -> void:
	_inventory_ui = inventory_ui
	_health = health
	health.died.connect(func() -> void: set_open(false))


func _input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed("pause"):
		return
	# An open bag owns Esc. Do not open two paused screens with one key event.
	if _inventory_ui == null or _inventory_ui.is_open or _health.is_dead:
		return
	if get_tree().paused and not is_open:
		return
	set_open(not is_open)
	get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if value == is_open:
		return
	if value and (_inventory_ui == null or _inventory_ui.is_open or _health.is_dead):
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
