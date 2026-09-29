class_name RecipeEntry
extends Resource

@export var item: ItemData
@export_range(1, 9999) var quantity: int = 1


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if item == null:
		errors.append("Recipe entry is missing ItemData.")
	else:
		errors.append_array(item.validation_errors())
	if quantity <= 0:
		errors.append("Recipe entry quantity must be positive.")
	return errors
