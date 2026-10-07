class_name UiSettingsPanel
extends PanelContainer
## Shared Main Menu/Pause preferences; no game-state ownership.

signal closed
var volume_slider: HSlider
var volume_label: Label
var sensitivity_slider: HSlider
var sensitivity_label: Label
var fullscreen_button: Button
var motion_button: Button
var back_button: Button

func _ready() -> void:
	name = "SettingsPanel"
	theme = PresentationStyle.theme()
	PresentationStyle.fit_panel(self, Vector2(560, 632))
	var rows := PresentationStyle.box(self, true, 14)
	var header := PresentationStyle.box(rows, false, 12)
	PresentationStyle.icon(header, UiIcons.get_icon("settings"), 26).modulate = PresentationStyle.GOLD
	PresentationStyle.heading(header, "Settings", "MAKE YOURSELF AT HOME")
	rows.add_child(HSeparator.new())
	var sound_header := PresentationStyle.box(rows, false, 12)
	PresentationStyle.label(sound_header, "Master volume", 18).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_label = PresentationStyle.label(sound_header, "", 18)
	volume_label.modulate = PresentationStyle.SAGE
	volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.step = 1
	volume_slider.custom_minimum_size.y = 34
	volume_slider.value_changed.connect(_set_volume)
	volume_slider.tooltip_text = "All game audio · left/right adjusts volume"
	rows.add_child(volume_slider)
	var camera_header := PresentationStyle.box(rows, false, 12)
	PresentationStyle.label(camera_header, "Camera Sensitivity", 18).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sensitivity_label = PresentationStyle.label(camera_header, "", 18)
	sensitivity_label.modulate = PresentationStyle.SAGE
	sensitivity_slider = HSlider.new()
	sensitivity_slider.name = "CameraSensitivity"
	sensitivity_slider.min_value = CameraPreferences.MINIMUM
	sensitivity_slider.max_value = CameraPreferences.MAXIMUM
	sensitivity_slider.step = 0.1
	sensitivity_slider.custom_minimum_size.y = 34
	sensitivity_slider.tooltip_text = "Mouse-look multiplier · applies immediately, including aim"
	sensitivity_slider.value_changed.connect(_set_sensitivity)
	rows.add_child(sensitivity_slider)
	var sensitivity_range := PresentationStyle.box(rows, false, 12)
	PresentationStyle.label(sensitivity_range, "Low", 14).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	PresentationStyle.label(sensitivity_range, "High", 14)
	fullscreen_button = _setting_row(rows, "Display", _toggle_fullscreen)
	# Web fullscreen must start during the pressed input event, before release.
	fullscreen_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	get_viewport().size_changed.connect(_update_labels)
	motion_button = _setting_row(rows, "UI motion", _toggle_motion)
	var space := Control.new()
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(space)
	# Fixed short lines avoid autowrap inflating the hidden panel's minimum
	# height while its containers still have zero width on first construction.
	var storage_hint := PresentationStyle.label(rows, "Camera sensitivity is saved.\nOther settings apply this session.", 14)
	storage_hint.modulate = PresentationStyle.MUTED
	back_button = PresentationStyle.button(rows, "Back  ·  Esc", close, "close")
	back_button.theme_type_variation = "HarvestMenuButton"
	hide()

func _setting_row(parent: Node, title: String, callback: Callable) -> Button:
	var row := PresentationStyle.box(parent, false, 16)
	PresentationStyle.label(row, title, 18).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var button := PresentationStyle.button(row, "", callback)
	button.custom_minimum_size.x = 190
	return button

func open() -> void:
	var master := AudioServer.get_bus_index("Master")
	volume_slider.set_value_no_signal(0 if AudioServer.is_bus_mute(master) else roundf(db_to_linear(AudioServer.get_bus_volume_db(master)) * 100))
	volume_label.text = "%d%%" % int(volume_slider.value)
	sensitivity_slider.set_value_no_signal(CameraPreferences.get_sensitivity())
	sensitivity_label.text = "%.1fx" % sensitivity_slider.value
	_update_labels()
	show()
	PresentationStyle.appear(self)
	back_button.grab_focus()

func close() -> void:
	hide()
	closed.emit()

func _set_volume(value: float) -> void:
	var master := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master, value == 0)
	AudioServer.set_bus_volume_db(master, linear_to_db(maxf(0.001, value / 100.0)))
	volume_label.text = "%d%%" % int(value)

func _set_sensitivity(value: float) -> void:
	CameraPreferences.set_sensitivity(value)
	sensitivity_label.text = "%.1fx" % CameraPreferences.get_sensitivity()

func _toggle_fullscreen() -> void:
	var fullscreen := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_update_labels()

func _toggle_motion() -> void:
	PresentationStyle.reduced_motion = not PresentationStyle.reduced_motion
	_update_labels()

func _update_labels() -> void:
	var web := OS.has_feature("web")
	fullscreen_button.text = "Browser controls" if web else ("Fullscreen" if DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN] else "Windowed")
	fullscreen_button.disabled = web or DisplayServer.get_name() == "headless"
	fullscreen_button.tooltip_text = "Use your browser menu for fullscreen." if web else "Toggle windowed / fullscreen."
	motion_button.text = "Reduced" if PresentationStyle.reduced_motion else "Standard"
	motion_button.tooltip_text = "Reduces decorative UI fades. Combat feedback stays visible."
