class_name ConsumableUse
extends Node
## Uses the existing bag and Health component; effects belong to ItemData.

signal feedback(message: String)
signal used(item: ItemData, restored_hp: float)
signal state_changed

const USE_COOLDOWN := 0.5
var game: Node3D
var quick_use_item: ItemData
var cooldown_remaining := 0.0
var _using := false

func bind(root_game: Node3D, item: ItemData) -> void:
	game = root_game
	quick_use_item = item
	set_physics_process(false)

func can_use_input() -> bool:
	return game != null and game.preparation_complete and not get_tree().paused and not game.player.health.is_dead and not game.rest.is_resting and not game.presentation.ending_started and game.waves.state not in [NightWaveManager.State.GAME_OVER, NightWaveManager.State.GAME_COMPLETED] and not game.inventory_ui.is_open and not game.crafting_ui.is_open and not game.pause_menu.is_open and game.player.camera_rig.can_control()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_medicine") and not event.is_echo() and can_use_input():
		use_item(quick_use_item)
		get_viewport().set_input_as_handled()

func use_item(item: ItemData) -> bool:
	if not can_use_input() or _using or cooldown_remaining > 0: return false
	if item == null or item.item_type != ItemData.ItemType.CONSUMABLE or item.heal_amount <= 0 or not item.validation_errors().is_empty(): return false
	var bag: Inventory = game.inventory
	if not bag.has_item(item.id):
		feedback.emit("No Medicine")
		return false
	# A caller cannot substitute a different resource with the same inventory ID.
	if bag.get_item_definition(item.id) != item: return false
	var health: HealthComponent = game.player.health
	if health.current_hp >= health.max_hp:
		feedback.emit("HP Full")
		return false
	# remove_item emits synchronously: lock before it to prevent reentrant use.
	_using = true
	cooldown_remaining = USE_COOLDOWN
	if item.consume_on_use and not bag.remove_item(item.id, 1):
		cooldown_remaining = 0.0
		_using = false
		return false
	var before := health.current_hp
	health.heal(item.heal_amount)
	set_physics_process(true)
	used.emit(item, health.current_hp - before)
	state_changed.emit()
	_using = false
	return true

func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	if cooldown_remaining <= 0:
		set_physics_process(false)
		state_changed.emit()
