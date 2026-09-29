class_name RecipeBook
extends Resource

@export var recipes: Array[CraftRecipe] = []


func get_recipe(id: StringName) -> CraftRecipe:
	for recipe in recipes:
		if recipe != null and recipe.recipe_id == id:
			return recipe
	return null


func validation_errors(catalog: ItemCatalog) -> PackedStringArray:
	var errors := PackedStringArray()
	var ids := {}
	if catalog == null:
		errors.append("Recipe book needs an ItemCatalog.")
	if recipes.is_empty():
		errors.append("Recipe book has no recipes.")
	for recipe in recipes:
		if recipe == null:
			errors.append("Recipe book contains a missing recipe.")
			continue
		errors.append_array(recipe.validation_errors())
		if ids.has(recipe.recipe_id):
			errors.append("Duplicate recipe id: '%s'." % recipe.recipe_id)
		ids[recipe.recipe_id] = true
		for group in [recipe.ingredients, recipe.outputs]:
			for entry in group:
				if entry != null and entry.item != null and catalog != null and catalog.get_item(entry.item.id) != entry.item:
					errors.append("Recipe '%s': item '%s' is not the catalog ItemData." % [recipe.recipe_id, entry.item.id])
	return errors
