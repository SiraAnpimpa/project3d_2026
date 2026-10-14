extends MeshInstance3D
## Static warning disk samples ground once; it never moves with the attacking boss.
func rebuild(center: Vector3, radius: float, material: Material) -> void:
	top_level = true
	global_position = center
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material_override = material
	var vertices := PackedVector3Array()
	var space := get_world_3d().direct_space_state
	for ring in 4:
		for segment in 48:
			var angle := TAU * segment / 48.0
			var next := TAU * (segment+1) / 48.0
			var points := [Vector2.from_angle(angle)*radius*ring/4.0, Vector2.from_angle(next)*radius*ring/4.0, Vector2.from_angle(angle)*radius*(ring+1)/4.0, Vector2.from_angle(next)*radius*(ring+1)/4.0]
			var sampled: Array[Vector3] = []
			for point in points:
				var origin := center + Vector3(point.x, 1.0, point.y)
				var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(origin, origin-Vector3.UP*8, 1))
				var height := float(hit.position.y) if not hit.is_empty() else RuralTerrain.height_at(origin.x, origin.z)
				sampled.append(Vector3(point.x, height-center.y+0.065, point.y))
			vertices.append_array(PackedVector3Array([sampled[0],sampled[1],sampled[2],sampled[1],sampled[3],sampled[2]]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var shape := ArrayMesh.new()
	shape.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = shape
	show()
