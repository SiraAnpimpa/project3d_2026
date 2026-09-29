class_name CraftRecipe
extends Resource

enum Category { AMMO, MEDICINE, WEAPON, UTILITY, DEFENSE, MATERIAL }

@export var recipe_id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var category: Category = Category.MATERIAL
@export var ingredients: Array[RecipeEntry] = []
@export var outputs: Array[RecipeEntry] = []
@export_range(1, 99) var craft_amount: int = 1
@export_range(1, 9999) var unlock_day: int = 1


func is_unlocked(day: int) -> bool:
	return day >= unlock_day


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(recipe_id).strip_edges().is_empty():
		errors.append("Recipe has an empty recipe_id.")
	if display_name.strip_edges().is_empty():
		errors.append("Recipe '%s' needs a display_name." % recipe_id)
	if category < Category.AMMO or category > Category.MATERIAL:
		errors.append("Recipe '%s' has an invalid category." % recipe_id)
	if craft_amount <= 0 or unlock_day <= 0:
		errors.append("Recipe '%s' needs positive craft_amount and unlock_day." % recipe_id)
	if ingredients.is_empty() or outputs.is_empty():
		errors.append("Recipe '%s' needs ingredients and outputs." % recipe_id)
	for group in [ingredients, outputs]:
		var ids := {}
		for entry in group:
			if entry == null:
				errors.append("Recipe '%s' has a missing entry." % recipe_id)
				continue
			errors.append_array(entry.validation_errors())
			if entry.item != null:
				if ids.has(entry.item.id):
					errors.append("Recipe '%s' repeats item '%s' in one list." % [recipe_id, entry.item.id])
				ids[entry.item.id] = true
	return errors
