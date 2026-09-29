class_name ItemCatalog
extends Resource

@export var items: Array[ItemData] = []
@export var plants: Array[PlantData] = []


func get_item(id: StringName) -> ItemData:
	for item in items:
		if item != null and item.id == id:
			return item
	return null


func get_plant(id: StringName) -> PlantData:
	for plant in plants:
		if plant != null and plant.plant_id == id:
			return plant
	return null


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	var item_ids: Array[StringName] = []
	var plant_ids: Array[StringName] = []
	for item in items:
		if item == null:
			errors.append("Catalog contains a missing ItemData.")
			continue
		errors.append_array(item.validation_errors())
		if item.id in item_ids:
			errors.append("Duplicate item id: '%s'." % item.id)
		item_ids.append(item.id)
		if item.item_type == ItemData.ItemType.SEED:
			var plant := get_plant(item.plant_id)
			if plant == null or plant.seed_item != item:
				errors.append("Seed '%s' has no matching PlantData in catalog." % item.id)
	for plant in plants:
		if plant == null:
			errors.append("Catalog contains a missing PlantData.")
			continue
		errors.append_array(plant.validation_errors())
		if plant.plant_id in plant_ids:
			errors.append("Duplicate plant id: '%s'." % plant.plant_id)
		plant_ids.append(plant.plant_id)
		if plant.seed_item != null and get_item(plant.seed_item.id) != plant.seed_item:
			errors.append("Plant '%s': seed_item is not registered in catalog." % plant.plant_id)
		if plant.harvest_item != null and get_item(plant.harvest_item.id) != plant.harvest_item:
			errors.append("Plant '%s': harvest_item is not registered in catalog." % plant.plant_id)
	return errors
