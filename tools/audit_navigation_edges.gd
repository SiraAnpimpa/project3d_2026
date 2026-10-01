extends SceneTree

func _initialize() -> void:
	var mesh := load("res://resources/navigation/prototype_navigation.tres") as NavigationMesh
	var vertices := mesh.vertices
	var edges: Dictionary = {}
	for p in mesh.get_polygon_count():
		var polygon := mesh.get_polygon(p)
		for i in polygon.size():
			var a: Vector3 = vertices[polygon[i]]
			var b: Vector3 = vertices[polygon[(i+1)%polygon.size()]]
			var sa := str(a)
			var sb := str(b)
			var key := sa+"|"+sb if sa < sb else sb+"|"+sa
			if not edges.has(key): edges[key] = []
			edges[key].append(p)
	var count := 0
	for key in edges:
		if edges[key].size() <= 2: continue
		count += 1
		print("EDGE_AUDIT key=",key," polygons=",edges[key])
		for p in edges[key]:
			var points := PackedVector3Array()
			for v in mesh.get_polygon(p): points.append(vertices[v])
			print("EDGE_AUDIT polygon=",p," vertices=",points)
	print("NAV_EDGE_AUDIT_RESULT failures=",count," overlapping_edges=",count)
	quit(1 if count else 0)
