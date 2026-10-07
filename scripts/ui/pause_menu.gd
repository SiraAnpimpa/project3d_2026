class_name PauseMenu
extends CanvasLayer

signal opened_changed(is_open: bool)
var is_open := false
var guide: Control
var help_button: Button
var settings_button: Button
var settings: UiSettingsPanel
var _inventory_ui: InventoryUI
var _health: HealthComponent
var _crafting_ui: CraftingUI
var _previous_pause := false
var _web_game: Node3D
var _web_camera: ThirdPersonCamera
var _web_capture_screen: Control
var _web_capture_waiting := false
var _web_previous_pause := false
var _web_had_capture := false

func _ready() -> void:
	var screen := PresentationStyle.screen(self)
	var panel := PresentationStyle.center_panel(screen, Vector2(440, 552))
	panel.name = "Panel"
	var rows := PresentationStyle.box(panel, true, 10)
	rows.name = "Rows"
	PresentationStyle.eyebrow(rows, "SOMCHAI’S FARM / PAUSED").name = "Context"
	PresentationStyle.label(rows, "A moment to rest", 30).name = "Title"
	var hint := PresentationStyle.label(rows, "The farm can wait.", 17)
	hint.name = "Hint"
	hint.modulate = PresentationStyle.MUTED
	var resume := PresentationStyle.button(rows, "Resume  ·  Esc", _resume_from_button, "play")
	resume.theme_type_variation = "PrimaryButton"
	resume.custom_minimum_size.y = 50
	resume.name = "Resume"
	resume.owner = self
	resume.unique_name_in_owner = true
	guide = PresentationStyle.guide_content(rows)
	guide.hide()
	settings_button = PresentationStyle.button(rows, "Settings", _open_settings, "settings")
	settings_button.name = "Settings"
	settings_button.theme_type_variation = "HarvestMenuButton"
	help_button = PresentationStyle.button(rows, "How to play", _toggle_guide, "help")
	help_button.theme_type_variation = "HarvestMenuButton"
	var restart := PresentationStyle.button(rows, "Restart", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/GameRoot.tscn"))
	restart.name = "Restart"
	restart.theme_type_variation = "QuietButton"
	var main := PresentationStyle.button(rows, "Main menu", func() -> void: PresentationStyle.go_to(get_tree(), "res://scenes/main/MainMenu.tscn"), "rest")
	main.name = "MainMenu"
	main.theme_type_variation = "HarvestMenuButton"
	var quit := PresentationStyle.button(rows, "Quit", func() -> void: get_tree().quit(), "quit")
	quit.name = "Quit"
	quit.theme_type_variation = "QuietButton"
	settings = UiSettingsPanel.new()
	screen.add_child(settings)
	settings.closed.connect(_close_settings)
	screen.hide()

func bind(inventory_ui: InventoryUI, health: HealthComponent) -> void:
	_inventory_ui = inventory_ui
	_health = health
	health.died.connect(func() -> void: set_open(false))


func bind_crafting(menu: CraftingUI) -> void:
	_crafting_ui = menu


func _input(event: InputEvent) -> void:
	if _web_capture_waiting:
		if event.is_action_pressed("capture_mouse"):
			_web_camera.capture_mouse_from_gesture()
		elif event.is_action_pressed("pause") and not event.is_echo():
			_finish_web_capture_wait()
			set_open(true)
		# The engagement click must never also shoot, plant, or select HUD items.
		get_viewport().set_input_as_handled()
		return
	if event.is_echo() or not event.is_action_pressed("pause"):
		return
	if is_open and settings.visible:
		settings.close()
		get_viewport().set_input_as_handled()
		return
	if is_open and guide.visible:
		_toggle_guide()
		get_viewport().set_input_as_handled()
		return
	# An open bag owns Esc. Do not open two paused screens with one key event.
	if _inventory_ui == null or _inventory_ui.is_open or _health.is_dead or (_crafting_ui != null and _crafting_ui.is_open):
		return
	if get_tree().paused and not is_open:
		return
	set_open(not is_open)
	get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if value == is_open:
		return
	if value and (_inventory_ui == null or _inventory_ui.is_open or _health.is_dead or (_crafting_ui != null and _crafting_ui.is_open)):
		return
	is_open = value
	$Screen.visible = value
	if value:
		_previous_pause = get_tree().paused
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		PresentationStyle.appear($Screen/Panel)
		%Resume.grab_focus()
	else:
		settings.hide()
		$Screen/Panel.show()
		get_tree().paused = _previous_pause
		get_viewport().gui_release_focus()
	opened_changed.emit(value)


func _exit_tree() -> void:
	if _web_capture_waiting:
		get_tree().paused = _web_previous_pause
	if is_open:
		get_tree().paused = _previous_pause

func _toggle_guide() -> void:
	guide.visible = not guide.visible
	help_button.text = "Back  ·  Esc" if guide.visible else "How to play"
	help_button.icon = UiIcons.get_icon("close" if guide.visible else "help")
	$Screen/Panel/Rows/Title.text = "How to survive" if guide.visible else "A moment to rest"
	for node_name in ["Context", "Resume", "Hint", "Settings", "Restart", "MainMenu", "Quit"]:
		$Screen/Panel/Rows.get_node(node_name).visible = not guide.visible
	PresentationStyle.fit_panel($Screen/Panel, Vector2(928, 632) if guide.visible else Vector2(440, 552))
	help_button.grab_focus()

func _open_settings() -> void:
	$Screen/Panel.hide()
	settings.open()

func _close_settings() -> void:
	$Screen/Panel.show()
	settings_button.grab_focus()


func bind_web_capture(game: Node3D) -> void:
	if not game.player.camera_rig.is_web_build():
		return
	_web_game = game
	_web_camera = game.player.camera_rig
	_web_camera.capture_wait_requested.connect(_begin_web_capture_wait)
	%Resume.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	_web_capture_screen = PresentationStyle.screen(self)
	_web_capture_screen.name = "WebCaptureScreen"
	var panel := PresentationStyle.center_panel(_web_capture_screen, Vector2(444, 220))
	var rows := PresentationStyle.box(panel, true, 12)
	PresentationStyle.eyebrow(rows, "SOMCHAI’S FARM / READY")
	PresentationStyle.label(rows, "Click to return to the farm", 26)
	PresentationStyle.label(rows, "Click anywhere to enable mouse look.\nEsc opens the pause menu.", 17)
	for control: Control in _web_capture_screen.find_children("*", "Control", true, false):
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_web_capture_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_web_capture_screen.hide()


func _resume_from_button() -> void:
	set_open(false)
	if _web_camera != null:
		# The pressed edge is a browser engagement gesture (unlike deferred loading).
		_web_camera.capture_mouse_from_gesture()


func _begin_web_capture_wait() -> void:
	if _web_capture_waiting or not _web_game_ready() or _web_camera._menu_open or _web_camera.has_pointer_capture() or get_tree().paused:
		return
	_web_previous_pause = get_tree().paused
	_web_capture_waiting = true
	_web_had_capture = false
	get_tree().paused = true
	_web_capture_screen.show()
	get_viewport().gui_release_focus()


func _finish_web_capture_wait() -> void:
	if not _web_capture_waiting:
		return
	_web_capture_waiting = false
	_web_capture_screen.hide()
	get_tree().paused = _web_previous_pause


func _web_game_ready() -> bool:
	return is_instance_valid(_web_game) and _web_game.preparation_complete and get_tree().current_scene == _web_game and _web_game.process_mode != Node.PROCESS_MODE_DISABLED and _web_camera._player_alive


func _process(_delta: float) -> void:
	if _web_camera == null:
		return
	_web_camera.sync_web_capture()
	if not _web_game_ready():
		if _web_camera.has_pointer_capture(): _web_camera.release_mouse()
		_finish_web_capture_wait()
		_web_had_capture = false
		return
	if _web_camera._menu_open or (get_tree().paused and not _web_capture_waiting):
		# An asynchronous request may finish after Esc, death or another menu.
		# Never leave a late lock over UI that needs a visible cursor.
		if _web_camera.has_pointer_capture(): _web_camera.release_mouse()
		_web_had_capture = false
		return
	if _web_camera.has_pointer_capture() and _web_camera._window_focused:
		_web_had_capture = true
		_finish_web_capture_wait()
	elif _web_had_capture:
		# Browsers may consume Esc before Godot sees it. Observe the actual unlock.
		_web_had_capture = false
		set_open(true)
	else:
		_begin_web_capture_wait()
