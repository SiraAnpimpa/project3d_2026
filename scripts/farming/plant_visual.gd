class_name PlantVisual
extends Node3D

var data: PlantData
var stage: int = -1

@onready var model_root: Node3D = $ModelRoot
@onready var seed_marker: MeshInstance3D = $SeedMarker
@onready var produce: MeshInstance3D = $Produce


func configure(definition: PlantData) -> void:
	data = definition
	var material := StandardMaterial3D.new()
	material.albedo_color = data.produce_color
	material.roughness = 0.7
	seed_marker.material_override = material
	produce.material_override = material
	set_stage(0)


func set_stage(value: int) -> void:
	if data == null or value == stage:
		return
	stage = clampi(value, 0, data.growth_stages.size() - 1)
	for child in model_root.get_children():
		model_root.remove_child(child)
		child.queue_free()
	var source := data.visual_scene
	if not data.stage_visuals.is_empty() and data.stage_visuals[stage] != null:
		source = data.stage_visuals[stage]
	var model := source.instantiate() as Node3D
	if model != null:
		model_root.add_child(model)
	model_root.scale = Vector3.ONE * data.stage_scales[stage]
	model_root.visible = stage > 0
	seed_marker.visible = stage == 0
	produce.visible = stage == data.growth_stages.size() - 1
