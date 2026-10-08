class_name UiSettingsPanel
extends PanelContainer
## Shared Main Menu/Pause preferences; no game-state ownership.

signal closed
var _graphics: Node
var volume_slider: HSlider
var volume_label: Label
var sensitivity_slider: HSlider
var sensitivity_label: Label
var fullscreen_button: Button
var motion_button: Button
var back_button: Button
var tabs: TabContainer
var categories: UiCategoryTabs
var quality_option: OptionButton
var shadows_button: Button
var render_scale_slider: HSlider
var render_scale_label: Label

func _ready() -> void:
	name = "SettingsPanel"
	_graphics = get_node("/root/GraphicsSettings")
	theme = PresentationStyle.theme()
	PresentationStyle.fit_panel(self, Vector2(600, 552))
	var rows := PresentationStyle.box(self, true, 10)
	var header := PresentationStyle.box(rows, false, 12)
	PresentationStyle.icon(header, UiIcons.get_icon("settings"), 26).modulate = PresentationStyle.GOLD
	PresentationStyle.heading(header, "Settings")
	rows.add_child(HSeparator.new())
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(tabs)
	var general := VBoxContainer.new()
	general.name = "General"
	general.add_theme_constant_override("separation", 12)
	tabs.add_child(general)
	var sound_header := PresentationStyle.box(general, false, 12)
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
	general.add_child(volume_slider)
	var camera_header := PresentationStyle.box(general, false, 12)
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
	general.add_child(sensitivity_slider)
	fullscreen_button = _setting_row(general, "Display", _toggle_fullscreen)
	# Web fullscreen must start during the pressed input event, before release.
	fullscreen_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	get_viewport().size_changed.connect(_update_labels)
	motion_button = _setting_row(general, "UI motion", _toggle_motion)
	_build_graphics()
	categories = UiCategoryTabs.new()
	rows.add_child(categories)
	rows.move_child(categories, tabs.get_index())
	categories.bind(tabs, ["general", "graphics"])
	_graphics.changed.connect(_update_graphics)
	_update_graphics()
	back_button = PresentationStyle.button(rows, "Back  ·  Esc", close, "close")
	back_button.theme_type_variation = "HarvestMenuButton"
	hide()

func _build_graphics() -> void:
	var graphics := VBoxContainer.new()
	graphics.name = "Graphics"
	graphics.add_theme_constant_override("separation", 10)
	tabs.add_child(graphics)
	var quality_row := PresentationStyle.box(graphics, false, 12)
	PresentationStyle.label(quality_row, "Quality preset", 18).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quality_option = OptionButton.new()
	quality_option.custom_minimum_size = Vector2(190, 44)
	for title in ["Low", "Medium", "High"]: quality_option.add_item(title)
	quality_option.tooltip_text = "Low: performance. High: image quality. Resets shadows and resolution."
	quality_option.item_selected.connect(_graphics.set_quality)
	quality_row.add_child(quality_option)
	shadows_button = _setting_row(graphics, "Shadows", func() -> void: _graphics.set_shadows(not _graphics.shadows_enabled))
	var scale_row := PresentationStyle.box(graphics, false, 12)
	PresentationStyle.label(scale_row, "3D resolution", 18).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	render_scale_label = PresentationStyle.label(scale_row, "", 18)
	render_scale_label.modulate = PresentationStyle.SAGE
	render_scale_slider = HSlider.new()
	render_scale_slider.min_value = 0.5
	render_scale_slider.max_value = 1.0
	render_scale_slider.step = 0.05
	render_scale_slider.custom_minimum_size.y = 34
	render_scale_slider.value_changed.connect(_graphics.set_render_scale)
	render_scale_slider.tooltip_text = "Lower values improve performance. UI stays sharp."
	graphics.add_child(render_scale_slider)

func _update_graphics() -> void:
	quality_option.select(_graphics.quality)
	shadows_button.text = "On" if _graphics.shadows_enabled else "Off"
	render_scale_slider.set_value_no_signal(_graphics.render_scale)
	render_scale_label.text = "%d%%" % roundi(_graphics.render_scale * 100)

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
	_update_graphics()
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
