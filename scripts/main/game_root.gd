extends Node3D

@export var catalog: ItemCatalog
@export var starter_loadout: InventoryLoadout
@onready var inventory: Inventory = $Player/Inventory
@onready var inventory_ui: InventoryUI = $InventoryUI
@onready var equipment: EquipmentLoadout = $Player/EquipmentLoadout
@onready var gameplay_mode: GameplayModeController = $Player/GameplayMode
@onready var pause_menu: PauseMenu = $PauseMenu

@onready var player: PlayerController = $Player
@onready var clock: GameClock = $TimeController
@onready var lighting: DayNightEnvironment = $DayNightEnvironment
@onready var hud: PrototypeHUD = $HUD
@onready var debug_controls: DebugControls = $DebugControls


func _ready() -> void:
	player.global_transform = $MainWorld/PlayerSpawn.global_transform
	if starter_loadout == null or not starter_loadout.give_to(inventory):
		push_error("Starter loadout is invalid or inventory is too small.")
	equipment.bind(inventory)
	gameplay_mode.bind(inventory, equipment, player.camera_rig)
	gameplay_mode.mode_changed.connect(func(_mode: GameplayModeController.Mode) -> void: player.interactor.refresh_target())
	inventory_ui.bind(inventory, player)
	inventory_ui.bind_equipment(equipment)
	pause_menu.bind(inventory_ui, player.health)
	pause_menu.opened_changed.connect(player.camera_rig.set_menu_open)
	inventory_ui.opened_changed.connect(player.camera_rig.set_menu_open)
	player.health.changed.connect(func(hp: float, _maximum: float) -> void: player.camera_rig.set_player_alive(hp > 0))
	lighting.bind_clock(clock)
	hud.bind(player, clock, debug_controls)
	debug_controls.bind(player, clock)
	hud.bind_inventory(inventory)
	hud.bind_gameplay_mode(gameplay_mode, equipment)
	player.aim_ray.bind(player.camera_rig, player, debug_controls)
	hud.get_node("Root/Crosshair").bind(player, player.aim_ray, hud.get_node("Root/AimDebugLabel"))
	var errors := catalog.validation_errors() if catalog != null else PackedStringArray(["Item catalog is missing."])
	if errors.is_empty():
		for plot in $MainWorld/FarmArea.get_children():
			if plot is FarmPlot:
				plot.bind(clock, catalog, inventory)
		debug_controls.bind_farming(inventory, catalog, starter_loadout, $MainWorld/FarmArea)
	else:
		for message in errors:
			push_error("Farming data: " + message)
		hud.show_message("Farming data is invalid. See the Godot debugger for details.")
	inventory_ui.bind_debug(debug_controls)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and player.health.is_dead:
		get_tree().reload_current_scene()
