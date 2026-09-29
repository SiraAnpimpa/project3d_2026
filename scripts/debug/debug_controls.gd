class_name DebugControls
extends Node

signal status_changed(active: bool, summary: String)
signal message_posted(message: String)

@export var debug_enabled: bool = true
@export var damage_amount: float = 20.0
@export var stamina_amount: float = 30.0
@export var time_step_minutes: float = 60.0
@export var accelerated_time_scale: float = 20.0

var active: bool = false
var player: PlayerController
var clock: GameClock

var inventory: Inventory
var catalog: ItemCatalog
var loadout: InventoryLoadout
var farm_plots: Array[FarmPlot] = []
var zombie_spawner: ZombieTestSpawner

const FARMING_ACTIONS: Array[StringName] = [
	&"debug_give_seeds", &"debug_clear_farm", &"debug_grow_all",
	&"debug_advance_growth", &"debug_fill_inventory", &"debug_clear_inventory"
]

const ACTIONS: Array[StringName] = [
	&"debug_damage", &"debug_heal", &"debug_drain_stamina", &"debug_restore_stamina",
	&"debug_time_back", &"debug_time_forward", &"debug_day", &"debug_night",
	&"debug_speed", &"debug_pause_time", &"debug_restore_player"
]


func bind(target_player: PlayerController, game_clock: GameClock) -> void:
	player = target_player
	clock = game_clock
	active = OS.is_debug_build() and debug_enabled
	clock.time_changed.connect(_on_time_changed)
	_publish()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not debug_enabled or player == null:
		return
	if event.is_action_pressed("debug_toggle"):
		set_active(not active)
		get_viewport().set_input_as_handled()
		return
	if not active:
		return
	for action in ACTIONS:
		if event.is_action_pressed(action):
			execute(action)
			get_viewport().set_input_as_handled()
			return


func set_active(value: bool) -> void:
	active = value and debug_enabled and OS.is_debug_build()
	if not active and clock != null:
		clock.time_scale = 1.0
		clock.paused = false
	_publish()


func execute(action: StringName) -> void:
	if not active or not debug_enabled or not OS.is_debug_build():
		return
	if action in [&"debug_spawn_zombie", &"debug_spawn_three", &"debug_clear_zombies"]:
		if zombie_spawner == null: return
		if action == &"debug_clear_zombies":
			zombie_spawner.clear_zombies()
			message_posted.emit("Debug: cleared test zombies")
		else:
			var count := zombie_spawner.spawn_test_zombies(3 if action == &"debug_spawn_three" else 1)
			message_posted.emit("Debug: spawned %d zombie(s); maximum 5, occupied points skipped" % count)
		return
	if action == &"debug_give_ammo":
		if inventory != null and catalog != null:
			var added := inventory.add_item(catalog.get_item(&"basic_ammo"), 30)
			message_posted.emit("Debug: gave Basic Ammo x30" if added else "Inventory full; no ammo added")
		return
	if action in FARMING_ACTIONS:
		_execute_farming(action)
		_publish()
		return
	match action:
		&"debug_damage": player.health.take_damage(damage_amount)
		&"debug_heal": player.health.heal(damage_amount)
		&"debug_drain_stamina": player.stamina.drain(stamina_amount)
		&"debug_restore_stamina": player.stamina.restore(stamina_amount)
		&"debug_time_back": clock.advance_game_minutes(-time_step_minutes)
		&"debug_time_forward": clock.advance_game_minutes(time_step_minutes)
		&"debug_day": clock.skip_to_day()
		&"debug_night": clock.skip_to_night()
		&"debug_speed": clock.time_scale = accelerated_time_scale if clock.time_scale == 1.0 else 1.0
		&"debug_pause_time": clock.paused = not clock.paused
		&"debug_restore_player":
			player.health.reset()
			player.stamina.reset()
			player.velocity = Vector3.ZERO
		_: return
	_publish()
	message_posted.emit("Debug: " + String(action).trim_prefix("debug_").replace("_", " "))


func _publish() -> void:
	if clock == null:
		return
	var state := "PAUSED" if clock.paused else "RUNNING"
	status_changed.emit(active, "TIME x%.0f  |  %s" % [clock.time_scale, state])


func _on_time_changed(_day: int, _hour: int, _minute: int, _daytime: bool) -> void:
	_publish()


func bind_farming(target_inventory: Inventory, definitions: ItemCatalog, starter: InventoryLoadout, plots: Node) -> void:
	inventory = target_inventory
	catalog = definitions
	loadout = starter
	for child in plots.get_children():
		if child is FarmPlot:
			farm_plots.append(child)


func _execute_farming(action: StringName) -> void:
	if inventory == null or catalog == null or loadout == null:
		return
	var message := "Debug: " + String(action).trim_prefix("debug_").replace("_", " ")
	match action:
		&"debug_give_seeds":
			if not loadout.give_to(inventory):
				message = "Not enough bag space for the starter seeds. Nothing added."
		&"debug_clear_farm":
			for plot in farm_plots:
				plot.clear_plot()
		&"debug_grow_all":
			var remaining := 0.0
			var growing := false
			for plot in farm_plots:
				if plot.state == FarmPlot.State.PLANTED:
					growing = true
					remaining = maxf(remaining, plot.remaining_growth_minutes())
			if growing:
				# Move through a minute boundary so every plot receives the clock event.
				clock.advance_game_minutes(ceilf(remaining) + 1.0)
		&"debug_advance_growth": clock.advance_game_minutes(time_step_minutes)
		&"debug_fill_inventory":
			for slot in inventory.get_slots():
				var missing := slot.item.max_stack - slot.quantity
				if missing > 0:
					inventory.add_item(slot.item, missing)
			var filler: ItemData = null
			for item in catalog.items:
				if item.item_type == ItemData.ItemType.MATERIAL:
					filler = item
					break
			if filler != null:
				while inventory.can_add_item(filler, filler.max_stack):
					inventory.add_item(filler, filler.max_stack)
		&"debug_clear_inventory": inventory.clear()
	message_posted.emit(message)
