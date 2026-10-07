extends "res://tests/phase_3_integration_test.gd"
## Inspect actual transformed source vertices against the rendered terrain triangles.
## This does not use the placement builder's ground fitting or height sampler.

var terrain_cells: Dictionary = {}
var rows: Array = []
var vertex_cache: Dictionary = {}

func run() -> void:
	set_meta("normal_play",true)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	game.clock.set_process(false)
	var world: Node3D = game.get_node("MainWorld")
	var scenery: RuralEnvironment = world.get_node("RuralEnvironment")
	for spec in [["PlayableTerrain",2.0],["DistantTerrain",4.0],["HorizonTerrain",12.0]]:
		var node := world.get_node("Terrain/"+spec[0]) as MeshInstance3D
		var cells: Dictionary = {}
		var vertices := node.mesh.get_faces()
		for i in range(0,vertices.size(),3):
			var a: Vector3 = node.global_transform*vertices[i]
			var b: Vector3 = node.global_transform*vertices[i+1]
			var c: Vector3 = node.global_transform*vertices[i+2]
			var center := (a+b+c)/3
			var cell := Vector2i(floori(center.x/spec[1]),floori(center.z/spec[1]))
			if not cells.has(cell): cells[cell] = []
			cells[cell].append({"plane":Plane(a,b,c),"polygon":PackedVector2Array([Vector2(a.x,a.z),Vector2(b.x,b.z),Vector2(c.x,c.z)])})
		terrain_cells[spec[1]] = cells
	var placed := 0
	for asset in scenery._models:
		var vertices := PackedVector3Array()
		var unique: Dictionary = {}
		for part in scenery._models[asset].parts:
			for v: Vector3 in part.mesh.get_faces(): unique[part.transform*v] = true
		for v: Vector3 in unique: vertices.append(v)
		vertex_cache[asset] = vertices
	for asset in scenery._models:
		var vertices: PackedVector3Array = vertex_cache[asset]
		var min_y := INF
		var max_y := -INF
		for v in vertices:
			min_y = minf(min_y,v.y)
			max_y = maxf(max_y,v.y)
		var base := PackedVector3Array()
		for v in vertices:
			if v.y <= min_y+(max_y-min_y)*0.03: base.append(v)
		var placements: Array = scenery._batches.get(asset,[])
		if asset in ["Cabin","Water Tower"]: placements = [scenery.get_node(str(asset).validate_node_name()).global_transform]
		for t: Transform3D in placements:
			var gap := INF
			var upper_gap := -INF
			var samples := vertices if str(asset).begins_with("Rock") or str(asset).begins_with("Pebble") else base
			for v in samples:
				var p := t*v
				var separation := p.y-mesh_height(p)
				gap = minf(gap,separation)
				upper_gap = maxf(upper_gap,separation)
			var stacked: bool = asset == "Survival_Wood Log" and t.origin.y > 0.15 and t.origin.x > 0 and t.origin.x < 5 and t.origin.z < -13
			stacked = stacked or (asset in ["Survival_Radio","Survival_First Aid Kit"])
			stacked = stacked or (asset == "Chest-RfSBvgcZUD" and t.origin.y > 0.5)
			rows.append({"asset":asset,"position":[t.origin.x,t.origin.y,t.origin.z],"min_gap":gap,"max_gap":upper_gap,"model_height":scenery._models[asset].bounds.size.y*t.basis.get_scale().y,"supported_stack":stacked})
			placed += 1
	var by_asset: Dictionary = {}
	for row in rows:
		if row.supported_stack: continue
		if not by_asset.has(row.asset): by_asset[row.asset] = {"count":0,"min_contact":INF,"max_contact":-INF,"max_base_gap":-INF}
		var stats: Dictionary = by_asset[row.asset]
		stats.count += 1
		stats.min_contact = minf(stats.min_contact,row.min_gap)
		stats.max_contact = maxf(stats.max_contact,row.min_gap)
		stats.max_base_gap = maxf(stats.max_base_gap,row.max_gap)
	var output := "user://scenery_placement_audit.json"
	var args := OS.get_cmdline_user_args()
	if "--validate" in args:
		validate_placement(world,scenery,by_asset)
	var out_index := args.find("--output")
	if out_index >= 0: output = args[out_index+1]
	var file := FileAccess.open(output,FileAccess.WRITE)
	file.store_string(JSON.stringify({"failures":failures,"placements":placed,"by_asset":by_asset,"rows":rows},"  "))
	print("SCENERY_AUDIT_RESULT failures=",failures," placements=",placed," output=",output)
	quit(1 if failures else 0)

func validate_placement(world: Node3D, scenery: RuralEnvironment, stats: Dictionary) -> void:
	for asset in stats:
		if asset == "Cabin": continue # Native furnished foundation/veranda is checked in cleanup_geometry.
		var entry: Dictionary = stats[asset]
		var stone: bool = str(asset).begins_with("Rock") or str(asset).begins_with("Pebble")
		var tree: bool = str(asset).begins_with("Tree") or str(asset).begins_with("Pine") or str(asset).begins_with("Dead Tree")
		if stone or tree:
			# Whole-footprint embedding supersedes the old single-contact depth.
			# The independent dense collar audit is ground_contact_audit.gd.
			var grounded := true
			for row in rows:
				if row.asset != asset: continue
				var limit: float = row.model_height*(0.65 if stone else 0.15)+0.015
				grounded = grounded and row.min_gap <= 0.001 and row.min_gap >= -limit
				if tree: grounded = grounded and row.max_gap <= 0.005
			check(grounded,asset+" stays rooted with bounded whole-footprint embedding")
		else:
			check(entry.min_contact >= -0.035 and entry.max_contact <= 0.025,asset+" bases have real ground contact without deep burial")
	var closest := INF
	for i in scenery.tree_positions.size():
		for j in range(i+1,scenery.tree_positions.size()):
			closest = minf(closest,scenery.tree_positions[i].distance_to(scenery.tree_positions[j]))
	check(closest >= 2.999,"all tree roots retain at least three metres of spacing")
	print("TREE_SPACING minimum_m=",closest," trees=",scenery.tree_positions.size())
	var tree_records := 0
	var route_intrusions := 0
	for record in scenery.placement_records:
		var asset: String = record.asset
		if not (asset.begins_with("Tree") or asset.begins_with("Pine")): continue
		tree_records += 1
		# Three original individual landmark trees retain their fixed positions.
		if record.zone not in ["Forest edge","Background"]: continue
		if RuralTerrain.trail_distance(record.point) < 4.39: route_intrusions += 1
	check(route_intrusions == 0,"all new tree stands preserve the existing trail corridors")
	check(tree_records > 250,"all foreground/background tree stands are represented in the audit")
	# Actual physical LOS from the open apron to orientation landmarks and interactions.
	var eye := Vector3(0,1.6,6)
	for item in [["home entry",Vector3(-13.5,1.2,-5.5)],["workbench",Vector3(3,1,-7.5)],["water tower",Vector3(-21,9,-18)]]:
		var query := PhysicsRayQueryParameters3D.create(eye,item[1],1)
		var hit := world.get_world_3d().direct_space_state.intersect_ray(query)
		var reaches_landmark := false
		if not hit.is_empty() and item[0] == "water tower":
			# A ray to the tank center is expected to hit the landmark's own box first.
			var point: Vector3 = hit.collider.global_position
			reaches_landmark = Vector2(point.x+21,point.z+18).length() < 0.05
		check(hit.is_empty() or hit.position.distance_to(item[1]) < 0.45 or reaches_landmark,"open apron keeps sightline to "+item[0])
	# Validate stacked source meshes against real lower meshes, never against the terrain.
	for record in scenery.placement_records:
		if not record.stacked: continue
		var asset: String = record.asset
		var vertices: PackedVector3Array = vertex_cache[asset]
		var low := INF
		for vertex in vertices: low = minf(low,vertex.y)
		var contact := INF
		for vertex in vertices:
			if vertex.y > low+0.00001: continue
			var point: Vector3 = record.transform*vertex
			for key in ["Chest","Survival_Wood Log"]:
				for support: Transform3D in scenery._batches[key]:
					if support.is_equal_approx(record.transform): continue
					var faces := PackedVector3Array()
					for part in scenery._models[key].parts:
						for v: Vector3 in part.mesh.get_faces(): faces.append(support*(part.transform*v))
					for i in range(0,faces.size(),3):
						var hit: Variant = Geometry3D.ray_intersects_triangle(point+Vector3.UP*0.1,Vector3.DOWN,faces[i],faces[i+1],faces[i+2])
						if hit == null or hit.y > point.y+0.06: continue
						contact = minf(contact,absf(point.y-hit.y))
		check(contact < 0.065,"stacked "+asset+" rests on an actual lower prop mesh")

func mesh_height(p: Vector3) -> float:
	for step in [2.0,4.0,12.0]:
		var cell := Vector2i(floori(p.x/step),floori(p.z/step))
		if not terrain_cells[step].has(cell): continue
		for triangle in terrain_cells[step][cell]:
			if not Geometry2D.is_point_in_polygon(Vector2(p.x,p.z),triangle.polygon): continue
			var plane: Plane = triangle.plane
			return (plane.d-plane.normal.x*p.x-plane.normal.z*p.z)/plane.normal.y
	return RuralTerrain.height_at(p.x,p.z)
