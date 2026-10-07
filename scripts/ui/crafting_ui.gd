class_name CraftingUI
extends CanvasLayer

signal opened_changed(is_open: bool)
const CATEGORY_NAMES := ["AMMO", "MEDICINE", "WEAPON", "UTILITY", "DEFENSE", "MATERIAL"]
var crafting: CraftingSystem
var inventory_ui: InventoryUI
var pause_menu: PauseMenu
var player: PlayerController
var is_open := false
var selected_recipe: CraftRecipe
var _previous_pause := false
var _buttons: Dictionary = {}
var screen: Control
var recipe_list: VBoxContainer
var detail_title: Label
var description: Label
var ingredients: VBoxContainer
var outputs: Label
var feedback: Label
var craft_button: Button
var _close_button: Button
var _preview: VBoxContainer
var _panel: PanelContainer

func _ready() -> void:
	screen = PresentationStyle.screen(self)
	_panel = PresentationStyle.center_panel(screen, Vector2(970, 610))
	var rows := PresentationStyle.box(_panel, true, 16)
	var header := PresentationStyle.box(rows, false, 12)
	PresentationStyle.icon(header, UiIcons.get_icon("workbench"), 26).modulate = PresentationStyle.GOLD
	PresentationStyle.heading(header, "Workbench", "FARM WORKSHOP / MAKE EVERY HARVEST COUNT")
	_close_button = PresentationStyle.button(header, "Esc", func() -> void: set_open(false), "close")
	_close_button.theme_type_variation = "QuietButton"
	rows.add_child(HSeparator.new())
	var columns := PresentationStyle.box(rows, false, 16)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var materials := PresentationStyle.box(columns, true, 14)
	materials.custom_minimum_size.x = 238
	PresentationStyle.label(materials, "MATERIALS", 14).modulate = PresentationStyle.MUTED
	PresentationStyle.label(materials, "OWNED / NEEDED", 12).modulate = PresentationStyle.MUTED
	ingredients = PresentationStyle.box(materials, true, 16) as VBoxContainer
	var recipes := PresentationStyle.box(columns, true, 8)
	recipes.custom_minimum_size.x = 282
	PresentationStyle.label(recipes, "RECIPES", 14).modulate = PresentationStyle.MUTED
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(282, 398)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	recipes.add_child(scroll)
	recipe_list = PresentationStyle.box(scroll, true, 6) as VBoxContainer
	recipe_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var result_panel := PanelContainer.new()
	columns.add_child(result_panel)
	result_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var result_style := PresentationStyle.flat(Color("17281f"), Color("526448"), 1)
	result_style.set_content_margin_all(14)
	result_panel.add_theme_stylebox_override("panel", result_style)
	var result := PresentationStyle.box(result_panel, true, 12)
	result.custom_minimum_size.x = 282
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.move_child(recipes, 0)
	PresentationStyle.label(result, "RESULT", 14).modulate = PresentationStyle.MUTED
	detail_title = PresentationStyle.label(result, "", 26)
	detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview = PresentationStyle.box(result, true, 6) as VBoxContainer
	outputs = PresentationStyle.label(result, "", 26)
	outputs.modulate = PresentationStyle.SAGE
	description = PresentationStyle.label(result, "", 17)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.modulate = PresentationStyle.MUTED
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result.add_child(spacer)
	feedback = PresentationStyle.label(result, "", 17)
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.custom_minimum_size.y = 46
	craft_button = PresentationStyle.button(result, "Craft", _craft_selected, "workbench")
	craft_button.theme_type_variation = "PrimaryButton"
	craft_button.custom_minimum_size.y = 50
	screen.hide()

func bind(system: CraftingSystem, bag: InventoryUI, pause: PauseMenu, actor: PlayerController) -> void:
	crafting = system
	inventory_ui = bag
	pause_menu = pause
	player = actor
	crafting.inventory.inventory_changed.connect(refresh)
	player.health.died.connect(func() -> void: set_open(false))
	_build_recipe_list()
	refresh()

func _input(event: InputEvent) -> void:
	if is_open and not event.is_echo() and event.is_action_pressed("pause"):
		set_open(false)
		get_viewport().set_input_as_handled()

func set_open(value: bool) -> void:
	if value == is_open: return
	if value and (crafting == null or player.health.is_dead or inventory_ui.is_open or pause_menu.is_open or get_tree().paused): return
	is_open = value
	screen.visible = value
	if value:
		_previous_pause = get_tree().paused
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		refresh()
		PresentationStyle.appear(_panel)
		if craft_button.disabled: _close_button.grab_focus()
		else: craft_button.grab_focus()
	else:
		get_tree().paused = _previous_pause
		get_viewport().gui_release_focus()
	opened_changed.emit(value)

func _build_recipe_list() -> void:
	_clear(recipe_list)
	_buttons.clear()
	if crafting == null: return
	for category in CATEGORY_NAMES.size():
		var heading_added := false
		for recipe in crafting.get_recipes():
			if recipe == null or recipe.category != category: continue
			if not heading_added:
				PresentationStyle.label(recipe_list, CATEGORY_NAMES[category], 14).modulate = PresentationStyle.MUTED
				heading_added = true
			var button := PresentationStyle.button(recipe_list, recipe.display_name, _select_recipe.bind(recipe))
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", 28)
			button.add_theme_font_size_override("font_size", 17)
			button.custom_minimum_size.y = 46
			_buttons[recipe] = button
	if selected_recipe == null and not crafting.get_recipes().is_empty(): selected_recipe = crafting.get_recipes()[0]

func _select_recipe(recipe: CraftRecipe) -> void:
	selected_recipe = recipe
	refresh()

func refresh() -> void:
	if crafting == null: return
	for recipe: CraftRecipe in _buttons:
		var button: Button = _buttons[recipe]
		var unlocked := crafting.is_unlocked(recipe)
		button.text = recipe.display_name
		button.icon = UiIcons.item_icon(recipe.outputs[0].item)
		button.add_theme_color_override("icon_normal_color", Color.WHITE if unlocked else Color(0.6, 0.65, 0.6, 0.65))
		button.add_theme_color_override("font_color", PresentationStyle.PAPER if unlocked else PresentationStyle.MUTED)
		button.tooltip_text = recipe.display_name if unlocked else "Unlocks on day %d" % recipe.unlock_day
		button.add_theme_stylebox_override("normal", PresentationStyle.flat(Color("3d4c36") if recipe == selected_recipe else Color(0.16, 0.2, 0.17, 0.55), PresentationStyle.GOLD if recipe == selected_recipe else Color(0.37, 0.43, 0.33, 0.2), 2 if recipe == selected_recipe else 1))
		button.add_theme_stylebox_override("hover", PresentationStyle.flat(Color("46573c"), PresentationStyle.PAPER, 1))
		button.add_theme_stylebox_override("pressed", PresentationStyle.flat(Color("233025"), PresentationStyle.GOLD, 2))
	_clear(ingredients)
	_clear(_preview)
	if selected_recipe == null:
		detail_title.text = "No recipes"
		description.text = ""
		outputs.text = ""
		feedback.text = ""
		craft_button.disabled = true
		return
	detail_title.text = selected_recipe.display_name
	for entry in selected_recipe.ingredients:
		if entry == null or entry.item == null: continue
		var owned := crafting.inventory.get_item_amount(entry.item.id)
		var required := entry.quantity * selected_recipe.craft_amount
		var row := PresentationStyle.box(ingredients, false, 12)
		PresentationStyle.icon(row, UiIcons.item_icon(entry.item), 42)
		var copy := PresentationStyle.box(row, true, 1)
		PresentationStyle.label(copy, entry.item.display_name, 18)
		PresentationStyle.label(copy, "%d / %d" % [owned, required], 22).modulate = PresentationStyle.RED if owned < required else PresentationStyle.SAGE
	var output_names := PackedStringArray()
	for entry in selected_recipe.outputs:
		if entry != null and entry.item != null:
			PresentationStyle.icon(_preview, UiIcons.item_icon(entry.item), 104)
			output_names.append("×%d" % (entry.quantity * selected_recipe.craft_amount) if selected_recipe.outputs.size() == 1 else "×%d %s" % [entry.quantity * selected_recipe.craft_amount, entry.item.display_name])
	outputs.text = "\n".join(output_names)
	description.text = UiIcons.use_text(selected_recipe.outputs[0].item)
	description.tooltip_text = selected_recipe.description
	var reason := crafting.failure_reason(selected_recipe)
	craft_button.disabled = not reason.is_empty()
	feedback.tooltip_text = reason
	feedback.modulate = PresentationStyle.RED if craft_button.disabled else PresentationStyle.SAGE
	if not crafting.is_unlocked(selected_recipe):
		feedback.text = "Unlocks on day %d" % selected_recipe.unlock_day
	elif reason.to_lower().contains("full") or reason.to_lower().contains("space"):
		feedback.text = "Bag full · Make room first"
	elif not reason.is_empty():
		feedback.text = "More materials needed"
	else:
		feedback.text = "Ready to craft"

func _craft_selected() -> void:
	var result := crafting.craft(selected_recipe)
	refresh()
	feedback.text = result
	feedback.modulate = PresentationStyle.SAGE if result.begins_with("Crafted") else PresentationStyle.RED
	PresentationStyle.appear(feedback)

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _exit_tree() -> void:
	if is_open: get_tree().paused = _previous_pause
