class_name CraftingSystem
extends Node

signal craft_completed(recipe: CraftRecipe)

var progression: ProgressionManager
var inventory: Inventory
var book: RecipeBook
var clock: GameClock
var _busy := false
var crafted_weapon_ids: Dictionary[StringName, bool] = {}


func bind(target_inventory: Inventory, recipe_book: RecipeBook, game_clock: GameClock) -> void:
	inventory = target_inventory
	book = recipe_book
	clock = game_clock


func get_recipes() -> Array[CraftRecipe]:
	if book == null:
		return []
	return book.recipes

func weapon_already_obtained(recipe: CraftRecipe) -> bool:
	if recipe == null: return false
	for entry in recipe.outputs:
		if entry == null or entry.item == null or entry.item.item_type != ItemData.ItemType.WEAPON: continue
		if crafted_weapon_ids.has(entry.item.id) or (inventory != null and inventory.has_item(entry.item.id)): return true
	return false

func get_available_recipes() -> Array[CraftRecipe]:
	return get_recipes().filter(func(recipe: CraftRecipe) -> bool: return recipe != null and not weapon_already_obtained(recipe))


func failure_reason(recipe: CraftRecipe) -> String:
	if inventory == null or book == null or clock == null or recipe == null:
		return "Crafting unavailable"
	if book.get_recipe(recipe.recipe_id) != recipe or not recipe.validation_errors().is_empty():
		return "Invalid recipe"
	if not is_unlocked(recipe):
		return "Recipe Locked (Day %d)" % recipe.unlock_day
	if weapon_already_obtained(recipe):
		return "Weapon already owned or crafted"
	for entry in recipe.ingredients:
		var needed := entry.quantity * recipe.craft_amount
		if not inventory.has_item(entry.item.id, needed):
			return "Not enough %s" % entry.item.display_name
	var removals := _totals(recipe.ingredients, recipe.craft_amount)
	var additions := _totals(recipe.outputs, recipe.craft_amount)
	if not inventory.can_exchange_items(removals, additions):
		return "Inventory Full"
	return ""


func craft(recipe: CraftRecipe) -> String:
	if _busy:
		return "Craft already in progress"
	var reason := failure_reason(recipe)
	if not reason.is_empty():
		return reason
	_busy = true
	var success := inventory.exchange_items(_totals(recipe.ingredients, recipe.craft_amount), _totals(recipe.outputs, recipe.craft_amount))
	_busy = false
	if not success:
		return "Craft failed; inventory unchanged"
	for entry in recipe.outputs:
		if entry.item.item_type == ItemData.ItemType.WEAPON: crafted_weapon_ids[entry.item.id] = true
	craft_completed.emit(recipe)
	var names := PackedStringArray()
	for entry in recipe.outputs:
		names.append("%s x%d" % [entry.item.display_name, entry.quantity * recipe.craft_amount])
	return "Crafted " + ", ".join(names)


func _totals(entries: Array[RecipeEntry], multiplier: int) -> Dictionary:
	var totals := {}
	for entry in entries:
		totals[entry.item] = entry.quantity * multiplier
	return totals


func is_unlocked(recipe: CraftRecipe) -> bool:
	if recipe == null: return false
	if recipe.category == CraftRecipe.Category.WEAPON: return true
	return progression.is_recipe_unlocked(recipe.recipe_id) if progression != null else recipe.is_unlocked(clock.current_day)
