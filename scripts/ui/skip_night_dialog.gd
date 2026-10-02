class_name SkipNightDialog
extends CanvasLayer
## Confirmation owns a single pause. The existing GameClock alone advances time.

signal skipped(minutes: float)
var game: Node3D
var is_open := false
var transitioning := false
var action_button: Button
var confirm_button: Button
var cancel_button: Button
var screen: Control
var title: Label
var time_summary: Label
var _opened_day := 0
var _previous_pause := false
var _previous_interactor := true

func bind(root_game: Node3D) -> void:
	game = root_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 25
	action_button = PresentationStyle.button(game.hud.get_node("Root"), "N", request_open, "wait")
	action_button.name = "SkipToNight"
	action_button.theme = PresentationStyle.theme(true)
	action_button.custom_minimum_size = Vector2(62, 44)
	action_button.position = Vector2(232,31)
	action_button.add_theme_font_size_override("font_size",15)
	action_button.focus_mode = Control.FOCUS_NONE
	action_button.tooltip_text = "Press N to review and confirm waiting until 18:00."
	screen = Control.new()
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.theme = PresentationStyle.theme()
	var dim := ColorRect.new()
	dim.color = Color(0.015,0.025,0.025,0.72)
	screen.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.name = "Confirmation"
	var center := CenterContainer.new()
	screen.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.add_child(panel)
	panel.custom_minimum_size = Vector2(580,340)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation",18)
	panel.add_child(rows)
	title = PresentationStyle.label(rows,"Wait until night?",30)
	time_summary = PresentationStyle.label(rows,"",19)
	time_summary.modulate = Color("e9c774")
	var text := PresentationStyle.label(rows,"The night wave begins at 18:00.\nPlants grow during the wait.\n\nHarvest, craft and reload before you leave.\nWaiting does not restore health.",18)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size.x = 532
	text.size_flags_vertical = Control.SIZE_FILL
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation",14)
	rows.add_child(buttons)
	cancel_button = PresentationStyle.button(buttons,"Cancel  ·  Esc",cancel)
	confirm_button = PresentationStyle.button(buttons,"Wait until 18:00",confirm_skip, "wait")
	for button in [cancel_button,confirm_button]: button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_button.focus_neighbor_right = cancel_button.get_path_to(confirm_button)
	confirm_button.focus_neighbor_left = confirm_button.get_path_to(cancel_button)
	screen.hide()
	game.player.health.died.connect(cancel)
	game.waves.completed.connect(cancel)
	_refresh()

func _eligible() -> bool:
	return game != null and game.clock.current_day >= 1 and game.clock.current_day <= 10 and game.clock.is_daytime and not game.clock.paused and game.waves.enabled and game.waves.state == NightWaveManager.State.DAY and not game.player.health.is_dead and not game.rest.is_resting and not game.presentation.ending_started

func can_open() -> bool:
	return not is_open and not transitioning and _eligible() and not get_tree().paused and not game.inventory_ui.is_open and not game.crafting_ui.is_open and not game.pause_menu.is_open and (game.weapons.current == null or not game.weapons.current.is_reloading) and game.player.camera_rig.can_control()

func request_open() -> bool:
	if not can_open(): return false
	_opened_day = game.clock.current_day
	_previous_pause = get_tree().paused
	_previous_interactor = game.player.interactor.enabled
	is_open = true
	game.player.interactor.enabled = false
	game.player.camera_rig.set_menu_open(true)
	get_tree().paused = true
	title.text = "Begin the Final Night?" if _opened_day == 10 else "Wait until night?"
	confirm_button.text = "BEGIN FINAL NIGHT" if _opened_day == 10 else "Wait until 18:00"
	confirm_button.disabled = false
	time_summary.text = "DAY %d / 10     %02d:%02d  →  18:00" % [_opened_day,game.clock.current_hour,game.clock.current_minute]
	screen.show()
	PresentationStyle.appear(screen)
	cancel_button.grab_focus()
	_refresh()
	return true

func cancel() -> void:
	if not is_open: return
	_close()

func confirm_skip() -> void:
	# Revalidate at the commitment point; repeated/stale presses cannot advance again.
	if not is_open or transitioning: return
	if not _eligible() or game.clock.current_day != _opened_day:
		_close()
		return
	transitioning = true
	confirm_button.disabled = true
	var before: float = game.clock.get_elapsed_minutes()
	_close()
	game.clock.skip_to_night()
	skipped.emit(game.clock.get_elapsed_minutes()-before)
	_finish_transition.call_deferred()

func _finish_transition() -> void:
	transitioning = false
	_refresh()

func _close() -> void:
	is_open = false
	screen.hide()
	get_viewport().gui_release_focus()
	get_tree().paused = _previous_pause
	game.player.interactor.enabled = _previous_interactor and not game.player.health.is_dead
	game.player.camera_rig.set_menu_open(false)
	_refresh()

func _process(_delta: float) -> void:
	if is_open and (not _eligible() or game.clock.current_day != _opened_day): cancel()
	_refresh()

func _refresh() -> void:
	if game == null: return
	action_button.visible = game.gameplay_mode.is_farming() and game.player.camera_rig.can_control() and game.clock.is_daytime and game.clock.current_day <= 10 and not game.player.health.is_dead and not game.presentation.ending_started
	action_button.disabled = not can_open()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_to_night"):
		if not event.is_echo(): request_open()
		get_viewport().set_input_as_handled()
	elif is_open:
		if event.is_action_pressed("pause"):
			cancel()
			get_viewport().set_input_as_handled()
		elif event is InputEventKey:
			var navigation := false
			for action in ["ui_accept","ui_up","ui_down","ui_left","ui_right","ui_focus_next","ui_focus_prev"]:
				if event.is_action(action): navigation = true
			if not navigation: get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	if is_open: get_tree().paused = _previous_pause
