class_name ItemData
extends Resource

enum ItemType { SEED, MATERIAL, CONSUMABLE, TOOL, WEAPON, AMMO }

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export_range(1, 9999) var max_stack: int = 99
@export var item_type: ItemType = ItemType.MATERIAL
# Stable ID avoids circular Resource references: PlantData holds seed_item.
@export var plant_id: StringName
@export_group("Seed selection")
@export var plantable: bool = false
@export_range(1, 99) var tier: int = 1
@export_range(0, 9999) var display_order: int = 0


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(id).strip_edges().is_empty():
		errors.append("Item has an empty id.")
	if display_name.strip_edges().is_empty():
		errors.append("Item '%s' needs a display_name." % id)
	if max_stack <= 0:
		errors.append("Item '%s': max_stack must be greater than zero." % id)
	if item_type < ItemType.SEED or item_type > ItemType.AMMO:
		errors.append("Item '%s': unknown item_type." % id)
	if item_type == ItemType.SEED and plant_id == &"":
		errors.append("Seed '%s' needs a plant_id." % id)
	if tier < 1 or display_order < 0:
		errors.append("Item '%s': tier must be positive and display_order nonnegative." % id)
	return errors
