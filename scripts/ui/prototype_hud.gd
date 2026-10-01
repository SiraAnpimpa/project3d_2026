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
var _completed := false
var _previous_hp := -1.0
var _hurt_remaining := 0.0
var _hint_time := 45.0
var damage_flash: ColorRect
@onready var ammo_label: Label = %AmmoLabel
@onready var seed_label: Label = %SeedLabel


func _ready() -> void:
	prompt_panel.hide()
	death_panel.hide()
	$Root/Title.text = "SOMCHAI'S LAST HARVEST"
	$Root/Title.add_theme_font_size_override("font_size", 16)
	damage_flash = ColorRect.new()
	damage_flash.color = Color(0.65, 0.08, 0.04, 0)
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root.add_child(damage_flash)
	$Root.move_child(damage_flash, 0)
	damage_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	toast_timer.wait_time = 5.0
	toast_timer.timeout.connect(func() -> void: toast_label.text = "")


func bind_survival(manager: NightWaveManager) -> void:
	waves = manager
	waves.changed.connect(_refresh_survival)
	waves.feedback.connect(show_message)
	if waves.progression != null: waves.progression.changed.connect(_refresh_survival)
	_refresh_survival()


func _refresh_survival() -> void:
	var label: Label = %NightLabel
	label.visible = waves.state not in [NightWaveManager.State.GAME_OVER, NightWaveManager.State.GAME_COMPLETED]
	match waves.state:
		NightWaveManager.State.DAY:
			if waves.progression != null and waves.progression.current != null:
				label.text = "TONIGHT: " + waves.progression.current.wave.preview()
				if not waves.progression.pending_rewards.is_empty(): label.text += "\nSeed delivery pending: make room in bag"
		NightWaveManager.State.ACTIVE:
			label.text = ("FINAL NIGHT\n" if waves.clock.current_day == 10 else "") + "ZOMBIES LEFT  %d\nAlive: %d  |  Incoming: %d" % [waves.remaining_zombies, waves.alive.size(), waves.total_zombies - waves.spawned_zombies]
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
	if _previous_hp >= 0 and current < _previous_hp: _hurt_remaining = 0.22
	_previous_hp = current
	hp_label.modulate = Color(1, 0.65, 0.55) if current <= maximum * 0.25 else Color.WHITE
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
	day_label.text = "DAY %d / 10   |   %s" % [mini(day, 10), "DAYTIME" if daytime else "NIGHTTIME"]
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
	if _completed or not is_inside_tree(): return
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
	if state.data.is_melee():
		ammo_label.text = "%s  [%d]\nNo ammo required  |  Damage %.0f\n%s" % [state.data.display_name,equipment.selected_weapon_slot+1,state.data.damage,"SWINGING..." if state.is_swinging else "LMB Swing  /  Scroll Switch"]
		return
	ammo_label.text = "%s  [%d]\n%d / %d   |   Magazine / Reserve\n%s" % [state.data.display_name, equipment.selected_weapon_slot + 1,
		state.current_magazine, weapons.reserve_ammo(), "RELOADING..." if state.is_reloading else "RMB Aim  /  LMB Fire  /  R Reload"]


func _on_debug_status(active: bool, summary: String) -> void:
	debug_panel.visible = active and not _completed
	debug_status.text = summary


func _key_hint(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
	return String(action)


func show_completion() -> void:
	_completed = true
	prompt_panel.hide()
	%NightLabel.hide()
	toast_timer.stop()
	toast_label.text = ""
	for path in ["Root/DebugPanel", "Root/SeedLabel", "Root/AmmoLabel", "Root/Crosshair", "Root/Controls", "Root/AimDebugLabel"]:
		get_node(path).hide()
	var panel := PanelContainer.new()
	panel.name = "CompletionPanel"
	$Root.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position -= Vector2(260, 110)
	panel.custom_minimum_size = Vector2(520, 220)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	panel.add_child(box)
	var label := Label.new()
	label.text = "GAME COMPLETED\nYOU SURVIVED ALL 10 NIGHTS\nRESCUE HAS ARRIVED\nPrototype ending"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	box.add_child(label)
	var restart := Button.new()
	restart.text = "Restart from Day 1  [R]"
	restart.pressed.connect(func() -> void: get_tree().reload_current_scene())
	box.add_child(restart)
	restart.grab_focus()


func _process(delta: float) -> void:
	_hurt_remaining = maxf(0, _hurt_remaining - delta)
	if damage_flash != null: damage_flash.color.a = _hurt_remaining * 0.4
	_hint_time = maxf(0, _hint_time - delta)
	if player != null and _hint_time > 0:
		$Root/Controls.text = "PLANT > HARVEST > WORKBENCH > AMMO\nQ: Combat   /   R: Reload before night\nEsc: Controls & pause"
	elif not _completed:
		$Root/Controls.text = "Esc: Controls & pause"
