class_name PlantData
extends Resource

@export var plant_id: StringName
@export var display_name: String
@export var seed_item: ItemData
@export var harvest_item: ItemData
@export_range(1, 999) var harvest_amount: int = 2
# In-game minutes; 36 minutes is 30 real seconds at the default clock rate.
@export_range(0.1, 14400.0) var growth_minutes: float = 36.0
@export var growth_stages := PackedStringArray(["Seed", "Sprout", "Growing", "Ready"])
@export var stage_thresholds := PackedFloat32Array([0.0, 0.25, 0.65, 1.0])
@export var stage_scales := PackedFloat32Array([0.15, 0.35, 0.7, 1.0])
@export var visual_scene: PackedScene
# Visual-only reward composition, shown exclusively at the final growth stage.
@export var harvest_visual_scene: PackedScene
@export var ambient_vfx: PackedScene
@export var ambient_vfx_offset := Vector3(0, 0.48, 0)
# Optional replacement meshes/scenes for later artwork, one entry per stage.
@export var stage_visuals: Array[PackedScene] = []
@export var produce_color := Color(0.65, 0.75, 0.4)
@export var show_produce_marker: bool = true


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	var prefix := "Plant '%s': " % plant_id
	if plant_id == &"" or display_name.strip_edges().is_empty():
		errors.append(prefix + "plant_id and display_name are required.")
	if seed_item == null:
		errors.append(prefix + "seed_item is missing.")
	elif seed_item.item_type != ItemData.ItemType.SEED or seed_item.plant_id != plant_id:
		errors.append(prefix + "seed_item must be a SEED linked to this plant_id.")
	else:
		errors.append_array(seed_item.validation_errors())
	if harvest_item == null:
		errors.append(prefix + "harvest_item is missing.")
	else:
		errors.append_array(harvest_item.validation_errors())
	if harvest_amount <= 0 or not is_finite(growth_minutes) or growth_minutes <= 0:
		errors.append(prefix + "harvest_amount and growth_minutes must be positive.")
	var count := growth_stages.size()
	if count < 4 or stage_thresholds.size() != count or stage_scales.size() != count:
		errors.append(prefix + "provide at least four matching stages, thresholds and scales.")
	else:
		if stage_thresholds[0] != 0.0 or stage_thresholds[-1] != 1.0:
			errors.append(prefix + "stage thresholds must start at 0 and end at 1.")
		for index in count:
			if not is_finite(stage_thresholds[index]) or not is_finite(stage_scales[index]) or stage_scales[index] <= 0:
				errors.append(prefix + "invalid threshold or nonpositive visual scale.")
			if index > 0 and stage_thresholds[index] <= stage_thresholds[index - 1]:
				errors.append(prefix + "stage thresholds must strictly increase.")
	if visual_scene == null:
		errors.append(prefix + "visual_scene is missing.")
	elif not _is_3d_scene(visual_scene):
		errors.append(prefix + "visual_scene must have a Node3D root.")
	if harvest_visual_scene != null and not _is_3d_scene(harvest_visual_scene):
		errors.append(prefix + "harvest_visual_scene must have a Node3D root.")
	if not stage_visuals.is_empty() and stage_visuals.size() != count:
		errors.append(prefix + "stage_visuals must be empty or match the stage count.")
	for scene in stage_visuals:
		if scene != null and not _is_3d_scene(scene):
			errors.append(prefix + "stage visual must have a Node3D root.")
	return errors


func _is_3d_scene(scene: PackedScene) -> bool:
	var root_type := scene.get_state().get_node_type(0)
	return root_type == &"Node3D" or ClassDB.is_parent_class(root_type, &"Node3D")


func stage_at(progress: float) -> int:
	var stage := 0
	for index in stage_thresholds.size():
		if progress + 0.000001 >= stage_thresholds[index]:
			stage = index
	return stage
