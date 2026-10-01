class_name PresentationStyle
extends RefCounted

const GUIDE := "Grow your supplies. Survive ten nights.\n\n1. Plant Lead, Paper and Copper; harvest when ready.\n2. Use the Workbench to craft Basic Ammo.\n3. Switch to Combat and reload before nightfall.\n4. Clear the night and rest in the shelter, or survive until dawn.\n\nWASD  Move     Shift  Sprint     Mouse / arrows  Look\nE  Interact     Tab  Bag     Q  Farming / Combat\nWheel  Select seed / equipped weapon     V  Switch shoulder\nRMB  Aim rifle     LMB  Fire / swing bat     R  Reload rifle\nN  Wait until night (confirmation)     Esc  Close / Pause\n\nBat: Combat + LMB, no ammo. Special ammo and medicine are craft-only."

static func theme(compact: bool = false) -> Theme:
	var result := Theme.new()
	result.default_font_size = 18
	result.set_color("font_color", "Label", Color("eeeede"))
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("263932") if state == "normal" else Color("3c5443")
		if state == "disabled": style.bg_color = Color("202a28")
		style.set_corner_radius_all(5)
		style.set_content_margin_all(12)
		if compact:
			style.content_margin_top = 5
			style.content_margin_bottom = 5
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.set_border_width_all(2)
			style.border_color = Color("e9c774")
		result.set_stylebox(state, "Button", style)
	result.set_color("font_color", "Button", Color("eeeede"))
	result.set_color("font_disabled_color", "Button", Color("88958d"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.055, 0.09, 0.085, 0.97)
	panel.set_corner_radius_all(10)
	panel.set_content_margin_all(24)
	panel.border_width_top = 2
	panel.border_color = Color("c7ad68")
	result.set_stylebox("panel", "PanelContainer", panel)
	return result

static func label(parent: Node, text: String, size: int = 18) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", size)
	parent.add_child(result)
	return result

static func button(parent: Node, text: String, action: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 44
	result.pressed.connect(action)
	parent.add_child(result)
	return result

static func go_to(tree: SceneTree, path: String) -> void:
	tree.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if path.ends_with("GameRoot.tscn"): tree.set_meta("normal_play", true)
	tree.change_scene_to_file(path)
