extends Node3D

@export var catalog: ItemCatalog
@export var starter_loadout: InventoryLoadout
@export var recipe_book: RecipeBook
@export var starter_weapon: ItemData
@onready var inventory: Inventory = $Player/Inventory
@onready var inventory_ui: InventoryUI = $InventoryUI
@onready var equipment: EquipmentLoadout = $Player/EquipmentLoadout
@onready var gameplay_mode: GameplayModeController = $Player/GameplayMode
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var crafting_system: CraftingSystem = $CraftingSystem
@onready var crafting_ui: CraftingUI = $CraftingUI
@onready var weapons: WeaponController = $Player/WeaponController

@onready var player: PlayerController = $Player
@onready var clock: GameClock = $TimeController
@onready var lighting: DayNightEnvironment = $DayNightEnvironment
@onready var hud: PrototypeHUD = $HUD
@onready var debug_controls: DebugControls = $DebugControls


func _ready() -> void:
	player.global_transform = $MainWorld/PlayerSpawn.global_transform
	if starter_loadout == null or not starter_loadout.give_to(inventory):
		push_error("Starter loadout is invalid or inventory is too small.")
	if starter_weapon != null and not inventory.add_item(starter_weapon):
		push_error("Cannot grant starter weapon.")
	equipment.bind(inventory)
	if starter_weapon != null:
		equipment.equip_weapon(0, starter_weapon)
	gameplay_mode.bind(inventory, equipment, player.camera_rig)
	gameplay_mode.mode_changed.connect(func(_mode: GameplayModeController.Mode) -> void: player.interactor.refresh_target())
	inventory_ui.bind(inventory, player)
	inventory_ui.bind_equipment(equipment)
	pause_menu.bind(inventory_ui, player.health)
	inventory_ui.bind_crafting(crafting_ui)
	pause_menu.bind_crafting(crafting_ui)
	pause_menu.opened_changed.connect(player.camera_rig.set_menu_open)
	inventory_ui.opened_changed.connect(player.camera_rig.set_menu_open)
	crafting_ui.opened_changed.connect(player.camera_rig.set_menu_open)
	player.health.changed.connect(func(hp: float, _maximum: float) -> void: player.camera_rig.set_player_alive(hp > 0))
	lighting.bind_clock(clock)
	hud.bind(player, clock, debug_controls)
	debug_controls.bind(player, clock)
	debug_controls.zombie_spawner = $MainWorld/ZombieTestSpawner
	debug_controls.zombie_spawner.bind(player, debug_controls)
	hud.bind_inventory(inventory)
	hud.bind_gameplay_mode(gameplay_mode, equipment)
	player.aim_ray.bind(player.camera_rig, player, debug_controls)
	hud.get_node("Root/Crosshair").bind(player, player.aim_ray, hud.get_node("Root/AimDebugLabel"))
	weapons.bind(player, inventory, equipment, gameplay_mode, catalog)
	hud.bind_weapons(weapons)
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
	var recipe_errors := recipe_book.validation_errors(catalog) if recipe_book != null else PackedStringArray(["Recipe book is missing."])
	if recipe_errors.is_empty():
		crafting_system.bind(inventory, recipe_book, clock)
		crafting_ui.bind(crafting_system, inventory_ui, pause_menu, player)
		$MainWorld/Workbench.workbench_requested.connect(func(actor: Node3D) -> void:
			if actor == player:
				crafting_ui.set_open(true))
	else:
		for message in recipe_errors:
			push_error("Crafting data: " + message)
		hud.show_message("Crafting data is invalid. See the Godot debugger for details.")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and player.health.is_dead:
		get_tree().reload_current_scene()
