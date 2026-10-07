extends Node3D

signal game_ready
var preparation_complete := false

var presentation: GamePresentation
var audio: GameAudio
var progression: ProgressionManager
var skip_night: SkipNightDialog
var consumables: ConsumableUse
@export var catalog: ItemCatalog
@export var starter_loadout: InventoryLoadout
@export var recipe_book: RecipeBook
@export var starter_weapon: ItemData
@export var fallback_weapon: ItemData
@onready var inventory: Inventory = $Player/Inventory
@onready var inventory_ui: InventoryUI = $InventoryUI
@onready var equipment: EquipmentLoadout = $Player/EquipmentLoadout
@onready var gameplay_mode: GameplayModeController = $Player/GameplayMode
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var crafting_system: CraftingSystem = $CraftingSystem
@onready var crafting_ui: CraftingUI = $CraftingUI
@onready var weapons: WeaponController = $Player/WeaponController
@onready var waves: NightWaveManager = $NightWaveManager
@onready var rest: RestSystem = $RestSystem

@onready var player: PlayerController = $Player
@onready var clock: GameClock = $TimeController
@onready var lighting: DayNightEnvironment = $DayNightEnvironment
@onready var hud: PrototypeHUD = $HUD
@onready var debug_controls: DebugControls = $DebugControls


func _ready() -> void:
	# Establish the final fog/light shader configuration before scenery renders.
	# Applying it after all batches existed recompiled the entire visible world
	# in one measured ~550 ms Compatibility render frame.
	lighting.bind_clock(clock)
	var scenery := WorldPresentation.new()
	$MainWorld.add_child(scenery)
	scenery.bind($MainWorld, clock)
	# The loading scene keeps gameplay disabled while the existing world builders
	# yield. Direct editor/test entry still prepares synchronously.
	for builder in [$MainWorld/Terrain, $MainWorld/RuralEnvironment]:
		if not builder.preparation_complete: await builder.prepared
	player.global_transform = $MainWorld/PlayerSpawn.global_transform
	if starter_loadout == null or not starter_loadout.give_to(inventory):
		push_error("Starter loadout is invalid or inventory is too small.")
	if starter_weapon != null and not inventory.add_item(starter_weapon):
		push_error("Cannot grant starter weapon.")
	if fallback_weapon != null and not inventory.add_item(fallback_weapon):
		push_error("Cannot grant fallback weapon.")
	equipment.bind(inventory)
	if starter_weapon != null:
		equipment.equip_weapon(0, starter_weapon)
	if fallback_weapon != null:
		equipment.equip_weapon(1, fallback_weapon)
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
	hud.bind(player, clock, debug_controls)
	debug_controls.bind(player, clock)
	debug_controls.zombie_spawner = $MainWorld/ZombieTestSpawner
	debug_controls.zombie_spawner.bind(player, debug_controls)
	debug_controls.status_changed.connect(_update_spawn_debug)
	_update_spawn_debug(debug_controls.active, "")
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
	progression = ProgressionManager.new()
	progression.name = "ProgressionManager"
	progression.data = preload("res://resources/progression/ten_days.tres")
	add_child(progression)
	progression.feedback.connect(hud.show_message)
	progression.bind(clock, inventory, catalog, recipe_book)
	crafting_system.progression = progression
	progression.changed.connect(crafting_ui.refresh)
	waves.progression = progression
	waves.completed.connect(_on_completed)
	waves.bind(clock, player, $MainWorld/WaveSpawnPoints)
	rest.bind(waves, player)
	$MainWorld/Bed.bind(rest)
	hud.bind_survival(waves)
	debug_controls.waves = waves
	audio = GameAudio.new()
	audio.name = "GameAudio"
	add_child(audio)
	audio.bind(self)
	presentation = GamePresentation.new()
	presentation.name = "Presentation"
	add_child(presentation)
	presentation.bind(self)
	consumables = ConsumableUse.new()
	consumables.name = "ConsumableUse"
	add_child(consumables)
	consumables.bind(self, catalog.get_item(&"basic_medicine"))
	hud.bind_consumables(consumables, crafting_system)
	consumables.used.connect(func(_item: ItemData, _restored: float) -> void: audio.cue("click"))
	skip_night = SkipNightDialog.new()
	skip_night.name = "SkipNightDialog"
	add_child(skip_night)
	skip_night.bind(self)
	for screen in [inventory_ui.screen, crafting_ui.screen, pause_menu.get_node("Screen")]:
		screen.theme = PresentationStyle.theme(screen == crafting_ui.screen)
	if get_tree().has_meta("normal_play") or not OS.is_debug_build():
		if get_tree().has_meta("normal_play"): get_tree().remove_meta("normal_play")
		debug_controls.set_active(false)
		# Preserve the development fixture only for direct editor/test entry.
		$MainWorld/TargetDummy.queue_free()
	gameplay_mode.mode_changed.connect(func(mode: GameplayModeController.Mode) -> void:
		hud.show_message("FARMING MODE" if mode == GameplayModeController.Mode.FARMING else "COMBAT MODE"))
	pause_menu.bind_web_capture(self)
	preparation_complete = true
	game_ready.emit()

func wait_until_ready() -> void:
	if not preparation_complete: await game_ready


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and (player.health.is_dead or waves.state == NightWaveManager.State.GAME_COMPLETED):
		PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn")


func _update_spawn_debug(active: bool, _summary: String) -> void:
	$TestInteractable/Label.visible = active
	$TestInteractable.enabled = active
	for side in ["North", "South", "East", "West"]:
		$MainWorld.get_node(side + "SpawnMarker").visible = active
		$MainWorld.get_node(side + "SpawnLabel").visible = active


func _on_completed() -> void:
	# Freeze gameplay nodes while leaving the HUD and restart handler available.
	inventory_ui.set_open(false)
	crafting_ui.set_open(false)
	player.camera_rig.set_player_alive(false)
	player.velocity = Vector3.ZERO
	player.process_mode = Node.PROCESS_MODE_DISABLED
	inventory_ui.process_mode = Node.PROCESS_MODE_DISABLED
	crafting_ui.process_mode = Node.PROCESS_MODE_DISABLED
	pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
	debug_controls.process_mode = Node.PROCESS_MODE_DISABLED
	$MainWorld/ZombieTestSpawner.clear_zombies()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	presentation.start_ending()
