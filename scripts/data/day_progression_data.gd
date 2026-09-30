class_name DayProgressionData
extends Resource

@export var days: Array[DayConfig] = []

func get_day(day: int) -> DayConfig:
	for config in days:
		if config != null and config.day == day: return config
	return null

func validation_errors(catalog: ItemCatalog, book: RecipeBook) -> PackedStringArray:
	var errors := PackedStringArray()
	var seeds := {}
	var recipes := {}
	var seen := {}
	for config in days:
		if config == null:
			errors.append("Null DayConfig")
			continue
		if config.day < 1 or config.day > 10 or seen.has(config.day): errors.append("Invalid/duplicate day")
		seen[config.day] = true
		if config.wave == null: errors.append("Missing wave for Day %d" % config.day)
		else:
			errors.append_array(config.wave.validation_errors())
			if config.wave.day != config.day: errors.append("Wave day mismatch")
		if config.starter_quantity < 0 or config.supply_quantity < 0: errors.append("Negative seed reward")
		for id in config.seed_unlocks:
			var item := catalog.get_item(id)
			if item == null or not item.plantable or item.item_type != ItemData.ItemType.SEED or seeds.has(id): errors.append("Invalid/duplicate seed unlock: %s" % id)
			seeds[id] = true
		for id in config.supply_seed_ids:
			var item := catalog.get_item(id)
			if item == null or item.item_type != ItemData.ItemType.SEED: errors.append("Invalid supply seed: %s" % id)
		for id in config.recipe_unlocks:
			var recipe := book.get_recipe(id)
			if recipe == null or recipes.has(id): errors.append("Invalid/duplicate recipe unlock: %s" % id)
			elif recipe.unlock_day != config.day: errors.append("Recipe unlock day mismatch: %s" % id)
			recipes[id] = true
	for day in range(1, 11):
		if not seen.has(day): errors.append("Missing DayConfig for Day %d" % day)
	return errors
