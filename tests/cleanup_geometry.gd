extends "res://tests/phase_3_integration_test.gd"
## Inspect actual generated geometry and physics ground, independently of the builder formulas.

var observations: Array = []
var terrain_exclusions: Array[RID] = []

func run() -> void:
	set_meta("normal_play",true)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	game.clock.paused = true
	var world: Node3D = game.get_node("MainWorld")
	var scenery: RuralEnvironment = world.get_node("RuralEnvironment")
	var terrain := world.get_node("Terrain/TerrainCollision") as StaticBody3D
	for object in game.find_children("*","CollisionObject3D",true,false):
		if object != terrain: terrain_exclusions.append(object.get_rid())
	var workshop: Array[MeshInstance3D] = []
	var depot: Array[MeshInstance3D] = []
	var fence_posts: Array[MeshInstance3D] = []
	var fence_rails: Array[MeshInstance3D] = []
	for child in scenery.get_children():
		var part := child as MeshInstance3D
		if part == null or not part.mesh is BoxMesh: continue
		var size: Vector3 = part.mesh.size
		if part.position.x >= -0.1 and part.position.x <= 6.1 and part.position.z >= -12.8 and part.position.z <= -7.5:
			workshop.append(part)
		elif part.position.x >= 24.8 and part.position.x <= 32.2 and part.position.z >= -19.2 and part.position.z <= -13.5:
			depot.append(part)
		if is_equal_approx(size.x,0.15) and is_equal_approx(size.z,0.15) and size.y > 1.0: fence_posts.append(part)
		if is_equal_approx(size.x,0.12) and is_equal_approx(size.y,0.12) and size.z > 1.5: fence_rails.append(part)
	inspect_frame(world,workshop,"workshop")
	inspect_frame(world,depot,"depot")
	check(fence_posts.size() == 16,"sixteen retained fence posts inspected")
	for post in fence_posts:
		inspect_foot(world,post,"fence")
		var q := PhysicsShapeQueryParameters3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = 0.13
		q.shape = sphere
		q.transform.origin = post.global_position+Vector3.DOWN*0.25
		q.collision_mask = 1
		q.exclude = [terrain.get_rid()]
		check(world.get_world_3d().direct_space_state.intersect_shape(q,1).is_empty(),"fence post clears solid rock/tree/structure at %s" % post.position)
	for rail in fence_rails:
		var a: Vector3 = rail.global_transform*Vector3(0,0,rail.mesh.size.z*0.5)
		var b: Vector3 = rail.global_transform*Vector3(0,0,-rail.mesh.size.z*0.5)
		var attached := 0
		for endpoint in [a,b]:
			for post in fence_posts:
				var bounds: AABB = post.global_transform*post.get_aabb()
				if bounds.grow(0.01).has_point(endpoint):
					attached += 1
					break
		check(attached >= 1,"every fence rail has a real attached end")
		observations.append({"kind":"fence_rail","attached_ends":attached})
	var bench: Node3D = world.get_node("Workbench")
	var tabletop: AABB = bench.get_node("Top").global_transform*bench.get_node("Top").get_aabb()
	for name in ["LegFrontLeft","LegFrontRight","LegBackLeft","LegBackRight"]:
		var leg := bench.get_node(name) as MeshInstance3D
		inspect_foot(world,leg,"bench")
		var bounds: AABB = leg.global_transform*leg.get_aabb()
		check(absf(bounds.end.y-tabletop.position.y) < 0.015,"bench leg connects to tabletop")
	var cabin_floor := scenery.get_node("Cabin").find_child("group1586743875",true,false) as MeshInstance3D
	check(cabin_floor != null,"native continuous Cabin floor retained")
	if cabin_floor != null:
		var bounds: AABB = cabin_floor.global_transform*cabin_floor.get_aabb()
		check(absf(bounds.end.y-0.135) < 0.025,"native veranda surface meets the earth apron without a step gap")
	var rock_instances := 0
	for child in scenery.get_children():
		var batch := child as MultiMeshInstance3D
		if batch == null or not str(batch.name).begins_with("Rock Medium"): continue
		var vertices := batch.multimesh.mesh.get_faces()
		for index in batch.multimesh.instance_count:
			var transform := batch.global_transform*batch.multimesh.get_instance_transform(index)
			var lowest := INF
			var highest := -INF
			for vertex in vertices:
				var point: Vector3 = transform*vertex
				var separation := point.y-RuralTerrain.height_at(point.x,point.z)
				lowest = minf(lowest,separation)
				highest = maxf(highest,separation)
			check(lowest <= 0.08 and highest > 0.15,"placed rock touches earth and retains exposed mass")
			observations.append({"kind":"rock","batch":str(batch.name),"instance":index,"min_ground_separation":lowest,"max_ground_separation":highest})
			rock_instances += 1
	check(rock_instances >= 40,"all dominant and satellite rock meshes inspected")
	for key in ["Survival_Shovel","Survival_Axe"]:
		for placement: Transform3D in scenery._batches[key]:
			var lowest := INF
			for part in scenery._models[key].parts:
				for vertex: Vector3 in part.mesh.get_faces():
					var point: Vector3 = placement*(part.transform*vertex)
					lowest = minf(lowest,point.y-RuralTerrain.height_at(point.x,point.z))
			check(absf(lowest) < 0.025,"static farm/workshop tool blade has real ground contact")
			observations.append({"kind":"tool_foot","asset":key,"min_ground_separation":lowest})
	# Raw instance bounds, not the single world-sized MultiMesh bounds, check visible rotor intrusion.
	var rotor := AABB(Vector3(24.5,1.7,38.5),Vector3(9,4,9))
	var visible_intrusions := 0
	for child in scenery.get_children():
		if child is MultiMeshInstance3D:
			for index in child.multimesh.instance_count:
				var bounds: AABB = child.global_transform*child.multimesh.get_instance_transform(index)*child.multimesh.mesh.get_aabb()
				if rotor.intersects(bounds): visible_intrusions += 1
		elif child is MeshInstance3D:
			var bounds: AABB = child.global_transform*child.get_aabb()
			if rotor.intersects(bounds): visible_intrusions += 1
	check(visible_intrusions == 0,"landing rotor box has no visible prop/canopy intrusion")
	for key in ["Town Sign","Street Light","Street Straight Crack","Rock Path Round Wide","Rock Path Square Thin","RPG_Scythe","RPG_Padlock"]:
		check(not scenery.used_assets.has(key),"removed odd scenery stays absent: "+key)
	check(game.find_children("*","Light3D",true,false).size() == 5,"five existing lights retained")
	var out := FileAccess.open("user://cleanup_geometry.json",FileAccess.WRITE)
	out.store_string(JSON.stringify({"failures":failures,"rock_instances":rock_instances,"fence_posts":fence_posts.size(),"fence_rails":fence_rails.size(),"visible_rotor_intrusions":visible_intrusions,"observations":observations},"  "))
	print("CLEANUP_GEOMETRY_RESULT failures=",failures)
	quit(1 if failures else 0)

func inspect_foot(world: Node3D,part: MeshInstance3D,kind: String) -> void:
	var bounds: AABB = part.global_transform*part.get_aabb()
	var foot := Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)
	var query := PhysicsRayQueryParameters3D.create(foot+Vector3.UP*2,foot-Vector3.UP*8,1)
	query.exclude = terrain_exclusions
	var hit := world.get_world_3d().direct_space_state.intersect_ray(query)
	check(not hit.is_empty(),kind+" support has physical terrain below")
	if hit.is_empty(): return
	var gap: float = foot.y-hit.position.y
	check(gap <= 0.035 and gap >= -0.18,kind+" support touches terrain with only shallow embedding")
	observations.append({"kind":kind+"_foot","point":[foot.x,foot.y,foot.z],"gap":gap})

func inspect_frame(world: Node3D,parts: Array[MeshInstance3D],label: String) -> void:
	var boxes: Array[AABB] = []
	var posts: Array[int] = []
	var roof := -1
	for index in parts.size():
		var part := parts[index]
		var size: Vector3 = part.mesh.size
		boxes.append(part.global_transform*part.get_aabb())
		if size.x > 3 and size.z > 4 and size.y < 0.25: roof = index
		if size.x >= 0.18 and size.x < 0.35 and size.z >= 0.18 and size.z < 0.35 and size.y > 2:
			posts.append(index)
			inspect_foot(world,part,label)
	check(roof >= 0 and posts.size() == 4,label+" has one roof and four grounded corner supports")
	if roof < 0: return
	var connected: Array[int] = [roof]
	var cursor := 0
	while cursor < connected.size():
		var current := connected[cursor]
		for index in parts.size():
			if not connected.has(index) and boxes[current].grow(0.015).intersects(boxes[index]): connected.append(index)
		cursor += 1
	for post in posts: check(connected.has(post),label+" roof/frame connects to every support")
	observations.append({"kind":label+"_frame","parts":parts.size(),"connected_parts":connected.size(),"posts":posts.size()})
