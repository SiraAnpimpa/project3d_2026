class_name PrototypeHUD
extends CanvasLayer

var day_label: Label
var time_label: Label
var hp_bar: ProgressBar
var hp_label: Label
var stamina_bar: ProgressBar
var stamina_label: Label
var prompt_panel: PanelContainer
var prompt_label: Label
var toast_label: Label
var toast_timer: Timer
var debug_panel: PanelContainer
var debug_status: Label
var death_panel: PanelContainer
var ammo_label: Label
var seed_label: Label
var damage_flash: ColorRect
var player: PlayerController
var inventory: Inventory
var gameplay_mode: GameplayModeController
var equipment: EquipmentLoadout
var weapons: WeaponController
var waves: NightWaveManager
var _prompt_target: Interactable
var _completed := false
var _previous_hp := -1.0
var _hurt_remaining := 0.0
var _clock: GameClock
var _prompt_icon: TextureRect
var _prompt_key: Label
var _selected_icon: TextureRect
var _mode_label: Label
var _slot_label: Label
var _wave_label: Label
var _wave_panel: PanelContainer
var _clock_panel: PanelContainer
var _stats_panel: PanelContainer
var _equipment_panel: PanelContainer
var _toast_panel: PanelContainer
var _toast_icon: TextureRect
var _toast_tween: Tween
var _mode_tween: Tween
var _ready_to_show := true

func _ready() -> void:
	$Root.theme = PresentationStyle.theme(true)
	damage_flash = ColorRect.new()
	damage_flash.color = Color(0.65, 0.08, 0.04, 0)
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root.add_child(damage_flash)
	damage_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_clock_panel = _panel("ClockPanel", Control.PRESET_TOP_LEFT, Rect2(24, 24, 200, 78))
	var clock_row := PresentationStyle.box(_clock_panel, false, 14)
	PresentationStyle.icon(clock_row, UiIcons.get_icon("clock"), 25)
	var clock_text := PresentationStyle.box(clock_row, true, 0)
	day_label = PresentationStyle.label(clock_text, "DAY 1", 14)
	day_label.modulate = PresentationStyle.MUTED
	time_label = PresentationStyle.label(clock_text, "06:00", 24)
	_stats_panel = _panel("StatsPanel", Control.PRESET_BOTTOM_LEFT, Rect2(24, -106, 258, 82))
	var stats := PresentationStyle.box(_stats_panel, true, 10)
	var hp := _status_row(stats, "health", PresentationStyle.RED)
	hp_bar = hp[0]
	hp_label = hp[1]
	var stamina := _status_row(stats, "stamina", PresentationStyle.SAGE)
	stamina_bar = stamina[0]
	stamina_label = stamina[1]
	_equipment_panel = _panel("EquipmentPanel", Control.PRESET_BOTTOM_RIGHT, Rect2(-286, -178, 262, 154))
	var selection := PresentationStyle.box(_equipment_panel, true, 3)
	var mode_row := PresentationStyle.box(selection, false, 10)
	_mode_label = PresentationStyle.label(mode_row, "FARMING", 14)
	_mode_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	PresentationStyle.keycap(mode_row, "Q")
	var item_row := PresentationStyle.box(selection, false, 14)
	_selected_icon = PresentationStyle.icon(item_row, null, 46)
	var counts := PresentationStyle.box(item_row, true, 0)
	seed_label = PresentationStyle.label(counts, "", 26)
	ammo_label = PresentationStyle.label(counts, "", 26)
	_slot_label = PresentationStyle.label(selection, "", 15)
	_slot_label.modulate = PresentationStyle.MUTED
	prompt_panel = _panel("PromptPanel", Control.PRESET_CENTER_BOTTOM, Rect2(-180, -100, 360, 60))
	var prompt := PresentationStyle.box(prompt_panel, false, 12)
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	_prompt_key = PresentationStyle.keycap(prompt, "E")
	_prompt_icon = PresentationStyle.icon(prompt, null, 26)
	prompt_label = PresentationStyle.label(prompt, "", 18)
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_wave_panel = _panel("NightPanel", Control.PRESET_CENTER_TOP, Rect2(-94, 24, 188, 58))
	var wave_row := PresentationStyle.box(_wave_panel, false, 12)
	wave_row.alignment = BoxContainer.ALIGNMENT_CENTER
	PresentationStyle.icon(wave_row, UiIcons.get_icon("wave"), 28).modulate = PresentationStyle.GOLD
	_wave_label = PresentationStyle.label(wave_row, "", 22)
	_wave_label.name = "NightLabel"
	_toast_panel = _panel("ToastPanel", Control.PRESET_CENTER_TOP, Rect2(-244, 96, 488, 48))
	var toast_row := PresentationStyle.box(_toast_panel, false, 12)
	toast_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_toast_icon = PresentationStyle.icon(toast_row, UiIcons.get_icon("notice"), 20)
	toast_label = PresentationStyle.label(toast_row, "", 17)
	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.8
	add_child(toast_timer)
	toast_timer.timeout.connect(_fade_toast)
	debug_panel = _panel("DebugPanel", Control.PRESET_TOP_RIGHT, Rect2(-440, 20, 420, 220))
	debug_status = PresentationStyle.label(debug_panel, "", 16)
	debug_panel.hide()
	death_panel = PresentationStyle.center_panel($Root, Vector2(520, 300))
	death_panel.name = "DeathPanel"
	PresentationStyle.label(death_panel, "Game over", 30).name = "Text"
	death_panel.hide()
	_toast_panel.hide()
	prompt_panel.hide()
	_wave_panel.hide()
	_hide_world_labels.call_deferred()

func _panel(node_name: String, preset: int, rect: Rect2) -> PanelContainer:
	var result := PanelContainer.new()
	result.name = node_name
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root.add_child(result)
	result.set_anchors_and_offsets_preset(preset)
	result.offset_left = rect.position.x
	result.offset_top = rect.position.y
	result.offset_right = rect.end.x
	result.offset_bottom = rect.end.y
	result.add_theme_stylebox_override("panel", PresentationStyle.surface(Color(0.065, 0.095, 0.075, 0.94), 12))
	return result

func _status_row(parent: Node, symbol: String, tint: Color) -> Array:
	var row := PresentationStyle.box(parent, false, 10)
	PresentationStyle.icon(row, UiIcons.get_icon(symbol), 20).modulate = tint
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(146, 9)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_stylebox_override("fill", PresentationStyle.flat(tint))
	row.add_child(bar)
	var number := PresentationStyle.label(row, "100", 16)
	number.custom_minimum_size.x = 31
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return [bar, number]

func _hide_world_labels() -> void:
	# UI policy only. Plot state, models and target availability stay unchanged.
	var world := get_parent().get_node_or_null("MainWorld")
	if world == null: return
	for node in world.find_children("*", "Interactable", true, false):
		for label in node.find_children("*", "Label3D", true, false): label.hide()

func bind(target_player: PlayerController, clock: GameClock, debug: DebugControls) -> void:
	player = target_player
	_clock = clock
	player.health.changed.connect(_on_health_changed)
	player.health.died.connect(func() -> void: death_panel.show(); _sync_visibility())
	player.stamina.changed.connect(_on_stamina_changed)
	player.interactor.target_changed.connect(_on_target_changed)
	player.interactor.interaction_completed.connect(show_message)
	player.camera_rig.controls_changed.connect(func(_enabled: bool) -> void: _sync_visibility())
	clock.time_changed.connect(_on_time_changed)
	debug.status_changed.connect(_on_debug_status)
	debug.message_posted.connect(show_message)
	_on_health_changed(player.health.current_hp, player.health.max_hp)
	_on_stamina_changed(player.stamina.current_stamina, player.stamina.max_stamina)
	_on_time_changed(clock.current_day, clock.current_hour, clock.current_minute, clock.is_daytime)
	_on_target_changed(player.interactor.target)

func bind_inventory(target: Inventory) -> void:
	inventory = target
	inventory.inventory_changed.connect(_refresh_seed)
	inventory.selection_changed.connect(_refresh_seed)
	_refresh_seed()

func bind_gameplay_mode(mode: GameplayModeController, loadout: EquipmentLoadout) -> void:
	gameplay_mode = mode
	equipment = loadout
	mode.mode_changed.connect(func(_mode: GameplayModeController.Mode) -> void: _refresh_seed(); _refresh_prompt())
	loadout.equipment_changed.connect(_refresh_seed)
	_refresh_seed()

func bind_weapons(controller: WeaponController) -> void:
	weapons = controller
	controller.state_changed.connect(_refresh_ammo)
	controller.feedback.connect(show_message)
	controller.hit_confirmed.connect($Root/Crosshair.flash_hit)
	_refresh_ammo()

func bind_survival(manager: NightWaveManager) -> void:
	waves = manager
	waves.changed.connect(_refresh_survival)
	waves.feedback.connect(show_message)
	if waves.progression != null: waves.progression.changed.connect(_refresh_survival)
	_refresh_survival()

func _sync_visibility() -> void:
	_ready_to_show = player != null and player.camera_rig.can_control() and not player.health.is_dead and not _completed
	for control in [_clock_panel, _stats_panel, _equipment_panel]: control.visible = _ready_to_show
	_toast_panel.visible = _ready_to_show and not toast_label.text.is_empty()
	_refresh_prompt()
	_refresh_survival()

func _refresh_survival() -> void:
	if waves == null: return
	_wave_panel.visible = _ready_to_show and not waves.clock.is_daytime and waves.state in [NightWaveManager.State.ACTIVE, NightWaveManager.State.CLEARED, NightWaveManager.State.RESTING]
	_wave_label.text = str(waves.remaining_zombies)
	if waves.clock.current_day == 10: _wave_label.text = "%d  ·  FINAL" % waves.remaining_zombies
	_wave_panel.tooltip_text = "Night cleared" if waves.state == NightWaveManager.State.CLEARED else "Zombies remaining, including incoming"

func _on_health_changed(current: float, maximum: float) -> void:
	if _previous_hp >= 0 and current < _previous_hp: _hurt_remaining = 0.22
	_previous_hp = current
	hp_label.modulate = PresentationStyle.RED if current <= maximum * 0.25 else Color.WHITE
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = str(ceili(current))
	hp_bar.tooltip_text = "Health %d / %d" % [ceili(current), ceili(maximum)]
	if not player.health.is_dead: death_panel.hide()

func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_label.text = str(ceili(current))
	stamina_bar.tooltip_text = "Stamina %d / %d" % [ceili(current), ceili(maximum)]

func _on_time_changed(day: int, hour: int, minute: int, _daytime: bool) -> void:
	day_label.text = "DAY %d / 10" % mini(day, 10)
	time_label.text = "%02d:%02d" % [hour, minute]
	_refresh_survival()

func _on_target_changed(target: Interactable) -> void:
	if is_instance_valid(_prompt_target) and _prompt_target.prompt_changed.is_connected(_refresh_prompt):
		_prompt_target.prompt_changed.disconnect(_refresh_prompt)
	_prompt_target = target
	if is_instance_valid(target): target.prompt_changed.connect(_refresh_prompt)
	_refresh_prompt()

func _refresh_prompt() -> void:
	prompt_panel.visible = _ready_to_show and is_instance_valid(_prompt_target) and (gameplay_mode == null or gameplay_mode.is_farming())
	if not prompt_panel.visible: return
	_prompt_key.text = _key_hint("interact")
	_prompt_key.show()
	_prompt_icon.texture = UiIcons.get_icon("notice")
	if _prompt_target is FarmPlot:
		var plot := _prompt_target as FarmPlot
		if plot.state == FarmPlot.State.EMPTY:
			var seed := inventory.get_selected_seed() if inventory != null else null
			_prompt_icon.texture = UiIcons.item_icon(seed)
			prompt_label.text = "Plant" if seed != null else "Select a seed"
			if seed == null: _prompt_key.text = "Tab"
		elif plot.state == FarmPlot.State.READY:
			_prompt_icon.texture = UiIcons.item_icon(plot.plant_data.harvest_item)
			prompt_label.text = "Harvest  ×%d" % plot.plant_data.harvest_amount
		else:
			_prompt_key.hide()
			_prompt_icon.texture = UiIcons.item_icon(plot.plant_data.harvest_item)
			prompt_label.text = "Growing  %d%%" % floori(plot.growth_progress * 100)
	elif _prompt_target is Workbench:
		_prompt_icon.texture = UiIcons.get_icon("workbench")
		prompt_label.text = "Craft"
	elif _prompt_target is ShelterBed:
		_prompt_icon.texture = UiIcons.get_icon("rest")
		if waves != null and waves.state == NightWaveManager.State.CLEARED:
			prompt_label.text = "Rest until morning"
		else:
			_prompt_key.hide()
			prompt_label.text = "Clear the night to rest"
	else:
		prompt_label.text = "Interact"

func _refresh_seed() -> void:
	if inventory == null: return
	var farming := gameplay_mode == null or gameplay_mode.is_farming()
	seed_label.visible = farming
	ammo_label.visible = not farming
	_mode_label.text = "FARMING" if farming else "COMBAT"
	_mode_label.modulate = PresentationStyle.SAGE if farming else PresentationStyle.GOLD
	if farming:
		var seed := inventory.get_selected_seed()
		_selected_icon.texture = UiIcons.item_icon(seed)
		seed_label.text = "×%d" % inventory.get_item_amount(seed.id) if seed != null else "—"
		_slot_label.text = seed.display_name if seed != null else "Tab  Select a seed"
	else:
		_refresh_ammo()
	_refresh_prompt()

func _refresh_ammo() -> void:
	var combat := weapons != null and gameplay_mode != null and not gameplay_mode.is_farming()
	ammo_label.visible = combat
	if not combat: return
	var item := equipment.get_selected_weapon()
	_selected_icon.texture = UiIcons.item_icon(item)
	if weapons.current == null:
		ammo_label.text = "—"
		_slot_label.text = "No weapon equipped"
		return
	var state := weapons.current
	if state.data.is_melee():
		ammo_label.text = "Swing"
		_slot_label.text = "Slot %d  ·  LMB" % (equipment.selected_weapon_slot + 1)
	else:
		ammo_label.text = "%d / %d" % [state.current_magazine, weapons.reserve_ammo()]
		_slot_label.text = "Reloading…" if state.is_reloading else "Slot %d  ·  R Reload" % (equipment.selected_weapon_slot + 1)

func show_message(message: String) -> void:
	if _completed or not is_inside_tree() or message.is_empty(): return
	if message in ["FARMING MODE", "COMBAT MODE"]:
		toast_timer.stop()
		toast_label.text = ""
		_toast_panel.hide()
		if _toast_tween != null and _toast_tween.is_valid(): _toast_tween.kill()
		if _mode_tween != null and _mode_tween.is_valid(): _mode_tween.kill()
		_equipment_panel.modulate = Color(1.18, 1.18, 1.12)
		_mode_tween = create_tween()
		_mode_tween.tween_property(_equipment_panel, "modulate", Color.WHITE, 0.22)
		return
	if message == "Workbench opened": return
	var text := message.replace("\n", "  ·  ").strip_edges()
	var symbol := "notice"
	if message.contains("NEW SEED:") or message.contains("NEW RECIPE:"):
		text = "%d seeds · %d recipes unlocked" % [message.count("NEW SEED:"), message.count("NEW RECIPE:")]
		symbol = "gift"
	elif message.begins_with("DAY "):
		text = message.get_slice("\n", 0) + " · A new morning"
	elif message.begins_with("NIGHT "):
		text = "Night %d · Zombies approaching" % _clock.current_day
	elif message.contains("FINAL NIGHT"):
		text = "FINAL NIGHT · Hold on until dawn"
	elif message.begins_with("Harvested"):
		symbol = "bag"
	elif message.contains("Inventory full") or message.contains("inventory space"):
		text = "Bag full · Make room to continue"
	# Keep the original response available to assistive/hover inspection.
	toast_label.tooltip_text = message
	toast_label.text = text if text.length() <= 58 else text.left(55) + "…"
	_toast_icon.texture = UiIcons.get_icon(symbol)
	if _toast_tween != null and _toast_tween.is_valid(): _toast_tween.kill()
	_toast_panel.modulate.a = 1
	_toast_panel.visible = _ready_to_show
	toast_timer.start()

func _fade_toast() -> void:
	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast_panel, "modulate:a", 0.0, 0.3)
	_toast_tween.tween_callback(func() -> void: toast_label.text = ""; _toast_panel.hide())

func _on_debug_status(active: bool, summary: String) -> void:
	debug_panel.visible = active and OS.is_debug_build() and not _completed
	debug_status.text = summary

func _key_hint(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
	return String(action)

func show_completion() -> void:
	_completed = true
	toast_timer.stop()
	toast_label.text = ""
	_sync_visibility()
	$Root/Crosshair.hide()
	$Root/AimDebugLabel.hide()
	debug_panel.hide()
	var panel := PresentationStyle.center_panel($Root, Vector2(520, 220))
	panel.name = "CompletionPanel"
	var rows := PresentationStyle.box(panel)
	PresentationStyle.label(rows, "YOU SURVIVED\n10 NIGHTS", 32)
	PresentationStyle.button(rows, "Play again", func() -> void: get_tree().reload_current_scene()).grab_focus()

func _process(delta: float) -> void:
	_hurt_remaining = maxf(0, _hurt_remaining - delta)
	if damage_flash != null: damage_flash.color.a = _hurt_remaining * 0.55
