extends "res://tests/phase_3_integration_test.gd"

func run() -> void:
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	game.clock.paused = true
	var world: Node3D = game.get_node("MainWorld")
	var low := INF
	var high := -INF
	var slope := 0.0
	for x in range(-54,55,2):
		for z in range(-54,55,2):
			var h := RuralTerrain.height_at(x,z)
			low = minf(low,h)
			high = maxf(high,h)
			var dx := (RuralTerrain.height_at(x+0.5,z)-RuralTerrain.height_at(x-0.5,z))
			var dz := (RuralTerrain.height_at(x,z+0.5)-RuralTerrain.height_at(x,z-0.5))
			slope = maxf(slope,rad_to_deg(atan(Vector2(dx,dz).length())))
	check(high-low > 5.0 and low < -0.5 and high > 4,"terrain has substantial raised and lowered areas")
	check(slope < 30,"all sampled playable slopes stay below actor/nav limits")
	var mesh: ArrayMesh = world.get_node("Terrain/PlayableTerrain").mesh
	var actual_slope := 0.0
	var vertices := 0
	for i in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(i)
		vertices += arrays[Mesh.ARRAY_VERTEX].size()
		for normal: Vector3 in arrays[Mesh.ARRAY_NORMAL]:
			actual_slope = maxf(actual_slope,rad_to_deg(acos(clampf(normal.y,-1,1))))
	check(actual_slope < 31,"actual collision triangles have gentle slopes below the 45-degree navigation limit")
	for p in [Vector2(0,6),Vector2(-13.5,-3),Vector2(29,43),Vector2(-39,12),Vector2(-10,-37),Vector2(44,-20),Vector2(18,39),Vector2(28,16)]:
		var query := PhysicsRayQueryParameters3D.create(Vector3(p.x,20,p.y),Vector3(p.x,-10,p.y),1)
		var hit := world.get_world_3d().direct_space_state.intersect_ray(query)
		check(not hit.is_empty(),"downward terrain ray has collision at %s" % p)
		if not hit.is_empty(): print("TERRAIN_RAY ",p," y=",hit.position.y," expected=",RuralTerrain.height_at(p.x,p.y))
	var scenery: RuralEnvironment = world.get_node("RuralEnvironment")
	var models := 0
	for entry in scenery.used_assets.values(): models += entry.instances
	var metrics := {"low_m":low,"high_m":high,"sampled_slope_degrees":slope,"triangle_slope_degrees":actual_slope,"sampled_points":3025,"playable_triangles":vertices/3,"unique_assets":scenery.used_assets.size(),"model_placements":models,"nodes":get_node_count(),"mesh_instances":game.find_children("*","MeshInstance3D",true,false).size(),"multi_meshes":game.find_children("*","MultiMeshInstance3D",true,false).size(),"static_bodies":game.find_children("*","StaticBody3D",true,false).size(),"lights":game.find_children("*","Light3D",true,false).size(),"nav_polygons":(world.get_node("NavigationRegion3D") as NavigationRegion3D).navigation_mesh.get_polygon_count()}
	metrics["playable_tree_colliders"] = scenery.playable_tree_colliders
	metrics["grass_zone_counts"] = scenery.grass_counts
	metrics["structural_placements"] = scenery.structural_placements
	var grass := 0
	for number in scenery.grass_counts.values(): grass += number
	metrics["grass_placements"] = grass
	check(grass > 6000,"ground vegetation is substantially denser than the old 100 tufts")
	check(scenery.grass_counts.get("Forest floor",0) > scenery.grass_counts.get("Combat edge",0)*3,"forest floor is denser than the fighting edges")
	for x in [-8.0,0.0,8.0]:
		for z in [-8.0,0.0,8.0]:
			if Vector2(x,z).length() > 8.0: continue
			check(absf(RuralTerrain.height_at(29+x,43+z)-0.65) < 0.01,"helicopter clearing is level across its usable centre")
	var obstacles := PhysicsShapeQueryParameters3D.new()
	var clear_box := BoxShape3D.new()
	clear_box.size = Vector3(9,4,9)
	obstacles.shape = clear_box
	obstacles.transform.origin = Vector3(29,3.7,43)
	obstacles.collision_mask = 1
	check(world.get_world_3d().direct_space_state.intersect_shape(obstacles,1).is_empty(),"rotor volume has no solid tall obstruction")
	var plots := world.get_node("FarmArea").get_children()
	var smallest_gap := INF
	for a in plots:
		for b in plots:
			if a == b: continue
			smallest_gap = minf(smallest_gap,Vector2(a.position.x-b.position.x,a.position.z-b.position.z).length()-1.65)
	metrics["minimum_plot_gap_m"] = smallest_gap
	check(smallest_gap > 2.0,"plot walking lanes exceed two metres")
	print("MAP_METRICS ",JSON.stringify(metrics))
	var out := FileAccess.open("user://beautification_usage.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(scenery.used_assets,"  "))
	var metric_out := FileAccess.open("user://beautification_metrics.json",FileAccess.WRITE)
	metric_out.store_string(JSON.stringify(metrics,"  "))
	print("BEAUTIFICATION_METRICS_RESULT failures=",failures)
	quit(1 if failures else 0)
