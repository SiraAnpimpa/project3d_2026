extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, description: String) -> void:
	if ok: print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func run() -> void:
	var catalog: ItemCatalog = load("res://resources/catalog.tres")
	check(catalog != null and catalog.validation_errors().is_empty(), "complete catalog loads and validates")
	check(catalog.items.size() == 10 and catalog.plants.size() == 5, "five seeds and five materials have unique ids")
	for plant in catalog.plants:
		check(plant.stage_at(0) == 0 and plant.stage_at(0.25) == 1 and plant.stage_at(0.65) == 2 and plant.stage_at(1) == 3, "four stage thresholds: " + plant.display_name)
	var bad_catalog := catalog.duplicate() as ItemCatalog
	bad_catalog.items = catalog.items.duplicate()
	bad_catalog.items.append(catalog.items[0])
	check("Duplicate item id" in " ".join(bad_catalog.validation_errors()), "duplicate item ID diagnosed")
	bad_catalog = catalog.duplicate() as ItemCatalog
	bad_catalog.plants = catalog.plants.duplicate()
	bad_catalog.plants.clear()
	check("no matching PlantData" in " ".join(bad_catalog.validation_errors()), "missing plant link diagnosed")
	var bad_plant := catalog.plants[0].duplicate() as PlantData
	bad_plant.harvest_item = null
	check("harvest_item is missing" in " ".join(bad_plant.validation_errors()), "missing yield resource gives useful diagnostic")
	bad_plant = catalog.plants[0].duplicate() as PlantData
	bad_plant.stage_thresholds = PackedFloat32Array([0, 0.5, 0.4, 1])
	check(not bad_plant.validation_errors().is_empty(), "invalid stage order rejected")
	bad_plant.growth_minutes = 0
	check("must be positive" in " ".join(bad_plant.validation_errors()), "zero growth duration rejected")
	check(catalog.validation_errors().is_empty(), "testing invalid copies does not mutate static definitions")
	print("PHASE_3_DATA_RESULT failures=", failures)
	quit(failures)
