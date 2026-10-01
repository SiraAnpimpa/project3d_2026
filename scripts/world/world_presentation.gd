class_name WorldPresentation
extends Node3D

var lamps: Array[OmniLight3D] = []

func bind(world: Node3D, clock: GameClock) -> void:
	# RuralTerrain and RuralEnvironment own the map; this node owns sparse marks and lights.
	for label_name in ["FarmLabel", "ShelterLabel", "RescueLabel", "ObstacleLabel"]:
		var label := world.get_node_or_null(label_name) as Label3D
		if label != null: label.hide()
	world.get_node("RescueArea/Mesh").hide()
	# Short low markers identify two soil beds without boxing the entire farm.
	for x in [-22.5,-4.4]:
		for z in [2.2,15.0]: box(RuralTerrain.ground_point(x,z,0.25),Vector3(0.12,0.5,0.12),Color("776549"))
	# Relocated landing marks follow the map's single evacuation anchor.
	var landing: Vector3 = world.get_node("RescueArea").global_position - Vector3.UP*0.05
	for x in [-1.2,1.2]: box(landing+Vector3(x,0.018,0),Vector3(0.22,0.01,3.8),Color("d9d2a3"))
	box(landing+Vector3(0,0.02,0),Vector3(2.6,0.01,0.22),Color("d9d2a3"))
	# Redundant freestanding boards removed. Actual interaction prompts remain in their scenes.
	# Yard light clears the entry sightline; workshop light mounts on its existing front post.
	var light_points := [Vector3(-17.6,2.2,-4.2),Vector3(5.75,2.28,-7.6),landing+Vector3(-7,2.4,5)]
	for index in light_points.size():
		var point: Vector3 = light_points[index]
		var lamp := OmniLight3D.new()
		lamp.position = point
		lamp.light_color = Color("ffe2a2")
		lamp.omni_range = 7
		lamp.shadow_enabled = false
		add_child(lamp)
		lamps.append(lamp)
		var ground := RuralTerrain.height_at(point.x,point.z)
		if index != 1:
			box(Vector3(point.x,(point.y+ground)*0.5,point.z),Vector3(0.08,point.y-ground+0.04,0.08),Color("514b3d"))
		else:
			box(point+Vector3(0,0,-0.11),Vector3(0.055,0.08,0.12),Color("514b3d"))
		box(point,Vector3(0.15,0.2,0.15),Color("c6b887"))
		box(point+Vector3.UP*0.12,Vector3(0.22,0.045,0.22),Color("514b3d"))
		box(point-Vector3.UP*0.12,Vector3(0.18,0.035,0.18),Color("514b3d"))
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

