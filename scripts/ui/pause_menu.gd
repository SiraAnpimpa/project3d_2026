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
	var resume := PresentationStyle.button(rows, "Resume  ·  Esc", func() -> void: set_open(false), "play")
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
