extends Control

var guide: PanelContainer
var play_button: Button
var help_button: Button
var settings_button: Button
var settings: UiSettingsPanel
var continue_button: Button
var new_game_panel: PanelContainer
var _confirm_new: Button
var _home: VBoxContainer
var _guide_shade: ColorRect

func _ready() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	theme = PresentationStyle.theme()
	var art := TextureRect.new()
	art.texture = preload("res://assets/ui/menu_background.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
	gradient.colors = PackedColorArray([Color(0.035, 0.06, 0.04, 0.97), Color(0.035, 0.06, 0.04, 0.7), Color(0.035, 0.06, 0.04, 0.05)])
	var fade_texture := GradientTexture2D.new()
	fade_texture.gradient = gradient
	var shade := TextureRect.new()
	shade.texture = fade_texture
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_home = PresentationStyle.box(self, true, 12) as VBoxContainer
	_home.custom_minimum_size.x = 484
	PresentationStyle.label(_home, "SOMCHAI’S\nLAST HARVEST", 54)
	PresentationStyle.label(_home, "Grow by day. Survive the night.", 19).modulate = PresentationStyle.MUTED
	if get_tree().has_meta("loading_failed"):
		get_tree().remove_meta("loading_failed")
		PresentationStyle.label(_home, "Could not load the farm. Please try again.", 16)
	var gap := Control.new()
	gap.custom_minimum_size.y = 8
	_home.add_child(gap)
	var checkpoint := get_node("/root/DayCheckpoint")
	continue_button = _menu_button("Continue", func() -> void: PresentationStyle.continue_game(get_tree()), "play")
	continue_button.visible = checkpoint.has_checkpoint()
	continue_button.theme_type_variation = "PrimaryButton"
	continue_button.custom_minimum_size.y = 54
	continue_button.text = "Continue  ·  Day %d" % checkpoint.saved_day()
	continue_button.tooltip_text = "Resume at 06:00 with this morning's inventory."
	play_button = PresentationStyle.button(_home, "New game", _request_new_game, "play")
	play_button.theme_type_variation = "HarvestMenuButton" if continue_button.visible else "PrimaryButton"
	play_button.custom_minimum_size = Vector2(344, 54)
	play_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	play_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	help_button = _menu_button("How to play", _open_guide, "help")
	settings_button = _menu_button("Settings", _open_settings, "settings")
	var quit := _menu_button("Quit", func() -> void: get_tree().quit(), "quit")
	quit.theme_type_variation = "QuietButton"
	resized.connect(_layout_home)
	_layout_home.call_deferred()
	_guide_shade = ColorRect.new()
	_guide_shade.color = Color(0.025, 0.04, 0.03, 0.55)
	add_child(_guide_shade)
	_guide_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_guide_shade.hide()
	guide = PresentationStyle.center_panel(self, Vector2(928, 660))
	guide.name = "Guide"
	var rows := PresentationStyle.box(guide, true, 16)
	rows.name = "Rows"
	PresentationStyle.heading(rows, "How to play")
	PresentationStyle.guide_content(rows)
	var back := PresentationStyle.button(rows, "Back  ·  Esc", _close_guide, "close")
	back.name = "Back"
	back.theme_type_variation = "HarvestMenuButton"
	guide.hide()
	settings = UiSettingsPanel.new()
	add_child(settings)
	settings.closed.connect(_close_settings)
	_build_new_game_confirmation()
	if continue_button.visible: continue_button.grab_focus()
	else: play_button.grab_focus()

func _build_new_game_confirmation() -> void:
	new_game_panel = PresentationStyle.center_panel(self, Vector2(500, 252))
	new_game_panel.name = "NewGameConfirmation"
	var rows := PresentationStyle.box(new_game_panel, true, 18)
	PresentationStyle.heading(rows, "Start a new game?")
	PresentationStyle.label(rows, "This replaces your saved game.", 18).modulate = PresentationStyle.MUTED
	var buttons := PresentationStyle.box(rows, false, 12)
	var cancel := PresentationStyle.button(buttons, "Cancel", _cancel_new_game)
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_confirm_new = PresentationStyle.button(buttons, "New game", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn"), "play")
	_confirm_new.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_confirm_new.theme_type_variation = "PrimaryButton"
	new_game_panel.hide()

func _request_new_game() -> void:
	if not get_node("/root/DayCheckpoint").has_checkpoint():
		PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn")
		return
	_home.hide()
	_guide_shade.show()
	new_game_panel.show()
	PresentationStyle.appear(new_game_panel)
	new_game_panel.find_children("*", "Button", true, false)[0].grab_focus()

func _cancel_new_game() -> void:
	new_game_panel.hide()
	_guide_shade.hide()
	_home.show()
	play_button.grab_focus()

func _menu_button(text: String, callback: Callable, icon: String) -> Button:
	var button := PresentationStyle.button(_home, text, callback, icon)
	button.custom_minimum_size.x = 344
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.theme_type_variation = "HarvestMenuButton"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return button

func _layout_home() -> void:
	_home.size = Vector2(484, _home.get_combined_minimum_size().y)
	_home.position = Vector2(76, maxf(28, (size.y - _home.size.y) / 2))

func _open_guide() -> void:
	_home.hide()
	_guide_shade.show()
	guide.show()
	PresentationStyle.appear(guide)
	guide.get_node("Rows/Back").grab_focus()

func _close_guide() -> void:
	guide.hide()
	_guide_shade.hide()
	_home.show()
	help_button.grab_focus()

func _open_settings() -> void:
	_home.hide()
	_guide_shade.show()
	settings.open()

func _close_settings() -> void:
	_guide_shade.hide()
	_home.show()
	settings_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if new_game_panel.visible:
			_cancel_new_game()
			get_viewport().set_input_as_handled()
		elif settings.visible:
			settings.close()
			get_viewport().set_input_as_handled()
		elif guide.visible:
			_close_guide()
			get_viewport().set_input_as_handled()
