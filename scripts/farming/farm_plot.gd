class_name FarmPlot
extends Interactable

enum State { EMPTY, PLANTED, READY }

const PLANT_SCENE = preload("res://scenes/farming/Plant.tscn")

var state: State = State.EMPTY
var plant_data: PlantData
var planted_time: float = 0.0
var growth_progress: float = 0.0
var growth_stage: int = -1
var plant_visual: PlantVisual
var _clock: GameClock
var _catalog: ItemCatalog
var _inventory: Inventory
var _busy := false

@onready var status_label: Label3D = $Status


func bind(clock: GameClock, catalog: ItemCatalog, inventory: Inventory) -> void:
	_clock = clock
	_catalog = catalog
	_inventory = inventory
	_clock.time_changed.connect(_on_time_changed)
	_inventory.selection_changed.connect(_publish_status)
	_inventory.inventory_changed.connect(_publish_status)
	_publish_status()


func is_available(actor: Node3D) -> bool:
	return super.is_available(actor) and _clock != null and _catalog != null and _is_farming(actor)


func get_interaction_text(actor: Node3D, key_hint: String) -> String:
	if not _is_farming(actor):
		return "Press Q for Farming mode"
	if state == State.EMPTY:
		var seed := _inventory.get_selected_seed() if _inventory != null else null
		if seed == null:
			return "Empty plot | Open [Tab] to select a seed"
		if not _inventory.has_item(seed.id):
			return "%s: none left | Open [Tab]" % seed.display_name
		return "[%s] Plant %s (x%d)" % [key_hint, seed.display_name, _inventory.get_item_amount(seed.id)]
	if state == State.READY:
		return "[%s] Harvest %s x%d" % [key_hint, plant_data.harvest_item.display_name, plant_data.harvest_amount]
	return "%s | %s %d%%" % [plant_data.display_name, plant_data.growth_stages[growth_stage], floori(growth_progress * 100)]


func interact(actor: Node3D) -> String:
	if not enabled or _busy or _clock == null or _catalog == null:
		return "Plot unavailable."
	if not _is_farming(actor):
		return "Switch to Farming mode to use this plot."
	var inventory := actor.get_node_or_null("Inventory") as Inventory
	var health := actor.get_node_or_null("Health") as HealthComponent
	if inventory == null or (health != null and health.is_dead):
		return "Cannot use this plot."
	if state == State.READY:
		return _harvest(inventory)
	if state == State.PLANTED:
		return get_interaction_text(actor, "E")
	return _plant(inventory)


func _plant(inventory: Inventory) -> String:
	var seed := inventory.get_selected_seed()
	if seed == null or seed.item_type != ItemData.ItemType.SEED or not seed.plantable:
		return "No seed selected. Press Tab to choose a seed."
	if not inventory.has_item(seed.id):
		return "No %s left." % seed.display_name
	var definition := _catalog.get_plant(seed.plant_id)
	if definition == null or definition.seed_item != seed or not definition.validation_errors().is_empty():
		return "This seed has invalid plant data; nothing was consumed."
	_busy = true
	var visual := PLANT_SCENE.instantiate() as PlantVisual
	if visual == null:
		_busy = false
		return "Plant visual unavailable; nothing was consumed."
	if not inventory.remove_item(seed.id, 1):
		visual.free()
		_busy = false
		return "Seed unavailable; nothing was planted."
	plant_data = definition
	planted_time = _clock.get_elapsed_minutes()
	growth_progress = 0.0
	growth_stage = 0
	state = State.PLANTED
	plant_visual = visual
	$PlantAnchor.add_child(visual)
	visual.configure(definition)
	_busy = false
	_publish_status()
	return "Planted %s." % definition.display_name


func _harvest(inventory: Inventory) -> String:
	_busy = true
	# add_item is atomic. Keep the ready crop untouched if all produce cannot fit.
	if not inventory.add_item(plant_data.harvest_item, plant_data.harvest_amount):
		_busy = false
		return "Inventory full. Make room for %s x%d." % [plant_data.harvest_item.display_name, plant_data.harvest_amount]
	var message := "Harvested %s x%d." % [plant_data.harvest_item.display_name, plant_data.harvest_amount]
	clear_plot()
	_busy = false
	return message


func clear_plot() -> void:
	if is_instance_valid(plant_visual):
		plant_visual.get_parent().remove_child(plant_visual)
		plant_visual.queue_free()
	plant_visual = null
	plant_data = null
	state = State.EMPTY
	planted_time = 0.0
	growth_progress = 0.0
	growth_stage = -1
	_publish_status()


func remaining_growth_minutes() -> float:
	if state != State.PLANTED:
		return 0.0
	return maxf(0.0, planted_time + plant_data.growth_minutes - _clock.get_elapsed_minutes())


func _on_time_changed(_day: int, _hour: int, _minute: int, _daytime: bool) -> void:
	if state != State.PLANTED:
		return
	# Growth never reverses when the debug clock rewinds. It resumes after catch-up.
	growth_progress = maxf(growth_progress, clampf((_clock.get_elapsed_minutes() - planted_time) / plant_data.growth_minutes, 0.0, 1.0))
	if growth_progress >= 0.999999:
		growth_progress = 1.0
		state = State.READY
	growth_stage = plant_data.stage_at(growth_progress)
	plant_visual.set_stage(growth_stage)
	_publish_status()


func _publish_status() -> void:
	if not is_node_ready():
		return
	if state == State.EMPTY:
		status_label.text = "EMPTY"
		status_label.modulate = Color(0.85, 0.81, 0.68)
	else:
		status_label.text = "%s\n%s %d%%" % [plant_data.display_name, plant_data.growth_stages[growth_stage], floori(growth_progress * 100)]
		status_label.modulate = Color(0.76, 1.0, 0.48) if state == State.READY else Color(0.95, 0.94, 0.85)
	prompt_changed.emit()


func _is_farming(actor: Node3D) -> bool:
	if actor == null:
		return false
	var mode := actor.get_node_or_null("GameplayMode") as GameplayModeController
	return mode == null or mode.is_farming()
