class_name PresentationStyle
extends RefCounted

const INK := Color("151e1b")
const PAPER := Color("ece5d3")
const MUTED := Color("b3b9ab")
const SAGE := Color("b1c58b")
const GOLD := Color("e2b775")
const RED := Color("ee9a84")
const TILE := preload("res://Asset/FREE version/Icon set 1/Dark Icons/0.5x/Button  x256.png")
static var _themes: Dictionary = {}

static func surface(color: Color = INK, padding: int = 20) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = TILE
	style.modulate_color = color
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 8)
		style.set_content_margin(side, padding)
	# The supplied graphic is imported at32px, with eight-pixel corners.
	return style

static func flat(color: Color, border: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	style.set_border_width_all(width)
	style.border_color = border
	style.set_content_margin_all(8)
	return style

static func theme(compact: bool = false) -> Theme:
	if _themes.has(compact): return _themes[compact]
	var result := Theme.new()
	result.default_font_size = 18
	result.set_color("font_color", "Label", PAPER)
	var colours := {"normal": Color("303b32"), "hover": Color("465540"), "pressed": Color("222e26"), "disabled": Color("202924")}
	for state in colours:
		var style := surface(colours[state], 12)
		style.content_margin_top = 6 if compact else 10
		style.content_margin_bottom = 6 if compact else 10
		result.set_stylebox(state, "Button", style)
	result.set_stylebox("focus", "Button", flat(Color.TRANSPARENT, GOLD, 2))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		result.set_color(state, "Button", PAPER)
	result.set_color("font_disabled_color", "Button", Color("858e82"))
	result.set_color("icon_disabled_color", "Button", Color("7b8476"))
	result.set_constant("h_separation", "Button", 12)
	result.set_stylebox("panel", "PanelContainer", surface(INK, 24))
	result.set_stylebox("panel", "TooltipPanel", surface(INK, 12))
	result.set_font_size("font_size", "TooltipLabel", 17)
	result.set_stylebox("background", "ProgressBar", flat(Color("303b32")))
	result.set_stylebox("fill", "ProgressBar", flat(SAGE))
	var line := StyleBoxLine.new()
	line.color = Color("455044")
	line.thickness = 1
	result.set_stylebox("separator", "HSeparator", line)
	_themes[compact] = result
	return result

static func label(parent: Node, text: String, size: int = 18) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", size)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

static func button(parent: Node, text: String, action: Callable, icon: String = "") -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 44
	result.pressed.connect(action)
	if not icon.is_empty():
		result.icon = UiIcons.get_icon(icon)
		result.expand_icon = true
		result.add_theme_constant_override("icon_max_width", 20)
	parent.add_child(result)
	return result

static func icon(parent: Node, texture: Texture2D, pixels: int = 24) -> TextureRect:
	var result := TextureRect.new()
	result.texture = texture
	result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result.custom_minimum_size = Vector2(pixels, pixels)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

static func keycap(parent: Node, text: String) -> Label:
	var result := label(parent, text, 16)
	result.add_theme_stylebox_override("normal", flat(Color("303b32"), Color("707962"), 1))
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result.custom_minimum_size = Vector2(32, 30)
	return result

static func box(parent: Node, vertical: bool = true, gap: int = 12) -> BoxContainer:
	var result: BoxContainer = VBoxContainer.new() if vertical else HBoxContainer.new()
	result.add_theme_constant_override("separation", gap)
	parent.add_child(result)
	return result

static func center_panel(parent: Control, dimensions: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	parent.add_child(panel)
	fit_panel(panel, dimensions)
	return panel

static func fit_panel(panel: Control, dimensions: Vector2) -> void:
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -dimensions.x / 2
	panel.offset_right = dimensions.x / 2
	panel.offset_top = -dimensions.y / 2
	panel.offset_bottom = dimensions.y / 2

static func screen(parent: Node) -> Control:
	var result := Control.new()
	result.name = "Screen"
	parent.add_child(result)
	result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result.theme = theme()
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.04, 0.03, 0.78)
	result.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return result

static func appear(node: Control) -> void:
	if node.has_meta("ui_fade"):
		var old: Tween = node.get_meta("ui_fade")
		if old.is_valid(): old.kill()
	node.modulate.a = 0.0
	var tween := node.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(node, "modulate:a", 1.0, 0.14)
	node.set_meta("ui_fade", tween)

static func guide_content(parent: Node) -> HBoxContainer:
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 36)
	parent.add_child(columns)
	var farm := box(columns)
	farm.custom_minimum_size.x = 340
	farm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label(farm, "Grow by day", 25).modulate = SAGE
	label(farm, "Plant Lead, Paper and Copper.\nHarvest, then craft Basic Ammo.\nReload before nightfall.", 18)
	farm.add_child(HSeparator.new())
	for row in [["WASD", "Move"], ["Shift", "Sprint"], ["Mouse / arrows", "Look"], ["E", "Plant / harvest / interact"], ["Tab", "Bag and equipment"], ["Wheel", "Select seed or weapon"]]:
		guide_row(farm, row[0], row[1])
	var combat := box(columns)
	combat.custom_minimum_size.x = 340
	combat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label(combat, "Survive the night", 25).modulate = GOLD
	label(combat, "Clear the wave, then rest in the cabin.\nOr hold on until dawn.\nRescue comes after night ten.", 18)
	combat.add_child(HSeparator.new())
	for row in [["Q", "Farming / Combat"], ["RMB / LMB", "Aim / fire or swing bat"], ["R", "Reload rifle"], ["V", "Switch shoulder"], ["N", "Wait until night (confirm)"], ["Esc", "Close / pause"]]:
		guide_row(combat, row[0], row[1])
	return columns

static func guide_row(parent: Node, key: String, action: String) -> void:
	var row := box(parent, false, 12)
	var cap := keycap(row, key)
	cap.custom_minimum_size.x = 130
	label(row, action, 17)

static func go_to(tree: SceneTree, path: String) -> void:
	tree.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if path.ends_with("GameRoot.tscn"): tree.set_meta("normal_play", true)
	tree.change_scene_to_file(path)
