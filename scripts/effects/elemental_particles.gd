extends GPUParticles3D
## Small mesh particles; no lights, textures or gameplay state.
@export var tint := Color(1, 0.4, 0.08)
@export var drift := Vector3(0, 0.15, 0)
@export var speed := 0.2
@export var mote_size := Vector3(0.025, 0.055, 0.025)
@export var rounded := false
@export var burst := false

func _ready() -> void:
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visibility_range_end = 22.0
	visibility_range_end_margin = 2.0
	local_coords = true
	visibility_aabb = AABB(Vector3(-0.8,-0.5,-0.8), Vector3(1.6,2.0,1.6))
	# Authored scenes carry immutable mesh/motion resources shared by instances.
	# Rebuilding ParticleProcessMaterial per shot caused repeated shader stalls.
	if draw_pass_1 == null or process_material == null: _build_resources()
	if burst:
		local_coords = false
		one_shot = true
		explosiveness = 1.0
		finished.connect(queue_free)
		restart()

func _build_resources() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.albedo_color = Color.WHITE
	if rounded:
		var mesh := SphereMesh.new()
		mesh.radius = mote_size.x * 0.5
		mesh.height = mote_size.y
		mesh.radial_segments = 6
		mesh.rings = 3
		mesh.material = material
		draw_pass_1 = mesh
	else:
		var mesh := BoxMesh.new()
		mesh.size = mote_size
		mesh.material = material
		draw_pass_1 = mesh
	var motion := ParticleProcessMaterial.new()
	motion.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	motion.emission_sphere_radius = 0.2
	motion.direction = Vector3.UP
	motion.spread = 35.0
	motion.initial_velocity_min = speed * 0.5
	motion.initial_velocity_max = speed
	motion.gravity = drift
	motion.angular_velocity_min = -45
	motion.angular_velocity_max = 45
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0,0.15,0.7,1])
	fade.colors = PackedColorArray([Color(tint,0),Color(tint,0.85),Color(tint,0.65),Color(tint,0)])
	var ramp := GradientTexture1D.new()
	ramp.gradient = fade
	motion.color_ramp = ramp
	process_material = motion
	if burst:
		motion.emission_sphere_radius = 0.025
		motion.spread = 75.0
