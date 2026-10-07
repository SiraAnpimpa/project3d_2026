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
var _slots_row: HBoxContainer
var _slot_marks: Array[Label] = []
var _death_shade: ColorRect
var _clock_actions: HBoxContainer
var _objective_panel: PanelContainer
var _objective_title: Label
var _objective_copy: Label
var _night_title: Label
var _night_copy: Label
var _phase_label: Label
var _count_caption: Label
var _equipment_hint: Label
var _health_title: Label
var _stamina_title: Label
var _slot_cards: Array[PanelContainer] = []
var _slot_icons: Array[TextureRect] = []
var _control_hints: HBoxContainer

func _ready() -> void:
	$Root.theme = PresentationStyle.theme(true).duplicate()
	$Root.theme.set_color("font_outline_color", "Label", Color(0.015, 0.025, 0.02, 0.88))
	$Root.theme.set_constant("outline_size", "Label", 1)
	damage_flash = ColorRect.new()
	damage_flash.color = Color(0.65, 0.08, 0.04, 0)
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root.add_child(damage_flash)
	damage_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_clock_panel = _panel("ClockPanel", Control.PRESET_TOP_LEFT, Rect2(24, 24, 236, 66))
	var clock_row := PresentationStyle.box(_clock_panel, false, 10)
	clock_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	PresentationStyle.icon(clock_row, UiIcons.get_icon("clock"), 22).modulate = PresentationStyle.GOLD
	var clock_text := PresentationStyle.box(clock_row, true, 0)
	clock_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var day_row := PresentationStyle.box(clock_text, false, 6)
	day_label = PresentationStyle.label(day_row, "Day 1", 12)
	day_label.modulate = PresentationStyle.PAPER
	_phase_label = PresentationStyle.label(day_row, "/ 10 · DAY", 11)
	_phase_label.modulate = PresentationStyle.MUTED
	time_label = PresentationStyle.label(clock_text, "06:00", 24)
	_clock_actions = PresentationStyle.box(clock_row, false, 0) as HBoxContainer
	_clock_actions.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_stats_panel = _panel("StatsPanel", Control.PRESET_BOTTOM_LEFT, Rect2(24, -152, 216, 100))
	var stats := PresentationStyle.box(_stats_panel, true, 8)
	var hp := _status_row(stats, "health", "HEALTH", PresentationStyle.RED)
	hp_bar = hp[0]
	hp_label = hp[1]
	_health_title = hp[2]
	var stamina := _status_row(stats, "stamina", "STAMINA", PresentationStyle.SAGE)
	stamina_bar = stamina[0]
	stamina_label = stamina[1]
	_stamina_title = stamina[2]
	_control_hints = PresentationStyle.box($Root, false, 10) as HBoxContainer
	_control_hints.name = "ControlHints"
	_control_hints.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_control_hints.offset_left = 26
	_control_hints.offset_top = -44
	_control_hints.offset_right = 240
	_control_hints.offset_bottom = -16
	_hint_key(_control_hints, _key_hint("toggle_inventory"))
	PresentationStyle.label(_control_hints, "Bag", 12)
	_hint_key(_control_hints, "Esc")
	PresentationStyle.label(_control_hints, "Pause", 12)
	_equipment_panel = _panel("EquipmentPanel", Control.PRESET_BOTTOM_RIGHT, Rect2(-244, -164, 220, 140))
	var selection := PresentationStyle.box(_equipment_panel, true, 4)
	var mode_row := PresentationStyle.box(selection, false, 10)
	_mode_label = PresentationStyle.label(mode_row, "FARMING", 12)
	_mode_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint_key(mode_row, _key_hint("switch_mode"))
	var item_row := PresentationStyle.box(selection, false, 12)
	_selected_icon = PresentationStyle.icon(item_row, null, 44)
	var counts := PresentationStyle.box(item_row, true, 0)
	counts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seed_label = PresentationStyle.label(counts, "", 24)
	ammo_label = PresentationStyle.label(counts, "", 24)
	_count_caption = PresentationStyle.label(counts, "SEEDS IN BAG", 11)
	_count_caption.modulate = PresentationStyle.MUTED
	_slot_label = PresentationStyle.label(selection, "", 16)
	_slot_label.clip_text = true
	_slot_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_slot_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slots_row = PresentationStyle.box(selection, false, 6) as HBoxContainer
	for index in 3:
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.custom_minimum_size = Vector2(58, 40)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_slots_row.add_child(card)
		var content := PresentationStyle.box(card, false, 4)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mark := PresentationStyle.label(content, str(index + 1), 11)
		mark.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		_slot_marks.append(mark)
		_slot_icons.append(PresentationStyle.icon(content, null, 26))
		_slot_cards.append(card)
	_slots_row.hide()
	_equipment_hint = PresentationStyle.label(selection, "TAB · SELECT SEED", 11)
	_equipment_hint.modulate = PresentationStyle.MUTED
	prompt_panel = _panel("PromptPanel", Control.PRESET_CENTER_BOTTOM, Rect2(-170, -90, 340, 50))
	var prompt := PresentationStyle.box(prompt_panel, false, 12)
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	_prompt_key = _hint_key(prompt, "E")
	_prompt_key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_icon = PresentationStyle.icon(prompt, null, 24)
	prompt_label = PresentationStyle.label(prompt, "", 18)
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_wave_panel = _panel("NightPanel", Control.PRESET_TOP_RIGHT, Rect2(-262, 24, 238, 82))
	var wave_rows := PresentationStyle.box(_wave_panel, true, 3)
	_night_title = PresentationStyle.label(wave_rows, "NIGHT WATCH", 11)
	_night_title.modulate = PresentationStyle.GOLD
	var wave_row := PresentationStyle.box(wave_rows, false, 10)
	PresentationStyle.icon(wave_row, UiIcons.get_icon("wave"), 24).modulate = PresentationStyle.GOLD
	_wave_label = PresentationStyle.label(wave_row, "", 22)
	_wave_label.name = "NightLabel"
	_night_copy = PresentationStyle.label(wave_rows, "", 12)
	_night_copy.modulate = PresentationStyle.MUTED
	_objective_panel = _panel("ObjectivePanel", Control.PRESET_TOP_RIGHT, Rect2(-262, 24, 238, 76))
	var objective := PresentationStyle.box(_objective_panel, true, 5)
	PresentationStyle.label(objective, "SURVIVE THE HARVEST", 11).modulate = PresentationStyle.GOLD
	_objective_title = PresentationStyle.label(objective, "Prepare for night", 16)
	_objective_copy = PresentationStyle.label(objective, "Grow supplies · Craft ammunition", 12)
	_objective_copy.modulate = PresentationStyle.MUTED
	_toast_panel = _panel("ToastPanel", Control.PRESET_CENTER_TOP, Rect2(-220, 120, 440, 42))
	var toast_row := PresentationStyle.box(_toast_panel, false, 12)
	toast_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_toast_icon = PresentationStyle.icon(toast_row, UiIcons.get_icon("notice"), 20)
	toast_label = PresentationStyle.label(toast_row, "", 15)
	toast_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toast_label.clip_text = true
	toast_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.8
	add_child(toast_timer)
	toast_timer.timeout.connect(_fade_toast)
	debug_panel = _panel("DebugPanel", Control.PRESET_TOP_RIGHT, Rect2(-440, 20, 420, 220))
	debug_status = PresentationStyle.label(debug_panel, "", 16)
	debug_panel.hide()
	_death_shade = ColorRect.new()
	_death_shade.color = Color(0.025, 0.04, 0.03, 0.62)
	$Root.add_child(_death_shade)
	_death_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_death_shade.hide()
	death_panel = PresentationStyle.center_panel($Root, Vector2(520, 300))
	death_panel.name = "DeathPanel"
	PresentationStyle.label(death_panel, "Game over", 30).name = "Text"
	death_panel.hide()
	_toast_panel.hide()
	prompt_panel.hide()
	_wave_panel.hide()
	# Decorative HUD containers must leave mouse input available to the game.
	for panel: Control in [_clock_panel, _stats_panel, _equipment_panel, prompt_panel, _wave_panel, _objective_panel, _toast_panel, _control_hints]:
		for control: Control in panel.find_children("*", "Control", true, false): control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hide_world_labels.call_deferred()

func _panel(node_name: String, preset: int, rect: Rect2) -> PanelContainer:
	var result := PanelContainer.new()
	result.name = node_name
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root.add_child(result)
	result.set_anchors_and_offsets_preset(preset)
	if preset in [Control.PRESET_BOTTOM_LEFT, Control.PRESET_BOTTOM_RIGHT, Control.PRESET_CENTER_BOTTOM]: result.grow_vertical = Control.GROW_DIRECTION_BEGIN
	if preset in [Control.PRESET_TOP_RIGHT, Control.PRESET_BOTTOM_RIGHT]: result.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	result.offset_left = rect.position.x
	result.offset_top = rect.position.y
	result.offset_right = rect.end.x
	result.offset_bottom = rect.end.y
	result.add_theme_stylebox_override("panel", _hud_surface())
	return result

func _hud_surface(accent: Color = Color(0.66, 0.69, 0.5, 0.18)) -> StyleBoxFlat:
	var style := PresentationStyle.flat(Color(0.035, 0.061, 0.05, 0.44), accent, 1)
	style.border_width_top = 1
	style.set_corner_radius_all(5)
	style.set_content_margin_all(10)
	style.shadow_color = Color(0, 0, 0, 0)
	style.shadow_size = 0
	return style

func _status_row(parent: Node, symbol: String, title: String, tint: Color) -> Array:
	var row := PresentationStyle.box(parent, false, 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	PresentationStyle.icon(row, UiIcons.get_icon(symbol), 20).modulate = tint
	var content := PresentationStyle.box(row, true, 4)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var header := PresentationStyle.box(content, false, 8)
	var caption := PresentationStyle.label(header, title, 12)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption.modulate = PresentationStyle.MUTED
	var number := PresentationStyle.label(header, "100", 18)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(146, 6)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for entry in [["fill", tint], ["background", Color("324239")]]:
		var style := PresentationStyle.flat(entry[1])
		style.set_content_margin_all(0)
		style.set_corner_radius_all(3)
		bar.add_theme_stylebox_override(entry[0], style)
	content.add_child(bar)
	return [bar, number, caption]

func _refresh_slots() -> void:
	if equipment == null: return
	for index in _slot_cards.size():
		var item := equipment.get_equipped_weapon(index)
		var selected := index == equipment.selected_weapon_slot and item != null
		_slot_icons[index].texture = UiIcons.item_icon(item)
		_slot_marks[index].text = str(index + 1) if item != null else "—"
		_slot_marks[index].modulate = PresentationStyle.GOLD if selected else PresentationStyle.MUTED
		_slot_cards[index].tooltip_text = item.display_name if item != null else "Empty equipment slot"
		var style := PresentationStyle.flat(Color(0.20, 0.27, 0.20, 0.6) if selected else Color(0.09, 0.14, 0.11, 0.35), PresentationStyle.GOLD if selected else Color("435347"), 2 if selected else 1)
		style.set_content_margin_all(4)
		_slot_cards[index].add_theme_stylebox_override("panel", style)

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
	player.health.died.connect(func() -> void: _death_shade.show(); death_panel.show(); _sync_visibility())
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
	for control in [_clock_panel, _stats_panel, _equipment_panel, _control_hints]: control.visible = _ready_to_show
	_toast_panel.visible = _ready_to_show and not toast_label.text.is_empty()
	_refresh_prompt()
	_refresh_survival()

func _refresh_survival() -> void:
	if waves == null: return
	var night := not waves.clock.is_daytime
	_objective_panel.visible = _ready_to_show and not night
	_objective_title.text = "Prepare for final night" if waves.clock.current_day == 10 else "Prepare for night"
	_wave_panel.visible = _ready_to_show and night and waves.state in [NightWaveManager.State.ACTIVE, NightWaveManager.State.CLEARED, NightWaveManager.State.RESTING]
	var cleared := waves.state == NightWaveManager.State.CLEARED
	_night_title.text = "FINAL NIGHT / 10" if waves.clock.current_day == 10 else "NIGHT %d / 10" % waves.clock.current_day
	_wave_label.text = "Area cleared" if cleared else "%d remaining" % waves.remaining_zombies
	_wave_label.modulate = PresentationStyle.SAGE if cleared else PresentationStyle.PAPER
	_night_copy.text = "Rest at cabin until morning" if cleared else "Stay alive · Watch for incoming"
	_wave_panel.tooltip_text = "Night cleared" if cleared else "Zombies remaining, including incoming"

func _on_health_changed(current: float, maximum: float) -> void:
	if _previous_hp >= 0 and current < _previous_hp: _hurt_remaining = 0.22
	_previous_hp = current
	_health_title.text = "HEALTH · LOW" if current <= maximum * 0.25 else "HEALTH"
	_health_title.modulate = PresentationStyle.RED if current <= maximum * 0.25 else PresentationStyle.MUTED
	hp_label.modulate = PresentationStyle.RED if current <= maximum * 0.25 else Color.WHITE
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = str(ceili(current))
	hp_bar.tooltip_text = "Health %d / %d" % [ceili(current), ceili(maximum)]
	if not player.health.is_dead:
		death_panel.hide()
		_death_shade.hide()

func _on_stamina_changed(current: float, maximum: float) -> void:
	_stamina_title.text = "STAMINA · LOW" if current <= maximum * 0.15 else "STAMINA"
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_label.text = str(ceili(current))
	stamina_bar.tooltip_text = "Stamina %d / %d" % [ceili(current), ceili(maximum)]

func _on_time_changed(day: int, hour: int, minute: int, _daytime: bool) -> void:
	day_label.text = "Day %d" % mini(day, 10)
	time_label.text = "%02d:%02d" % [hour, minute]
	_phase_label.text = "/ 10 · DAY" if _daytime else "/ 10 · NIGHT"
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
	_slots_row.visible = not farming
	_equipment_panel.offset_top = -164 if farming else -208
	_count_caption.text = "SEEDS IN BAG" if farming else "LOADED / RESERVE"
	_count_caption.show()
	_equipment_hint.text = "TAB · SELECT SEED" if farming else "MOUSE WHEEL · CHANGE WEAPON"
	_refresh_slots()
	_slot_label.show()
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
	_refresh_slots()
	var item := equipment.get_selected_weapon()
	_selected_icon.texture = UiIcons.item_icon(item)
	if weapons.current == null or item == null:
		ammo_label.text = "—"
		_count_caption.text = "EMPTY LOADOUT"
		_slot_label.text = "No weapon equipped"
		_equipment_hint.text = "TAB · EQUIP FROM YOUR BAG"
		return
	var state := weapons.current
	if state.data.is_melee():
		ammo_label.hide()
		ammo_label.text = "Swing"
		_count_caption.text = "MELEE WEAPON"
		_slot_label.text = item.display_name
	else:
		_count_caption.text = "RELOADING" if state.is_reloading else "LOADED / RESERVE"
		ammo_label.text = "%d / %d" % [state.current_magazine, weapons.reserve_ammo()]
		ammo_label.modulate = PresentationStyle.RED if state.current_magazine == 0 else PresentationStyle.PAPER
		_slot_label.text = "Reloading…" if state.is_reloading else "R  Reload" if state.current_magazine == 0 else item.display_name
		_slot_label.show()

func show_message(message: String) -> void:
	if _completed or not is_inside_tree() or message.is_empty(): return
	if message in ["FARMING MODE", "COMBAT MODE"]:
		toast_timer.stop()
		toast_label.text = ""
		_toast_panel.hide()
		if _toast_tween != null and _toast_tween.is_valid(): _toast_tween.kill()
		if _mode_tween != null and _mode_tween.is_valid(): _mode_tween.kill()
		if PresentationStyle.reduced_motion:
			_equipment_panel.modulate = Color.WHITE
			return
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
	if PresentationStyle.reduced_motion:
		toast_label.text = ""
		_toast_panel.hide()
		return
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

func _hint_key(parent: Node, text: String) -> Label:
	var key := PresentationStyle.keycap(parent, text)
	key.add_theme_font_size_override("font_size", 14)
	var style := PresentationStyle.flat(Color(0.035, 0.061, 0.05, 0.44), Color(0.34, 0.39, 0.31, 0.4), 1)
	style.set_content_margin_all(4)
	key.add_theme_stylebox_override("normal", style)
	key.custom_minimum_size = Vector2(32, 28)
	return key
