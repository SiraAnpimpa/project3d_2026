class_name GameplayModeController
extends Node

signal mode_changed(mode: Mode)

enum Mode { FARMING, COMBAT }
var current_mode: Mode = Mode.FARMING
var _inventory: Inventory
var _equipment: EquipmentLoadout
var _camera: ThirdPersonCamera


func bind(inventory: Inventory, equipment: EquipmentLoadout, camera: ThirdPersonCamera) -> void:
	_inventory = inventory
	_equipment = equipment
	_camera = camera
	_camera.set_combat_enabled(current_mode == Mode.COMBAT)


func is_farming() -> bool:
	return current_mode == Mode.FARMING


func set_mode(mode: Mode) -> void:
	if mode == current_mode or (mode != Mode.FARMING and mode != Mode.COMBAT):
		return
	current_mode = mode
	if _camera != null:
		_camera.set_combat_enabled(mode == Mode.COMBAT)
	mode_changed.emit(mode)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or _camera == null or not _camera.can_control():
		return
	if event.is_action_pressed("switch_mode"):
		set_mode(Mode.COMBAT if is_farming() else Mode.FARMING)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cycle_item_next") or event.is_action_pressed("cycle_item_previous"):
		var direction := 1 if event.is_action_pressed("cycle_item_next") else -1
		# The only gameplay wheel listener. UI handles its own scrolling while paused.
		if is_farming():
			_inventory.cycle_seed(direction)
		else:
			_equipment.cycle_weapon(direction)
		get_viewport().set_input_as_handled()
