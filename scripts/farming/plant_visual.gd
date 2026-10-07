class_name PlantVisual
extends Node3D

var data: PlantData
var stage: int = -1
var ambient_particles: GPUParticles3D
var harvest_visual: Node3D

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
	if data.harvest_visual_scene != null:
		harvest_visual = data.harvest_visual_scene.instantiate() as Node3D
		if harvest_visual != null:
			harvest_visual.visible = false
			add_child(harvest_visual)
	if data.ambient_vfx != null:
		ambient_particles = data.ambient_vfx.instantiate() as GPUParticles3D
		if ambient_particles != null:
			add_child(ambient_particles)
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
	var ready_stage := stage == data.growth_stages.size() - 1
	produce.visible = data.show_produce_marker and harvest_visual == null and ready_stage
	if harvest_visual != null: harvest_visual.visible = ready_stage
	if ambient_particles != null:
		ambient_particles.emitting = ready_stage
		ambient_particles.visible = ready_stage
		ambient_particles.amount_ratio = 1.0
		# Scale and height follow this plant's authored growth, not plot/world origin.
		var size := data.stage_scales[stage]
		ambient_particles.scale = Vector3.ONE * size
		ambient_particles.position = data.ambient_vfx_offset * size
