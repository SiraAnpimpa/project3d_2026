class_name PresentationStyle
extends RefCounted

const INK := Color("18271f")
const PAPER := Color("f3eddb")
const MUTED := Color("adb8a6")
const SAGE := Color("bdcf9b")
const GOLD := Color("dbb77e")
const RED := Color("ee9a84")
const TILE := preload("res://Asset/FREE version/Icon set 1/Dark Icons/0.5x/Button  x256.png")
static var _themes: Dictionary = {}
static var _heading_font: FontVariation
static var reduced_motion := false
static var _hud_material: ShaderMaterial

static func heading_font() -> FontVariation:
	if _heading_font == null:
		_heading_font = FontVariation.new()
		_heading_font.base_font = ThemeDB.fallback_font
		_heading_font.variation_embolden = 0.6
		_heading_font.spacing_glyph = 1
	return _heading_font

static func hud_icon(parent: Node, texture: Texture2D, pixels: int = 24) -> TextureRect:
	# A small alpha outline preserves icons on bright terrain without HUD plates.
	if _hud_material == null:
		var shader := Shader.new()
		shader.code = """shader_type canvas_item;
varying vec4 icon_tint;
void vertex() { icon_tint = COLOR; }
void fragment() {
    vec4 source = texture(TEXTURE, UV) * icon_tint;
    vec2 step_size = vec2(length(dFdx(UV)), length(dFdy(UV))) * 1.0;
    float edge = max(max(texture(TEXTURE, UV + vec2(step_size.x, 0.0)).a,
                        texture(TEXTURE, UV - vec2(step_size.x, 0.0)).a),
                    max(texture(TEXTURE, UV + vec2(0.0, step_size.y)).a,
                        texture(TEXTURE, UV - vec2(0.0, step_size.y)).a));
    float halo = edge * 0.8 * icon_tint.a;
    COLOR = vec4(mix(vec3(0.025, 0.04, 0.03), source.rgb, source.a), max(source.a, halo));
}"""
		_hud_material = ShaderMaterial.new()
		_hud_material.shader = shader
	var result := icon(parent, texture, pixels)
	result.material = _hud_material
	return result

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
	style.set_corner_radius_all(6)
	style.set_border_width_all(width)
	style.border_color = border
	style.set_content_margin_all(8)
	return style

static func theme(compact: bool = false) -> Theme:
	if _themes.has(compact): return _themes[compact]
	var result := Theme.new()
	result.default_font = ThemeDB.fallback_font
	result.default_font_size = 18
	result.set_color("font_color", "Label", PAPER)
	result.set_color("font_shadow_color", "Label", Color(0.01, 0.02, 0.015, 0.45))
	result.set_constant("shadow_offset_y", "Label", 1)
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
	for variant in ["PrimaryButton", "HarvestMenuButton", "QuietButton"]:
		result.set_type_variation(variant, "Button")
		for state in colours:
			var style: StyleBox
			if variant == "PrimaryButton":
				var tint := SAGE if state == "normal" else PAPER if state == "hover" else GOLD if state == "pressed" else Color("384135")
				style = surface(tint, 16)
			else:
				var tint := Color(0.3, 0.37, 0.27, 0.35) if state == "hover" else Color(0.09, 0.14, 0.1, 0.65) if state == "pressed" else Color.TRANSPARENT
				style = flat(tint)
				style.set_content_margin_all(12)
			result.set_stylebox(state, variant, style)
		result.set_stylebox("focus", variant, flat(Color.TRANSPARENT, GOLD, 2))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color"]:
		result.set_color(state, "PrimaryButton", INK)
	result.set_color("font_disabled_color", "PrimaryButton", MUTED)
	var panel := flat(Color(0.068, 0.108, 0.084, 0.98), Color(0.66, 0.69, 0.5, 0.4), 1)
	panel.border_width_top = 2
	panel.corner_radius_top_left = 10
	panel.corner_radius_top_right = 10
	panel.set_content_margin_all(26)
	panel.shadow_color = Color(0, 0, 0, 0.2)
	panel.shadow_size = 12
	panel.shadow_offset = Vector2(0, 6)
	result.set_stylebox("panel", "PanelContainer", panel)
	result.set_stylebox("panel", "TooltipPanel", surface(INK, 12))
	result.set_font_size("font_size", "TooltipLabel", 17)
	result.set_stylebox("background", "ProgressBar", flat(Color(0.035, 0.06, 0.04, 0.5), Color(0.02, 0.035, 0.025, 0.85), 1))
	result.set_stylebox("fill", "ProgressBar", flat(SAGE))
	var line := StyleBoxLine.new()
	line.color = Color("455044")
	line.thickness = 1
	result.set_stylebox("separator", "HSeparator", line)
	for track in ["slider", "grabber_area", "grabber_area_highlight"]:
		var style := flat(Color("344232") if track == "slider" else SAGE if track == "grabber_area" else GOLD)
		style.set_content_margin_all(0)
		style.content_margin_top = 3
		style.content_margin_bottom = 3
		result.set_stylebox(track, "HSlider", style)
	result.set_icon("grabber", "HSlider", preload("res://assets/ui/icons/slider_knob.svg"))
	result.set_icon("grabber_highlight", "HSlider", preload("res://assets/ui/icons/slider_knob_active.svg"))
	_themes[compact] = result
	return result

static func eyebrow(parent: Node, text: String) -> Label:
	var result := label(parent, text, 12)
	result.modulate = GOLD
	return result

static func heading(parent: Node, text: String, context: String, size: int = 30) -> Label:
	var rows := box(parent, true, 3)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eyebrow(rows, context)
	return label(rows, text, size)

static func label(parent: Node, text: String, size: int = 18) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", size)
	if size >= 24: result.add_theme_font_override("font", heading_font())
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

static func button(parent: Node, text: String, action: Callable, icon: String = "") -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 44
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
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
	result.add_theme_stylebox_override("normal", flat(Color(0.15, 0.2, 0.16, 0.25), Color(0.56, 0.59, 0.45, 0.45), 1))
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
	shade.color = Color(0.025, 0.04, 0.03, 0.58)
	result.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return result

static func appear(node: Control) -> void:
	if node.has_meta("ui_fade"):
		var old: Tween = node.get_meta("ui_fade")
		if old.is_valid(): old.kill()
	if reduced_motion:
		node.modulate.a = 1.0
		return
	node.modulate.a = 0.0
	var tween := node.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(node, "modulate:a", 1.0, 0.14)
	node.set_meta("ui_fade", tween)

static func guide_content(parent: Node) -> HBoxContainer:
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 36)
	parent.add_child(columns)
	var farm := box(columns, true, 8)
	farm.custom_minimum_size.x = 340
	farm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eyebrow(farm, "01 / CULTIVATE")
	label(farm, "Grow by day", 25).modulate = SAGE
	label(farm, "Plant, harvest, craft.\nStock ammunition before nightfall.", 18)
	farm.add_child(HSeparator.new())
	for row in [["WASD", "Move"], ["Shift", "Sprint"], ["Mouse / arrows", "Look"], ["E", "Plant / harvest / interact"], ["Tab", "Bag and equipment"], ["Wheel", "Select seed or weapon"]]:
		guide_row(farm, row[0], row[1])
	var combat := box(columns, true, 8)
	combat.custom_minimum_size.x = 340
	combat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eyebrow(combat, "02 / HOLD YOUR GROUND")
	label(combat, "Survive the night", 25).modulate = GOLD
	label(combat, "Clear the wave, then rest.\nSurvive ten nights for rescue.", 18)
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
