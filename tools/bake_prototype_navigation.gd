extends SceneTree


func _initialize() -> void:
	call_deferred("bake")


func bake() -> void:
	var world: Node3D = load("res://scenes/world/MainWorld.tscn").instantiate()
	root.add_child(world)
	# This solid prop lives outside MainWorld in GameRoot; include its actual scene.
	var station: Node3D = load("res://scenes/interactables/TestInteractable.tscn").instantiate()
	world.add_child(station)
	station.position = Vector3(0, 0, -1)
	await physics_frame
	var mesh := NavigationMesh.new()
	mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	mesh.geometry_collision_mask = 1
	mesh.agent_radius = 0.5
	mesh.agent_height = 1.8
	mesh.agent_max_climb = 0.2
	mesh.cell_size = 0.25
	mesh.cell_height = 0.1
	var source := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(mesh, source, world)
	NavigationServer3D.bake_from_source_geometry_data(mesh, source)
	var result := ResourceSaver.save(mesh, "res://resources/navigation/prototype_navigation.tres")
	print("NAV_BAKE_RESULT polygons=", mesh.get_polygon_count(), " error=", result)
	quit(result)
