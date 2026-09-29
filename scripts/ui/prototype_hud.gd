class_name PrototypeHUD
extends CanvasLayer

@onready var day_label: Label = %DayLabel
@onready var time_label: Label = %TimeLabel
@onready var hp_bar: ProgressBar = %HPBar
@onready var hp_label: Label = %HPLabel
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var stamina_label: Label = %StaminaLabel
@onready var prompt_panel: PanelContainer = %PromptPanel
@onready var prompt_label: Label = %PromptLabel
@onready var toast_label: Label = %ToastLabel
@onready var toast_timer: Timer = $ToastTimer
@onready var debug_panel: PanelContainer = %DebugPanel
@onready var debug_status: Label = %DebugStatus
@onready var death_panel: PanelContainer = %DeathPanel

var player: PlayerController
var _prompt_target: Interactable
var inventory: Inventory
var gameplay_mode: GameplayModeController
var equipment: EquipmentLoadout
var weapons: WeaponController
var waves: NightWaveManager
@onready var ammo_label: Label = %AmmoLabel
@onready var seed_label: Label = %SeedLabel


func _ready() -> void:
	prompt_panel.hide()
	death_panel.hide()
	toast_timer.timeout.connect(func() -> void: toast_label.text = "")


func bind_survival(manager: NightWaveManager) -> void:
	waves = manager
	waves.changed.connect(_refresh_survival)
	waves.feedback.connect(show_message)
	_refresh_survival()


func _refresh_survival() -> void:
	var label: Label = %NightLabel
	label.visible = waves.state != NightWaveManager.State.DAY and waves.state != NightWaveManager.State.GAME_OVER
	match waves.state:
		NightWaveManager.State.ACTIVE:
			label.text = "ZOMBIES LEFT  %d\nAlive: %d  |  Incoming: %d" % [waves.remaining_zombies, waves.alive.size(), waves.total_zombies - waves.spawned_zombies]
		NightWaveManager.State.CLEARED: label.text = "NIGHT CLEARED  |  0 left\nRest at the shelter bed"
		NightWaveManager.State.RESTING: label.text = "RESTING..."


func bind(target_player: PlayerController, clock: GameClock, debug: DebugControls) -> void:
	player = target_player
	player.health.changed.connect(_on_health_changed)
	player.health.died.connect(func() -> void: death_panel.show())
	player.stamina.changed.connect(_on_stamina_changed)
	player.interactor.target_changed.connect(_on_target_changed)
	player.interactor.interaction_completed.connect(show_message)
	clock.time_changed.connect(_on_time_changed)
	debug.status_changed.connect(_on_debug_status)
	debug.message_posted.connect(show_message)
	_on_health_changed(player.health.current_hp, player.health.max_hp)
	_on_stamina_changed(player.stamina.current_stamina, player.stamina.max_stamina)
	_on_time_changed(clock.current_day, clock.current_hour, clock.current_minute, clock.is_daytime)
	_on_target_changed(player.interactor.target)


func _on_health_changed(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "HP   %d / %d" % [ceili(current), ceili(maximum)]
	if not player.health.is_dead:
		death_panel.hide()


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_label.text = "STAMINA   %d / %d" % [ceili(current), ceili(maximum)]


func _on_time_changed(day: int, hour: int, minute: int, daytime: bool) -> void:
	day_label.text = "DAY %d   /   %s" % [day, "DAYTIME" if daytime else "NIGHTTIME"]
	time_label.text = "%02d:%02d" % [hour, minute]


func _on_target_changed(target: Interactable) -> void:
	if is_instance_valid(_prompt_target) and _prompt_target.prompt_changed.is_connected(_refresh_prompt):
		_prompt_target.prompt_changed.disconnect(_refresh_prompt)
	_prompt_target = target
	if is_instance_valid(target):
		target.prompt_changed.connect(_refresh_prompt)
	_refresh_prompt()


func _refresh_prompt() -> void:
	prompt_panel.visible = is_instance_valid(_prompt_target)
	if is_instance_valid(_prompt_target):
		prompt_label.text = _prompt_target.get_interaction_text(player, _key_hint("interact"))


func bind_inventory(target: Inventory) -> void:
	inventory = target
	inventory.inventory_changed.connect(_refresh_seed)
	inventory.selection_changed.connect(_refresh_seed)
	_refresh_seed()


func bind_gameplay_mode(mode: GameplayModeController, loadout: EquipmentLoadout) -> void:
	gameplay_mode = mode
	equipment = loadout
	mode.mode_changed.connect(func(_mode: GameplayModeController.Mode) -> void: _refresh_seed())
	loadout.equipment_changed.connect(_refresh_seed)
	_refresh_seed()


func _refresh_seed() -> void:
	if gameplay_mode != null and not gameplay_mode.is_farming():
		var weapon := equipment.get_selected_weapon()
		var current := "No weapon equipped"
		if weapon != null:
			current = "[%d / %d] %s" % [equipment.selected_weapon_slot + 1, equipment.weapon_slot_count, weapon.display_name]
		seed_label.text = "COMBAT  [Q]\n%s\nWheel: equipped weapons  /  [Tab] Bag" % current
		seed_label.modulate = Color(1.0, 0.81, 0.54)
		return
	var seed := inventory.get_selected_seed()
	seed_label.text = "FARMING  [Q]\nNo plantable seeds\n[Tab] Open bag"
	seed_label.modulate = Color(0.82, 1.0, 0.65)
	if seed != null:
		seed_label.text = "FARMING  [Q]\n%s  x%d  /  Tier %d\nWheel: seeds  /  [Tab] Bag" % [seed.display_name, inventory.get_item_amount(seed.id), seed.tier]


func show_message(message: String) -> void:
	toast_label.text = message
	toast_timer.start()


func bind_weapons(controller: WeaponController) -> void:
	weapons = controller
	controller.state_changed.connect(_refresh_ammo)
	controller.feedback.connect(show_message)
	controller.hit_confirmed.connect($Root/Crosshair.flash_hit)
	_refresh_ammo()


func _refresh_ammo() -> void:
	ammo_label.visible = weapons != null and gameplay_mode != null and not gameplay_mode.is_farming()
	if not ammo_label.visible: return
	if weapons.current == null:
		ammo_label.text = "No usable weapon equipped"
		return
	var state := weapons.current
	ammo_label.text = "%s  [%d]\n%d / %d   |   Magazine / Reserve\n%s" % [state.data.display_name, equipment.selected_weapon_slot + 1,
		state.current_magazine, weapons.reserve_ammo(), "RELOADING..." if state.is_reloading else "RMB Aim  /  LMB Fire  /  R Reload"]


func _on_debug_status(active: bool, summary: String) -> void:
	debug_panel.visible = active
	debug_status.text = summary


func _key_hint(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
	return String(action)
