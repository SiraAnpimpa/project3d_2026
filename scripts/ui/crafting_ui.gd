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

@onready var screen: Control = $Screen
@onready var recipe_list: VBoxContainer = %RecipeList
@onready var detail_title: Label = %DetailTitle
@onready var description: Label = %Description
@onready var ingredients: VBoxContainer = %Ingredients
@onready var outputs: Label = %Outputs
@onready var feedback: Label = %Feedback
@onready var craft_button: Button = %Craft


func _ready() -> void:
	screen.hide()
	%Close.pressed.connect(func() -> void: set_open(false))
	craft_button.pressed.connect(_craft_selected)


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
	if value == is_open:
		return
	if value and (crafting == null or player.health.is_dead or inventory_ui.is_open or pause_menu.is_open or get_tree().paused):
		return
	is_open = value
	screen.visible = value
	if value:
		_previous_pause = get_tree().paused
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		refresh()
		if craft_button.disabled:
			%Close.grab_focus()
		else:
			craft_button.grab_focus()
	else:
		get_tree().paused = _previous_pause
		get_viewport().gui_release_focus()
	opened_changed.emit(value)


func _build_recipe_list() -> void:
	for child in recipe_list.get_children():
		child.queue_free()
	_buttons.clear()
	if crafting == null:
		return
	for category in CATEGORY_NAMES.size():
		var heading_added := false
		for recipe in crafting.get_recipes():
			if recipe == null or recipe.category != category:
				continue
			if not heading_added:
				var heading := Label.new()
				heading.text = CATEGORY_NAMES[category]
				heading.add_theme_color_override("font_color", Color(0.75, 0.87, 0.51))
				recipe_list.add_child(heading)
				heading_added = true
			var button := Button.new()
			button.text = recipe.display_name
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.pressed.connect(_select_recipe.bind(recipe))
			recipe_list.add_child(button)
			_buttons[recipe] = button
	if selected_recipe == null and not crafting.get_recipes().is_empty():
		selected_recipe = crafting.get_recipes()[0]


func _select_recipe(recipe: CraftRecipe) -> void:
	selected_recipe = recipe
	refresh()


func refresh() -> void:
	if crafting == null:
		return
	for recipe in _buttons:
		var button: Button = _buttons[recipe]
		button.text = ("> " if recipe == selected_recipe else "  ") + recipe.display_name
		if not crafting.is_unlocked(recipe):
			button.text += "  [LOCKED]"
	for child in ingredients.get_children():
		child.queue_free()
	if selected_recipe == null:
		detail_title.text = "No recipes"
		description.text = ""
		outputs.text = ""
		feedback.text = ""
		craft_button.disabled = true
		return
	detail_title.text = selected_recipe.display_name
	description.text = selected_recipe.description
	for entry in selected_recipe.ingredients:
		if entry == null or entry.item == null:
			continue
		var owned := crafting.inventory.get_item_amount(entry.item.id)
		var required := entry.quantity * selected_recipe.craft_amount
		var label := Label.new()
		label.text = "%s     %d / %d%s" % [entry.item.display_name, owned, required, "  MISSING" if owned < required else ""]
		label.add_theme_color_override("font_color", Color(1.0, 0.56, 0.46) if owned < required else Color(0.9, 0.95, 0.84))
		ingredients.add_child(label)
	var output_names := PackedStringArray()
	for entry in selected_recipe.outputs:
		if entry != null and entry.item != null:
			output_names.append("%s x%d" % [entry.item.display_name, entry.quantity * selected_recipe.craft_amount])
	outputs.text = "Output: " + ", ".join(output_names)
	var reason := crafting.failure_reason(selected_recipe)
	craft_button.disabled = not reason.is_empty()
	feedback.text = reason if not reason.is_empty() else "Ready to craft"


func _craft_selected() -> void:
	var result := crafting.craft(selected_recipe)
	refresh()
	feedback.text = result


func _exit_tree() -> void:
	if is_open:
		get_tree().paused = _previous_pause
