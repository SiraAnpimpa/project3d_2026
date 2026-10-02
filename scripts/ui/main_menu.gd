extends Control

var guide: PanelContainer
var play_button: Button
var help_button: Button
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
	gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	gradient.colors = PackedColorArray([Color(0.035, 0.065, 0.047, 0.96), Color(0.035, 0.065, 0.047, 0.76), Color(0.035, 0.065, 0.047, 0.18)])
	var fade_texture := GradientTexture2D.new()
	fade_texture.gradient = gradient
	var shade := TextureRect.new()
	shade.texture = fade_texture
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_home = PresentationStyle.box(self, true, 16) as VBoxContainer
	_home.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_home.position = Vector2(68, size.y / 2 - 221)
	_home.size = Vector2(430, 442)
	PresentationStyle.label(_home, "SOMCHAI’S\nLAST HARVEST", 49)
	var subtitle := PresentationStyle.label(_home, "Grow by day. Survive ten nights.", 20)
	subtitle.modulate = PresentationStyle.MUTED
	var gap := Control.new()
	gap.custom_minimum_size.y = 10
	_home.add_child(gap)
	play_button = PresentationStyle.button(_home, "Play", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn"), "play")
	play_button.custom_minimum_size.y = 52
	help_button = PresentationStyle.button(_home, "How to play", _open_guide, "help")
	PresentationStyle.button(_home, "Quit", func() -> void: get_tree().quit(), "quit")
	PresentationStyle.label(_home, "Keyboard + mouse", 15).modulate = PresentationStyle.MUTED
	_guide_shade = ColorRect.new()
	_guide_shade.color = Color(0.025, 0.04, 0.03, 0.6)
	add_child(_guide_shade)
	_guide_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_guide_shade.hide()
	guide = PresentationStyle.center_panel(self, Vector2(928, 660))
	var rows := PresentationStyle.box(guide, true, 16)
	rows.name = "Rows"
	PresentationStyle.label(rows, "How to survive", 30)
	PresentationStyle.guide_content(rows)
	PresentationStyle.label(rows, "Bat needs no ammo. Special ammo and medicine are craft-only.", 16).modulate = PresentationStyle.MUTED
	PresentationStyle.button(rows, "Back  ·  Esc", _close_guide, "close").name = "Back"
	guide.hide()
	play_button.grab_focus()

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and guide.visible:
		_close_guide()
		get_viewport().set_input_as_handled()
