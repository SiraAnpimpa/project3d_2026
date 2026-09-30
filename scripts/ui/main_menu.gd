extends Control

var guide: PanelContainer
var play_button: Button
var help_button: Button

func _ready() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	theme = PresentationStyle.theme()
	var backdrop := ColorRect.new()
	backdrop.color = Color("172a29")
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# An original vector farm motif, with no external art dependency.
	var art := TextureRect.new()
	art.texture = load("res://assets/ui/menu_landscape.svg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	panel.position += Vector2(70, -260)
	panel.custom_minimum_size = Vector2(475, 520)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 14)
	panel.add_child(rows)
	PresentationStyle.label(rows, "A FARM. TEN NIGHTS. ONE CHANCE.", 15).modulate = Color("d2b777")
	PresentationStyle.label(rows, "SOMCHAI'S\nLAST HARVEST", 42)
	PresentationStyle.label(rows, "Grow by day. Hold on through the dark.\nRescue arrives after the tenth night.")
	play_button = PresentationStyle.button(rows, "PLAY", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn"))
	help_button = PresentationStyle.button(rows, "HOW TO PLAY", func() -> void: guide.show(); guide.get_node("Rows/Back").grab_focus())
	PresentationStyle.button(rows, "QUIT", func() -> void: get_tree().quit())
	PresentationStyle.label(rows, "SURVIVAL DEMO  /  Keyboard + mouse", 14)
	guide = PanelContainer.new()
	add_child(guide)
	guide.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	guide.position += Vector2(-450, -280)
	guide.custom_minimum_size = Vector2(900, 560)
	var help_rows := VBoxContainer.new()
	help_rows.name = "Rows"
	help_rows.add_theme_constant_override("separation", 15)
	guide.add_child(help_rows)
	PresentationStyle.label(help_rows, "HOW TO SURVIVE", 30)
	PresentationStyle.label(help_rows, PresentationStyle.GUIDE, 18)
	var back := PresentationStyle.button(help_rows, "BACK  [Esc]", _close_guide)
	back.name = "Back"
	guide.hide()
	play_button.grab_focus()

func _close_guide() -> void:
	guide.hide()
	help_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and guide.visible:
		_close_guide()
		get_viewport().set_input_as_handled()
