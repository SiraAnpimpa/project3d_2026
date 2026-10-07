extends RuralEnvironment
## Test-only pre-fix placement, kept outside exports for matched measurement.

func prop(key: String, zone: String, point: Vector2, width: float, yaw: float, solid: bool = false, lift: float = 0, height: float = 0, pitch: float = 0) -> void:
	var info := model_info(key)
	var bounds: AABB = info.bounds
	var scale_factor := height/bounds.size.y if height > 0 else width/maxf(bounds.size.x,bounds.size.z)
	var position := RuralTerrain.ground_point(point.x,point.y,lift)
	var orientation := Basis(Vector3.UP,deg_to_rad(yaw))
	if pitch != 0: orientation *= Basis(Vector3.RIGHT,deg_to_rad(pitch))
	var is_tree := key.begins_with("Tree") or key.begins_with("Pine") or key.begins_with("Dead Tree")
	var ground_cover := key in ["Grass","Tall Grass","Grass Wispy","Clover"]
	var stone := key.begins_with("Rock Medium") or key.begins_with("Pebble")
	var low_plant := key in ["Fern","Bush","Bush with Flowers","Flower Group","Mushroom"]
	var stacked := lift > 0.08
	# Landmarks/furnished shells retain their authored foundation levels. Other assets use
	# actual support vertices and the rendered terrain's triangles, not only the center height.
	if key not in ["Cabin","Water Tower"] and not stacked:
		position.y = SceneryGrounding.surface_height(point)
		if stone or ground_cover or low_plant:
			orientation = SceneryGrounding.slope_basis(point,yaw,0.8 if stone else 1.0,24.0)
		elif not solid and not is_tree and pitch == 0:
			orientation = SceneryGrounding.slope_basis(point,yaw,1.0,12.0)
	var center := Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)
	if is_tree or low_plant or ground_cover:
		# Asymmetric canopies/leaves do not define where the trunk/stem grows from.
		center.x = info.foot_center.x
		center.z = info.foot_center.z
	var normalization := Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*scale_factor),-center*scale_factor)
	var embedding := 0.0
	if key not in ["Cabin","Water Tower"] and not stacked:
		embedding = clampf(bounds.size.y*scale_factor*0.12,0.008,0.30) if stone else 0.025 if is_tree else 0.012 if ground_cover or low_plant else 0.004
		var support: PackedVector3Array = info.vertices if stone or pitch != 0 else info.support
		position.y += SceneryGrounding.contact_adjustment(support,Transform3D(orientation,position)*normalization,embedding)
	var transform := Transform3D(orientation,position)
	if is_tree:
		tree_positions.append(point)
		var cell := Vector2i(floori(point.x/2.0),floori(point.y/2.0))
		if not _trunk_cells.has(cell): _trunk_cells[cell] = []
		_trunk_cells[cell].append(point)
	if key.begins_with("Rock Medium"):
		_stone_footprints.append({"point":point,"radius":maxf(bounds.size.x,bounds.size.z)*scale_factor*0.38})
	if not ground_cover:
		placement_records.append({"asset":key,"zone":zone,"point":point,"transform":transform*normalization,"embedding":embedding,"stacked":stacked,"solid":solid})
	if key in ["Water Tower","Cabin"]:
		# Preserve the landmark's imported scene/material behavior; other static props batch.
		var anchor := Node3D.new()
		anchor.name = key.validate_node_name()
		anchor.transform = transform*normalization
		add_child(anchor)
		var model := (EnvironmentAssets.SCENES[key] as PackedScene).instantiate() as Node3D
		anchor.add_child(model)
		if key == "Cabin": prepare_cabin_model(model)
	else:
		if not _batches.has(key): _batches[key] = []
		_batches[key].append(transform*normalization)
	if not used_assets.has(key): used_assets[key] = {"zones":[],"instances":0,"zone_counts":{}}
	if not used_assets[key].zones.has(zone): used_assets[key].zones.append(zone)
	used_assets[key].instances += 1
	used_assets[key].zone_counts[zone] = used_assets[key].zone_counts.get(zone,0)+1
	if solid: structural_placements.append({"asset":key,"zone":zone,"point":[position.x,position.y,position.z],"width":width,"height":height,"lift":lift,"yaw":yaw})
	if solid and key == "Cabin":
		var faces := PackedVector3Array()
		for part in info.parts:
			# Door leaf/handle and the thin doormat are decorative; the continuous floor is solid.
			if part.name in ["group2096568958","group1499761262","group1971417479"]: continue
			for vertex: Vector3 in part.mesh.get_faces(): faces.append(part.transform*vertex)
		var cabin_shape := ConcavePolygonShape3D.new()
		cabin_shape.set_faces(faces)
		collider("Cabin",transform*normalization,cabin_shape)
	elif solid:
		var shape := BoxShape3D.new()
		shape.size = bounds.size*scale_factor
		# Giant trees use trunk-only collision; the canopy stays clear above walking space.
		if key.begins_with("Tree") or key.begins_with("Dead Tree"):
			trunk(point)
		else:
			collider(zone,transform*Transform3D(Basis.IDENTITY,Vector3.UP*shape.size.y*0.5),shape)

func model_info(key: String) -> Dictionary:
	if _models.has(key): return _models[key]
	var source := (EnvironmentAssets.SCENES[key] as PackedScene).instantiate() as Node3D
	if key == "Cabin": prepare_cabin_model(source)
	var info := {"bounds":GamePresentation.model_bounds(source),"parts":[],"vertices":PackedVector3Array(),"support":PackedVector3Array(),"foot_center":Vector3.ZERO}
	collect_parts(source,Transform3D.IDENTITY,info.parts)
	var unique: Dictionary = {}
	var bottom := INF
	var top := -INF
	for part in info.parts:
		for vertex: Vector3 in part.mesh.get_faces():
			var point: Vector3 = part.transform*vertex
			unique[point] = true
			bottom = minf(bottom,point.y)
			top = maxf(top,point.y)
	for vertex: Vector3 in unique:
		info.vertices.append(vertex)
		if vertex.y <= bottom+(top-bottom)*0.03:
			info.support.append(vertex)
			info.foot_center += vertex
	if not info.support.is_empty(): info.foot_center /= info.support.size()
	source.free()
	_models[key] = info
	return info
