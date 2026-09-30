class_name WorldPresentation
extends Node3D

var lamps: Array[OmniLight3D] = []

func bind(world: Node3D, clock: GameClock) -> void:
	# Preserve all solid geometry and the baked navigation footprint.
	for label_name in ["FarmLabel", "ShelterLabel", "RescueLabel", "ObstacleLabel"]:
		var label := world.get_node_or_null(label_name) as Label3D
		if label != null: label.hide()
	world.get_node("RescueArea/Mesh").hide()
	for side in ["North", "South", "East", "West"]:
		for step in range(-22, 23, 4):
			var point := Vector3(step, 1.0, -23.8 if side == "North" else 23.8)
			if side in ["East", "West"]: point = Vector3(23.8 if side == "East" else -23.8, 1.0, step)
			box(point, Vector3(0.18, 2, 0.18), Color("66523c"))
	# Low plot edging stays flush with soil and has no physical/nav footprint.
	box(Vector3(-8, 0.03, 0.8), Vector3(12, 0.06, 0.12), Color("b3a078"))
	box(Vector3(-8, 0.03, 8.5), Vector3(12, 0.06, 0.12), Color("b3a078"))
	for x in [-13.9, -2.1]: box(Vector3(x, 0.03, 4.65), Vector3(0.12, 0.06, 7.7), Color("b3a078"))
	# Landing markings are ground decals made from unlit thin meshes.
	for x in [11.8, 14.2]: box(Vector3(x, 0.018, 10), Vector3(0.22, 0.01, 3.8), Color("d9d2a3"))
	box(Vector3(13, 0.02, 10), Vector3(2.6, 0.01, 0.22), Color("d9d2a3"))
	sign_at(Vector3(-13.5, 1.15, 0), "FARM\nGROW / HARVEST")
	sign_at(Vector3(-9, 2.2, -4.1), "SHELTER\nREST AFTER CLEAR")
	sign_at(Vector3(15.8, 0.8, 12.8), "RESCUE\nHOLD FOR 10 NIGHTS")
	for point in [Vector3(-8, 2.2, 0), Vector3(-2, 2.4, -1), Vector3(13, 1.5, 12.8)]:
		var lamp := OmniLight3D.new()
		lamp.position = point
		lamp.light_color = Color("ffe2a2")
		lamp.omni_range = 7
		lamp.shadow_enabled = false
		add_child(lamp)
		lamps.append(lamp)
		box(Vector3(point.x, point.y * 0.5, point.z), Vector3(0.06, point.y, 0.06), Color("514b3d"))
		box(point, Vector3(0.15, 0.2, 0.15), Color("f4d78f"))
	# Trees outside the existing safety walls frame the approach routes without blocking them.
	for point in [Vector3(-26, 0, -18), Vector3(-27, 0, 12), Vector3(26, 0, -13), Vector3(25, 0, 19), Vector3(-16, 0, -26), Vector3(14, 0, -26)]:
		box(point + Vector3.UP * 1.4, Vector3(0.45, 2.8, 0.45), Color("594b38"))
		var mesh := MeshInstance3D.new()
		var crown := CylinderMesh.new()
		crown.top_radius = 0
		crown.bottom_radius = 2.1
		crown.height = 5
		crown.radial_segments = 6
		mesh.mesh = crown
		mesh.position = point + Vector3.UP * 4
		mesh.material_override = material(Color("304e3e"))
		add_child(mesh)
	clock.time_changed.connect(func(_day: int, _hour: int, _minute: int, daytime: bool) -> void:
		for lamp in lamps: lamp.light_energy = 0.1 if daytime else 1.5)
	for lamp in lamps: lamp.light_energy = 0.1

func material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	return mat

func box(point: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = material(color)
	mesh.position = point
	add_child(mesh)

func sign_at(point: Vector3, text: String) -> void:
	box(point, Vector3(2.1, 0.85, 0.08), Color("233b33"))
	var label := Label3D.new()
	label.text = text
	label.position = point + Vector3(0, 0, 0.05)
	label.font_size = 32
	label.pixel_size = 0.007
	label.modulate = Color("f1e5b9")
	add_child(label)
