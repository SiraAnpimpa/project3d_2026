class_name GamePresentation
extends CanvasLayer

var game: Node3D
var ending_started := false
var ending_finished := false
var ending_elapsed := 0.0
var ending_starts := 0
var rescue_camera: Camera3D
var rescue_vehicle: Node3D
var overlay: ColorRect
var caption: Label
var ending_panel: PanelContainer
var rest_fade := 0.0
var _camera_switched := false
var _rescue_origin := Vector3.ZERO

func bind(root_game: Node3D) -> void:
	game = root_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	var screen := Control.new()
	screen.name = "Screen"
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.theme = PresentationStyle.theme()
	overlay = ColorRect.new()
	overlay.color = Color(0.015, 0.025, 0.025, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption = PresentationStyle.label(screen, "", 26)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	caption.offset_left = -440
	caption.offset_right = 440
	caption.offset_top = -100
	caption.offset_bottom = -25
	caption.add_theme_color_override("font_shadow_color", Color.BLACK)
	caption.add_theme_constant_override("shadow_offset_y", 2)
	game.rest.changed.connect(_rest_changed)
	game.waves.morning_started.connect(func(day: int, rested: bool) -> void:
		if not ending_started: game.hud.show_message("Day %d" % day))
	_setup_death_menu()

func _setup_death_menu() -> void:
	var panel: PanelContainer = game.hud.death_panel
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.theme = PresentationStyle.theme()
	panel.get_node("Text").hide()
	panel.offset_left = -260
	panel.offset_right = 260
	panel.offset_top = -196
	panel.offset_bottom = 196
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 14)
	panel.add_child(rows)
	PresentationStyle.icon(rows, UiIcons.get_icon("wave"), 42).modulate = PresentationStyle.RED
	PresentationStyle.label(rows, "Game over", 36).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var summary := PresentationStyle.label(rows, "", 17)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.modulate = PresentationStyle.MUTED
	rows.add_child(HSeparator.new())
	var restart := PresentationStyle.button(rows, "Retry day  ·  R", func() -> void: PresentationStyle.continue_game(get_tree()), "play")
	restart.theme_type_variation = "PrimaryButton"
	restart.name = "Restart"
	var main := PresentationStyle.button(rows, "Main menu", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/MainMenu.tscn"), "rest")
	main.theme_type_variation = "HarvestMenuButton"
	main.name = "MainMenu"
	game.player.health.died.connect(func() -> void:
		summary.text = "Day %d / 10  ·  %02d:%02d" % [mini(game.clock.current_day, 10), game.clock.current_hour, game.clock.current_minute]
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		restart.grab_focus())

func _rest_changed() -> void:
	if ending_started: return
	if game.rest.is_resting: rest_fade = 0.01
	else: rest_fade = -0.45

func start_ending() -> void:
	if ending_started: return
	ending_started = true
	ending_starts += 1
	ending_elapsed = 0
	game.player.health.damage_enabled = false
	game.player.visual.set_motion(false, false)
	game.hud.hide()
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	game.audio.set_ending()
	# Map anchor only: keep sequence timing, UI and state behavior unchanged.
	_rescue_origin = game.get_node("MainWorld/RescueArea").global_position - Vector3.UP*0.05
	rescue_vehicle = Node3D.new()
	rescue_vehicle.name = "RescueHelicopter"
	game.add_child(rescue_vehicle)
	var model := load("res://Asset/Low Poly Military Vehicles-glb/Helicopter.glb").instantiate() as Node3D
	rescue_vehicle.add_child(model)
	var bounds := model_bounds(model)
	var size := maxf(bounds.size.x, bounds.size.z)
	if size > 0:
		rescue_vehicle.scale = Vector3.ONE * (7.0 / size)
		model.position -= Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z)
	rescue_vehicle.hide()
	rescue_camera = Camera3D.new()
	game.add_child(rescue_camera)
	rescue_camera.position = _rescue_origin + Vector3(10, 7, 11)
	rescue_camera.look_at(_rescue_origin + Vector3(-1, 2, 0))
	rescue_camera.fov = 57

static func model_bounds(node: Node3D, parent_transform: Transform3D = Transform3D.IDENTITY) -> AABB:
	var transform := parent_transform * node.transform
	var result := AABB()
	if node is MeshInstance3D: result = transform * node.get_aabb()
	for child in node.get_children():
		if child is Node3D:
			var other := model_bounds(child, transform)
			if other.size != Vector3.ZERO: result = other if result.size == Vector3.ZERO else result.merge(other)
	return result

func _process(delta: float) -> void:
	if not ending_started:
		if rest_fade > 0:
			rest_fade += delta
			overlay.color.a = minf(1, rest_fade / 0.2)
		elif rest_fade < 0:
			rest_fade = minf(0, rest_fade + delta)
			overlay.color.a = -rest_fade / 0.45
		return
	if ending_finished: return
	ending_elapsed += delta
	if ending_elapsed < 0.65:
		overlay.color.a = ending_elapsed / 0.65
		return
	if not _camera_switched:
		_camera_switched = true
		game.audio.start_rescue_sound()
		rescue_camera.make_current()
		game.player.position = _rescue_origin + Vector3(-4, 0.03, 2)
		game.player.visual.rotation.y = 1.9
		rescue_vehicle.show()
	var arrival := clampf((ending_elapsed - 0.65) / 4.2, 0, 1)
	rescue_vehicle.position = (_rescue_origin + Vector3(0, 9, -13)).lerp(_rescue_origin + Vector3(0, 0.2, 0), smoothstep(0, 1, arrival))
	overlay.color.a = maxf(0, 1 - (ending_elapsed - 0.65) / 0.65)
	caption.text = "DAY 11  /  06:00\nRescue is approaching." if arrival < 1 else "Rescue has arrived.\nYou survived ten nights."
	if ending_elapsed > 7: overlay.color.a = minf(1, ending_elapsed - 7)
	if ending_elapsed >= 8: _finish_ending()

func _finish_ending() -> void:
	ending_finished = true
	caption.hide()
	ending_panel = PanelContainer.new()
	ending_panel.name = "EndingPanel"
	$Screen.add_child(ending_panel)
	ending_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	ending_panel.offset_left = -320
	ending_panel.offset_right = 320
	ending_panel.offset_top = -250
	ending_panel.offset_bottom = 250
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 16)
	ending_panel.add_child(rows)
	PresentationStyle.eyebrow(rows, "SOMCHAI’S LAST HARVEST / DAY 11").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	PresentationStyle.icon(rows, UiIcons.item_icon(game.catalog.get_item(&"seed_small_herb")), 60)
	PresentationStyle.label(rows, "YOU SURVIVED\n10 NIGHTS", 42).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(HSeparator.new())
	var again := PresentationStyle.button(rows, "New game", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn"), "play")
	again.theme_type_variation = "PrimaryButton"
	again.name = "PlayAgain"
	var main := PresentationStyle.button(rows, "Main menu", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/MainMenu.tscn"), "rest")
	main.theme_type_variation = "HarvestMenuButton"
	main.name = "MainMenu"
	again.grab_focus()
