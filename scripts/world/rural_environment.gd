@tool
class_name RuralEnvironment
extends Node3D
## Fixed zone layout, with repeatable variation only inside authored vegetation clusters.
## Static meshes, a few simple colliders, and batched decorative models; no gameplay logic.

var used_assets: Dictionary = {}
var playable_tree_colliders := 0
var grass_counts: Dictionary = {}
var structural_placements: Array = []
var _batches: Dictionary = {}
var _models: Dictionary = {}
var _materials: Dictionary = {}
var _foliage_materials: Dictionary = {}
var _toned_meshes: Dictionary = {}
var wayfinding_points: Array[Vector2] = []
var tree_positions: Array[Vector2] = []
var placement_records: Array = []
var _grass_sites: Dictionary = {}
var _trunk_cells: Dictionary = {}
var _stone_footprints: Array = []
var _fence_sites: Array[Vector2] = []
const FOLIAGE_CELL_SIZE := 32.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 20261001
	build_structures()
	build_clusters()
	build_vegetation()
	build_landscape_details()
	flush_batches()
	for marker in get_parent().get_node("WaveSpawnPoints").get_children():
		marker.position.y = RuralTerrain.height_at(marker.position.x,marker.position.z)+0.1
		# Retained debug helpers describe the real approach, rather than the old arena.
		var old_area := get_parent().get_node_or_null("ZombieSpawnAreas/"+str(marker.name))
		if old_area != null: old_area.position = marker.position
		var debug_marker := get_parent().get_node_or_null(str(marker.name)+"SpawnMarker")
		if debug_marker != null: debug_marker.position = marker.position
		var debug_label := get_parent().get_node_or_null(str(marker.name)+"SpawnLabel")
		if debug_label != null: debug_label.position = marker.position+Vector3.UP*1.2

func build_structures() -> void:
	# Main farm home: supplied Cabin; static open doorway, no door gameplay.
	prop("Cabin","House",Vector2(-12,-10),9.5,0,true,-0.276)
	# The workshop has its own yard across the house's eastern breathing space.
	build_workshop_frame()
	prop("Water Tower","House",Vector2(-21,-18),5.0,10,true,0,12.5)
	# F: recognizable abandoned depot on the raised eastern old field.
	prop("Container Green","Abandoned",Vector2(35,-23),8.5,18,true)
	prop("Container Red","Abandoned",Vector2(43,-23),7.4,65,true)
	prop("Jeep","Abandoned",Vector2(26,-22),4.4,-25,true)
	prop("Ambulance Car","Abandoned",Vector2(41,-32),4.8,15,true)
	build_depot_frame()
	# G: a stopped supply truck supplies the clearing; no isolated asphalt/gateway.
	prop("Truck","Road",Vector2(18,42),5.3,-9,true)
	# E/N: large silhouettes create remembered approach directions and hide entry pockets.
	prop("Tree-qZtx0AHhcy","Forest",Vector2(-31,4),7,10,true,0,11)
	prop("Dead Tree-Mcd2zYqyww","Forest",Vector2(-41,-8),5,25,true,0,8.5)
	rock_cluster(Vector2(-3,-29),4.1,"Ridge",15)
	rock_cluster(Vector2(7,-32),5.8,"Ridge",62)
	rock_cluster(Vector2(-10,-32),4.8,"Ridge",-17)
	rock_cluster(Vector2(-31,11),4.4,"Forest",15)
	for p in [Vector2(38,14),Vector2(44,9),Vector2(-49,-11),Vector2(-48,22),Vector2(2,-50)]:
		rock_cluster(p,4.5,"Boundary",p.x*7)
	# Fence fragments belong to farm edges and the old western pasture, never a perimeter square.
	for z in [3.5,7.8,12.0]: fence(Vector2(-24,z),Vector2(-24,z+2.6),false,true)
	# The two middle pasture fragments intersected the boundary boulder/satellite stones.
	for z in [-22,-7]: fence(Vector2(-50,z),Vector2(-49,z+3.2),true)
	for x in [24,29,34]: fence(Vector2(x,-9),Vector2(x+3.2,-9.5),true)
	# Storage models match the retained bodies relocated into the utility zone.
	prop("Chest","Workshop",Vector2(6.8,-12.5),1.8,0)
	prop("Chest-RfSBvgcZUD","Workshop",Vector2(6.8,-12.5),1.3,0,false,model_height("Chest",1.8))
	prop("Chest","Workshop",Vector2(7.4,-9.5),1.4,0)
	var station := get_parent().get_parent().get_node_or_null("TestInteractable/Mesh")
	if station != null: station.hide()

func build_workshop_frame() -> void:
	# The original footprint/pitched roof remains; a continuous load path finishes the shed.
	var pitch := deg_to_rad(6)
	var front := 3.0-tan(pitch)*2.3-0.08/cos(pitch)
	var back := 3.0+tan(pitch)*2.3-0.08/cos(pitch)
	box("WorkshopWall",Vector3(3,(back-0.2)*0.5,-12.4),Vector3(5.5,back-0.2,0.15),Color("625c49"),true)
	var roof := box("WorkshopRoof",Vector3(3,3.0,-10.1),Vector3(6.0,0.16,5.0),Color("514d40"))
	roof.rotation.x = pitch
	for z in [-7.8,-12.4]:
		var underside: float = front if z == -7.8 else back
		for x in [0.25,5.75]:
			var ground := RuralTerrain.height_at(x,z)
			var top := underside-0.2
			box("WorkshopPost",Vector3(x,(ground-0.06+top)*0.5,z),Vector3(0.2,top-ground+0.06,0.2),Color("6c5b43"),true)
		box("WorkshopEave",Vector3(3,underside-0.1,z),Vector3(5.7,0.2,0.2),Color("6c5b43"))
	for x in [0.25,3.0,5.75]:
		beam("WorkshopRafter",Vector3(x,front-0.075,-7.8),Vector3(x,back-0.075,-12.4),0.15,Color("6c5b43"))
	# Narrow timber seams break up the retained solid back wall without adding obstacles.
	for x in [0.8,1.7,2.6,3.5,4.4,5.3]:
		box("WorkshopBatten",Vector3(x,(back-0.25)*0.5,-12.31),Vector3(0.045,back-0.25,0.035),Color("756952"))

func build_depot_frame() -> void:
	# A roofless left bay and supported surviving right roof read as damage, not unbuilt parts.
	var pitch := deg_to_rad(6)
	var ground := RuralTerrain.height_at(28.5,-19)
	var front := ground+3.7-tan(pitch)*2.5-0.09/cos(pitch)
	var back := ground+3.7+tan(pitch)*2.5-0.09/cos(pitch)
	box("DepotWall",Vector3(28.5,ground+(back-0.22-ground)*0.5,-19),Vector3(7.4,back-0.22-ground,0.22),Color("6c6c57"),true)
	for z in [-14.0,-19.0]:
		var underside: float = front if z == -14.0 else back
		for x in [25.0,32.0]:
			var foot := RuralTerrain.height_at(x,z)-0.06
			box("DepotPost",Vector3(x,(foot+underside-0.22)*0.5,z),Vector3(0.28,underside-0.22-foot,0.28),Color("70654e"),true)
		box("DepotEave",Vector3(28.5,underside-0.11,z),Vector3(7.3,0.22,0.25),Color("70654e"))
	for x in [25.0,28.2,32.0]:
		beam("DepotRafter",Vector3(x,front-0.075,-14),Vector3(x,back-0.075,-19),0.15,Color("70654e"))
	var roof := box("DepotRoof",Vector3(30,ground+3.7,-16.5),Vector3(3.8,0.18,5.6),Color("5e5444"))
	roof.rotation.x = pitch

func model_height(key: String, width: float) -> float:
	var bounds: AABB = model_info(key).bounds
	return bounds.size.y*width/maxf(bounds.size.x,bounds.size.z)

func build_clusters() -> void:
	# A small domestic cache shares the native furnished right room; entry/rest lane stay open.
	prop("Chest","House",Vector2(-10.3,-12.2),1.05,0,true,0)
	var cache_top := model_height("Chest",1.05)
	prop("Survival_Radio","House",Vector2(-10.45,-12.2),0.32,0,false,cache_top)
	prop("Survival_First Aid Kit","House",Vector2(-10.03,-12.2),0.32,-8,false,cache_top)
	# Utility materials: stock against the back wall, tools by the side post.
	prop("Barrel","Workshop",Vector2(5,-11.4),0.72,0,true)
	prop("Chest-RfSBvgcZUD","Workshop",Vector2(3.9,-11.5),0.85,0,true)
	prop("Survival_Gas Can","Workshop",Vector2(4.45,-11.65),0.3,10)
	prop("Survival_Propane Tank","Workshop",Vector2(5.6,-11.4),0.37,0)
	prop("Pallet","Workshop",Vector2(6.6,-14),1.25,-8)
	prop("Survival_Shovel","Workshop",Vector2(0.8,-11.95),0.4,0,false,0,1.7,-12)
	prop("Survival_Axe","Workshop",Vector2(1.35,-12.1),0.4,0,false,0,1.0,-13)
	# Heavy firewood/storage belongs behind the utility shed, not the farm front.
	prop("Barrel","Workshop",Vector2(0.7,-14.0),0.8,0,true)
	prop("Survival_Shovel","Farm",Vector2(-24,3),0.3,0,false,0,1.4)
	var log_diameter := model_height("Survival_Wood Log",1.8)
	var log_spacing := log_diameter*0.94
	for i in 3: prop("Survival_Wood Log","Workshop",Vector2(2.44+(i-1)*log_spacing,-14),1.8,90,false,-0.025)
	var stack_rise := sqrt(log_diameter*log_diameter-pow(log_spacing*0.5,2))
	for i in 2: prop("Survival_Wood Log","Workshop",Vector2(2.44+(i-0.5)*log_spacing,-14),1.8,90,false,stack_rise-0.025)
	# E: an abandoned forester's camp in a distinct clearing.
	prop("Survival_Tent","Forest",Vector2(-34,21),4.4,30,true)
	prop("Survival_Bonfire","Forest",Vector2(-31,20),0.85,0)
	prop("Survival_Can","Forest",Vector2(-30.7,19.5),0.12,0)
	prop("Survival_Can Broken","Forest",Vector2(-31.5,19.5),0.12,80)
	prop("Survival_Wood Log","Forest",Vector2(-32,22.5),2.4,5)
	prop("Dead Tree","Forest",Vector2(-37,25),3.0,15,true,0,6.0)
	# F: damaged lounge, discarded tires and materials tell a depot evacuation story.
	prop("Damaged Couch","Abandoned",Vector2(28,-16),2.2,-20,true)
	prop("Wheels Stack","Abandoned",Vector2(32,-21),1.0,0,true)
	prop("Wheel","Abandoned",Vector2(31.1,-21.2),0.52,68)
	prop("Pallet Broken","Abandoned",Vector2(32.8,-17.7),1.45,-17)
	prop("Pipes","Abandoned",Vector2(32.5,-18.4),1.7,-3)
	prop("Trash Bags","Abandoned",Vector2(36,-19),1.1,0)
	prop("Trash Bag","Abandoned",Vector2(37,-19),0.6,60)
	prop("Cinder Block","Abandoned",Vector2(26.7,-17),0.42,-7)
	prop("Fire Hydrant","Abandoned",Vector2(44,-28),0.45,0)
	prop("Traffic Barrier","Abandoned",Vector2(40,-11),3.4,-10,true)
	# A grouped aid/radio cache stays next to the truck, outside rotor clearance.
	prop("Survival_Gas Can","Road",Vector2(18,39),0.35,15)
	prop("Chest","Road",Vector2(19,39),0.9,15)
	var aid_top := model_height("Chest",0.9)
	prop("Survival_Radio","Rescue",Vector2(19.2,39),0.32,0,false,aid_top)
	prop("Survival_First Aid Kit","Rescue",Vector2(18.8,39),0.32,0,false,aid_top)
	for point in [Vector2(23.5,39),Vector2(34.5,39),Vector2(23.5,47),Vector2(34.5,47)]:
		prop("Traffic Cone","Rescue",point,0.4,0)
	# Dry drainage remains natural ground: detached paving samples/pipe bundle removed.

func build_vegetation() -> void:
	var clusters := [
		[Vector2(-40,0),10.0,19],[Vector2(-45,26),12.0,15],[Vector2(-35,-22),8.0,13],
		[Vector2(-51,-35),8.0,12],[Vector2(48,-8),10.0,16],[Vector2(49,25),10.0,15],
		[Vector2(-28,-50),10.0,14],[Vector2(9,-49),9.0,15],[Vector2(34,-51),8.0,11],
		[Vector2(-72,-42),16.0,18],[Vector2(-76,15),14.0,18],[Vector2(-61,65),14.0,17],
		[Vector2(0,-80),17.0,22],[Vector2(51,-73),17.0,22],[Vector2(83,-21),16.0,20],
		[Vector2(74,49),18.0,22],[Vector2(32,83),17.0,22]
	]
	var trees := ["Tree","Tree-qZtx0AHhcy","Tree-aVOxaHRPWe","Tree-QVOop92WmG","Pine","Pine-699sFuLCN2","Pine-79gmlLnweB"]
	for cluster_index in clusters.size():
		var cluster: Array = clusters[cluster_index]
		var center: Vector2 = cluster[0]
		var radius: float = cluster[1]
		for i in cluster[2]:
			var point := center
			var accepted := false
			for attempt in 32:
				# Three loose stands have different edges and gaps; never regular tree rows.
				var stand_angle: float = cluster_index*1.71+(i%3)*2.15
				var stand := center+Vector2(cos(stand_angle),sin(stand_angle))*radius*0.37
				var angle := rng.randf()*TAU
				var distance := sqrt(rng.randf())*radius*0.72
				point = stand+Vector2(cos(angle),sin(angle))*distance
				if not tree_site_allowed(point): continue
				accepted = true
				break
			if not accepted: continue
			var key: String = trees[(cluster_index+i%3)%4] if center.x < 0 and i%5 != 0 else trees[4+(cluster_index+i%2)%3]
			var background := maxf(absf(point.x),absf(point.y)) > RuralTerrain.PLAY_HALF
			var edge := clampf(point.distance_to(center)/radius,0.0,1.0)
			var height := lerpf(10.2,7.2,edge)*rng.randf_range(0.88,1.10)
			prop(key,"Background" if background else "Forest edge",point,4.5,rng.randf()*360,false,0,height)
			if not background: trunk(point)
			if not background:
				var angle := rng.randf()*TAU
				var bush_point := point+Vector2(cos(angle),sin(angle))*rng.randf_range(1.6,2.2)
				if understorey_allowed(bush_point,0.9): prop("Bush with Flowers","Forest edge",bush_point,rng.randf_range(0.95,1.65),rng.randf()*360)
				var fern_point := point+Vector2(cos(angle+1.1),sin(angle+1.1))*1.2
				if understorey_allowed(fern_point,0.4): prop("Fern","Forest edge",fern_point,rng.randf_range(0.5,0.8),rng.randf()*360)
				grass_patch(point+Vector2(1.2,1.6),Vector2(2.0,1.6),14,"Forest floor",0.45,0.85)
	# Fixed meadow/forest patches have dense, thinner and empty intervals.
	# One batch per existing mesh variant; no per-blade scene nodes or grass collision.
	var patches := [
		[Vector2(-29,20),Vector2(8,7),330,"Meadow"],[Vector2(-17,24),Vector2(6,5),260,"Meadow"],
		[Vector2(-5,26),Vector2(8,6),380,"Meadow"],[Vector2(-20,-2),Vector2(5,4),150,"Yard edge"],
		[Vector2(-20,-21),Vector2(8,7),360,"Meadow"],[Vector2(-7,-21),Vector2(7,6),280,"Meadow"],
		[Vector2(12,-17),Vector2(8,7),330,"Meadow"],[Vector2(14,-3),Vector2(6,5),210,"Combat edge"],
		[Vector2(1,6),Vector2(5,4),130,"Combat edge"],[Vector2(12,15),Vector2(8,7),280,"Combat edge"],
		[Vector2(23,12),Vector2(7,6),330,"Meadow"],[Vector2(36,11),Vector2(7,7),330,"Meadow"],
		[Vector2(35,26),Vector2(6,5),300,"Meadow"],[Vector2(3,41),Vector2(9,8),390,"Meadow"],
		[Vector2(-11,40),Vector2(11,9),550,"Meadow"],[Vector2(-27,36),Vector2(7,6),420,"Forest floor"],
		[Vector2(-22,-36),Vector2(7,6),410,"Forest floor"],[Vector2(14,-38),Vector2(7,6),410,"Meadow"],
		[Vector2(26,-38),Vector2(7,6),420,"Forest floor"],[Vector2(46,-36),Vector2(7,6),490,"Forest floor"],
		[Vector2(43,-1),Vector2(7,6),470,"Forest floor"],[Vector2(44,27),Vector2(8,7),520,"Forest floor"],
		[Vector2(-42,35),Vector2(9,8),630,"Forest floor"],[Vector2(-46,0),Vector2(11,9),740,"Forest floor"],
		[Vector2(-39,-27),Vector2(8,7),560,"Forest floor"],[Vector2(-36,-43),Vector2(9,7),560,"Forest floor"],
		[Vector2(-51,46),Vector2(8,6),470,"Wilderness"],[Vector2(-16,51),Vector2(10,5),470,"Wilderness"],
		[Vector2(40,51),Vector2(10,5),470,"Wilderness"]
	]
	for patch in patches:
		var zone: String = patch[3]
		var short_grass := zone in ["Combat edge","Yard edge"]
		grass_patch(patch[0],patch[1],patch[2],zone,0.23 if short_grass else 0.45,0.4 if short_grass else 0.85)
	# Sparse short growth along farm soil edges and the yard; active beds stay bare.
	for center in [Vector2(-22.4,6),Vector2(-22.6,12),Vector2(-4.0,12),Vector2(-11,16.4),Vector2(-18,1),Vector2(-8,-2)]:
		grass_patch(center,Vector2(2.8,1.8),40,"Yard edge",0.16,0.28)
	# Reclamation follows unused depot corners; the central bay and vehicle silhouettes stay open.
	for item in [[Vector2(34.0,-28.3),1.0,24.0],[Vector2(34.9,-29.1),0.75,137.0],[Vector2(38.0,-27.2),1.25,78.0],[Vector2(38.7,-28.0),0.8,219.0],[Vector2(45.5,-24.5),0.9,311.0],[Vector2(46.2,-25.7),1.15,43.0]]:
		prop("Bush" if item[1] < 1.0 else "Bush with Flowers","Abandoned",item[0],item[1],item[2])
	for item in [[Vector2(-36.3,23.1),0.22,14.0],[Vector2(-36.7,23.5),0.32,120.0],[Vector2(-32.9,24.7),0.25,211.0],[Vector2(-32.3,25.2),0.40,54.0],[Vector2(-29.8,23.3),0.28,300.0]]:
		prop("Mushroom" if item[1] < 0.3 else "Flower Group","Forest",item[0],item[1],item[2])
	var road_stones := [Vector2(12.2,25.7),Vector2(13.5,27.1),Vector2(16.4,31.8),Vector2(17.9,32.6),Vector2(19.2,31.0),Vector2(21.3,38.6),Vector2(23.1,39.2),Vector2(22.6,40.4)]
	for i in road_stones.size():
		prop("Pebble Round" if i%2 else "Pebble Square","Road",road_stones[i],0.45+(i%3)*0.09,i*65)
	# Roadside outcrop belongs to the reveal shoulder and screens the southern entry.
	rock_cluster(Vector2(10,31),3.5,"Road shoulder",-20)

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
			orientation = SceneryGrounding.slope_basis(point,yaw,1.0 if key.begins_with("Pebble") or not stone else 0.8,32.0 if key.begins_with("Pebble") else 24.0)
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
		var fitted := Transform3D(orientation,position)*normalization
		if is_tree or stone:
			# Seal the complete basal footprint against uneven terrain, not its one
			# lowest contact. Upright trees retain their authored yaw/scale and XZ.
			position.y += SceneryGrounding.footprint_adjustment(info.footprint,fitted,clampf(bounds.size.y*scale_factor*0.025,0.0015,0.015) if stone else 0.015)
		else:
			var support: PackedVector3Array = info.vertices if pitch != 0 else info.support
			position.y += SceneryGrounding.contact_adjustment(support,fitted,embedding)
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
	var info := {"bounds":GamePresentation.model_bounds(source),"parts":[],"vertices":PackedVector3Array(),"support":PackedVector3Array(),"foot_center":Vector3.ZERO,"footprint":PackedVector3Array()}
	collect_parts(source,Transform3D.IDENTITY,info.parts)
	var unique: Dictionary = {}
	var all_faces := PackedVector3Array()
	var bottom := INF
	var top := -INF
	for part in info.parts:
		for vertex: Vector3 in part.mesh.get_faces():
			var point: Vector3 = part.transform*vertex
			unique[point] = true
			all_faces.append(point)
			bottom = minf(bottom,point.y)
			top = maxf(top,point.y)
	for vertex: Vector3 in unique:
		info.vertices.append(vertex)
		if vertex.y <= bottom+(top-bottom)*0.03:
			info.support.append(vertex)
			info.foot_center += vertex
	if not info.support.is_empty(): info.foot_center /= info.support.size()
	var tree := key.begins_with("Tree") or key.begins_with("Pine") or key.begins_with("Dead Tree")
	var stone := key.begins_with("Rock") or key.begins_with("Pebble")
	if tree or stone: info.footprint = SceneryGrounding.lower_footprint(all_faces,bottom,top,0.03 if tree else 0.20)
	source.free()
	_models[key] = info
	return info

func collect_parts(node: Node3D, parent: Transform3D, parts: Array) -> void:
	var transform := parent*node.transform
	if node is MeshInstance3D: parts.append({"mesh":node.mesh,"transform":transform,"material":node.material_override,"name":str(node.name)})
	for child in node.get_children():
		if child is Node3D: collect_parts(child,transform,parts)

func build_landscape_details() -> void:
	# Domestic perennial borders define the farm edge without narrowing the 2.15m bed lanes.
	var detail_rng := RandomNumberGenerator.new()
	detail_rng.seed = 20261007
	for center in [Vector2(-22.7,5),Vector2(-22.7,13.5),Vector2(-4.4,5),Vector2(-4.3,14),Vector2(-18,17),Vector2(-8,17),Vector2(-18.6,-3.2),Vector2(-6.7,-2.5)]:
		for i in 4:
			var offset: Vector2 = [Vector2(-0.65,0.15),Vector2(0.05,-0.3),Vector2(0.45,0.2),Vector2(0.1,0.65)][i]
			var point: Vector2 = center+offset+Vector2(detail_rng.randf_range(-0.12,0.12),detail_rng.randf_range(-0.1,0.1))
			if not understorey_allowed(point,0.3): continue
			prop("Flower Group" if i == 0 else "Clover","Garden border",point,0.55,detail_rng.randf()*360,false,0,detail_rng.randf_range(0.24,0.33))
		if RuralTerrain.trail_distance(center) > 2.8:
			prop("Bush with Flowers","Garden border",center,0.85,center.x*19,false,0,0.48)
	# Leafy woodland pockets and dry weeds tell the camp/depot apart at player eye height.
	for center in [Vector2(-29,24.5),Vector2(-38,18),Vector2(-39,26),Vector2(-32,28),Vector2(-28,18.5)]:
		for i in 3:
			var point: Vector2 = center+Vector2(detail_rng.randf_range(-0.8,0.8),detail_rng.randf_range(-0.55,0.55))
			if not understorey_allowed(point,0.4): continue
			prop("Fern" if i == 0 else "Mushroom","Camp edge",point,0.5,detail_rng.randf()*360,false,0,detail_rng.randf_range(0.34,0.46) if i == 0 else detail_rng.randf_range(0.12,0.20))
	for center in [Vector2(25,-10),Vector2(35,-11),Vector2(46,-26),Vector2(37,-34),Vector2(31,-28)]:
		for i in 3:
			var point: Vector2 = center+Vector2(detail_rng.randf_range(-0.6,0.6),detail_rng.randf_range(-0.45,0.45))
			if not understorey_allowed(point,0.2): continue
			prop("Grass Wispy","Depot verge",point,0.45,detail_rng.randf()*360,false,0,detail_rng.randf_range(0.23,0.35))
	# Slim painted roadside stakes form a repeated visual cue to the clearing.
	# Use both margins at the two bends: no signage boards or new physical gates.
	for item in [
		[Vector2(7,16),Vector2(2,9)],
		[Vector2(9,25),Vector2(5,8)],
		[Vector2(14,33),Vector2(7,2)],
		[Vector2(25,39),Vector2(4,4)]
	]:
		var normal: Vector2 = Vector2(-item[1].y,item[1].x).normalized()
		for side in [-1,1]:
			var point: Vector2 = item[0]+normal*3.8*side
			if RuralTerrain.trail_distance(point) < 2.7 or point.distance_to(RuralTerrain.RESCUE) < 10: continue
			wayfinding_points.append(point)
			var foot := RuralTerrain.ground_point(point.x,point.y)
			box("TrailStake",foot+Vector3.UP*0.33,Vector3(0.09,0.76,0.09),Color("68573e"))
			box("TrailStakeCap",foot+Vector3.UP*0.59,Vector3(0.095,0.12,0.095),Color("d4ae6b"))
	# Small gravel skirts read as contact with earth, never extra collision or stepping hazards.
	for center in [Vector2(-18,-17.8),Vector2(-24,-18),Vector2(6.4,-8.3),Vector2(23.7,-13)]:
		for i in 5:
			var point: Vector2 = center+Vector2(detail_rng.randf_range(-0.85,0.85),detail_rng.randf_range(-0.5,0.5))
			prop("Pebble Round","Foundation edge",point,detail_rng.randf_range(0.15,0.26),detail_rng.randf()*360,false,0,detail_rng.randf_range(0.08,0.13))

func flush_batches() -> void:
	for key in _batches:
		# Partition the high instance-count ground cover: a MultiMesh culls as a group.
		# Measured tree partitioning increased surface/shadow draw calls on this small map.
		# Keep canopy/structural parts together and preserve the imported LOD scale correction.
		var is_foliage: bool = key in ["Grass","Tall Grass","Grass Wispy","Clover"]
		var groups: Dictionary = {}
		for placement: Transform3D in _batches[key]:
			var cell := Vector2i(floori(placement.origin.x/FOLIAGE_CELL_SIZE),floori(placement.origin.z/FOLIAGE_CELL_SIZE)) if is_foliage else Vector2i.ZERO
			if not groups.has(cell): groups[cell] = []
			groups[cell].append(placement)
		for cell in groups:
			for part in _models[key].parts:
				add_batch(key,part,groups[cell],cell,is_foliage)

func add_batch(key: String, part: Dictionary, placements: Array, cell: Vector2i, is_foliage: bool) -> void:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = part.mesh
	multi.instance_count = placements.size()
	var origin := Vector3((cell.x+0.5)*FOLIAGE_CELL_SIZE,0,(cell.y+0.5)*FOLIAGE_CELL_SIZE) if is_foliage else Vector3.ZERO
	var largest_scale := 1.0
	for i in multi.instance_count:
		var transform: Transform3D = placements[i]*part.transform
		transform.origin -= origin
		multi.set_instance_transform(i,transform)
		var scale := transform.basis.get_scale().abs()
		largest_scale = maxf(largest_scale,maxf(scale.x,maxf(scale.y,scale.z)))
	var visual := MultiMeshInstance3D.new()
	visual.name = (key+"_"+str(cell.x)+"_"+str(cell.y)).validate_node_name()
	visual.position = origin
	visual.multimesh = multi
	visual.material_override = part.material
	if key in ["Grass","Tall Grass","Grass Wispy","Clover"]:
		if not _foliage_materials.has(key):
			var source_material := part.mesh.surface_get_material(0) as StandardMaterial3D
			var toned := source_material.duplicate() as StandardMaterial3D
			toned.albedo_color *= Color(0.48,0.59,0.38)
			toned.roughness = 1.0
			_foliage_materials[key] = toned
		visual.material_override = _foliage_materials[key]
	elif key.begins_with("Tree") or key.begins_with("Pine") or key in ["Fern","Bush","Bush with Flowers"]:
		multi.mesh = toned_foliage_mesh(part.mesh)
	# MultiMesh LOD needs the scale inside instance transforms for tiny imported meshes.
	# Otherwise imported container panels and similar thin structures disappear too soon.
	visual.lod_bias = largest_scale
	add_child(visual)

func toned_foliage_mesh(source_mesh: Mesh) -> Mesh:
	var mesh_key := source_mesh.get_instance_id()
	if _toned_meshes.has(mesh_key): return _toned_meshes[mesh_key]
	var copied := source_mesh.duplicate() as ArrayMesh
	for surface in copied.get_surface_count():
		var source := copied.surface_get_material(surface) as StandardMaterial3D
		if source == null: continue
		var material_key := str(source.get_instance_id())
		if not _foliage_materials.has(material_key):
			var toned := source.duplicate() as StandardMaterial3D
			toned.albedo_color *= Color(0.81,0.88,0.74)
			toned.roughness = 1.0
			_foliage_materials[material_key] = toned
		copied.surface_set_material(surface,_foliage_materials[material_key])
	_toned_meshes[mesh_key] = copied
	return copied

func collider(zone: String, transform: Transform3D, shape: Shape3D) -> void:
	var body := StaticBody3D.new()
	body.name = zone.validate_node_name()+"Solid"
	add_child(body)
	body.transform = transform
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

func trunk(point: Vector2) -> void:
	playable_tree_colliders += 1
	var shape := CylinderShape3D.new()
	shape.height = 4.0
	shape.radius = 0.35
	collider("Tree",Transform3D(Basis.IDENTITY,Vector3(point.x,SceneryGrounding.surface_height(point)+2,point.y)),shape)

func tree_site_allowed(point: Vector2) -> bool:
	if RuralTerrain.trail_distance(point) < 4.4 or point.distance_to(RuralTerrain.RESCUE) < 13.0: return false
	for other in tree_positions:
		if point.distance_squared_to(other) < 3.0*3.0: return false
	for other in _fence_sites:
		if point.distance_squared_to(other) < 1.3*1.3: return false
	for entry in structural_placements:
		if str(entry.asset).begins_with("Tree") or str(entry.asset).begins_with("Dead Tree"): continue
		var center := Vector2(entry.point[0],entry.point[2])
		if point.distance_to(center) < entry.width*0.5+1.6: return false
	# Keep the home/workshop/farm apron and broad incoming combat sightlines open.
	if point.x > -26 and point.x < 21 and point.y > -17 and point.y < 24: return false
	if point.distance_to(Vector2(-34,21)) < 6.0: return false
	return true

func understorey_allowed(point: Vector2, radius: float) -> bool:
	if RuralTerrain.trail_distance(point) < 2.8+radius or point.distance_to(RuralTerrain.RESCUE) < 10.5+radius: return false
	for entry in structural_placements:
		if str(entry.asset).begins_with("Tree") or str(entry.asset).begins_with("Dead Tree"): continue
		if point.distance_to(Vector2(entry.point[0],entry.point[2])) < entry.width*0.5+radius+0.25: return false
	return true

func box(zone: String, point: Vector3, size: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.96
		_materials[color] = material
	visual.material_override = _materials[color]
	visual.name = zone.validate_node_name()
	visual.position = point
	add_child(visual)
	if solid:
		var shape := BoxShape3D.new()
		shape.size = size
		collider(zone,visual.transform,shape)
	return visual

func beam(zone: String, a: Vector3, b: Vector3, thickness: float, color: Color) -> MeshInstance3D:
	var visual := box(zone,(a+b)*0.5,Vector3(thickness,thickness,a.distance_to(b)),color)
	visual.look_at(b)
	return visual

func fence(a: Vector2, b: Vector2, broken: bool, low: bool = false) -> void:
	_fence_sites.append(a)
	_fence_sites.append(b)
	var height := 1.0 if low else 1.7
	var start := RuralTerrain.ground_point(a.x,a.y,height*0.5)
	var finish := RuralTerrain.ground_point(b.x,b.y,height*0.5)
	box("FencePost",start-Vector3.UP*0.04,Vector3(0.15,height+0.08,0.15),Color("6a604a"))
	box("FencePost",finish-Vector3.UP*0.04,Vector3(0.15,height+0.08,0.15),Color("6a604a"))
	for y in [-0.19,0.19] if low else [-0.25,0.25]:
		var rail_start: Vector3 = start+Vector3.UP*y
		var rail_end: Vector3 = finish+Vector3.UP*y
		if broken and y > 0:
			# One surviving upper section is attached to its post; the free end shows damage.
			rail_end = rail_start.lerp(rail_end,0.62)-Vector3.UP*0.22
		beam("FenceRail",rail_start,rail_end,0.12,Color("8a8064"))

func rock_cluster(center: Vector2, width: float, zone: String, yaw: float) -> void:
	# An asymmetric large/medium/small grouping leaves a clear side facing the route.
	var dominant := "Rock Medium-JQxF95498B" if zone == "Ridge" else "Rock Medium-s1OJ3bBzqc" if zone == "Boundary" else "Rock Medium"
	prop(dominant,zone,center,width,yaw,true,-0.38)
	for i in 3:
		var offset: Vector2 = [Vector2(-0.43,0.38),Vector2(-0.72,0.06),Vector2(0.48,-0.23)][i]
		var satellite_width: float = [2.05,1.25,0.88][i]*clampf(width/4.4,0.85,1.2)
		var point := center+offset.rotated(deg_to_rad(yaw))*width
		for attempt in 12:
			if RuralTerrain.trail_distance(point) >= 1.8+satellite_width*0.45: break
			point = center+offset.rotated(deg_to_rad(yaw+31*(attempt+1)))*width
		prop("Rock Medium" if i%2 else "Rock Medium-s1OJ3bBzqc",zone,point,satellite_width,yaw+37+i*71,false,-0.1)
	for i in 5:
		var offset: Vector2 = [Vector2(-0.5,0.65),Vector2(-0.73,0.42),Vector2(-0.94,0.18),Vector2(0.58,-0.3),Vector2(0.77,-0.14)][i]
		var point := center+offset.rotated(deg_to_rad(yaw))*width
		if RuralTerrain.trail_distance(point) < 2.4: continue
		prop("Pebble Round" if i%2 else "Pebble Square",zone,point,0.2+(i%3)*0.09,yaw+i*47,false,-0.02)
	var bush_point := center+Vector2(-width*0.55,width*0.5)
	var fern_point := center+Vector2(width*0.62,0.8)
	if understorey_allowed(bush_point,0.5): prop("Bush with Flowers",zone,bush_point,1.1,yaw)
	if understorey_allowed(fern_point,0.35): prop("Fern",zone,fern_point,0.7,yaw+55)
	grass_patch(center,Vector2(width*0.9,width*0.7),65,"Rock edge",0.35,0.65)

func grass_patch(center: Vector2, radius: Vector2, count: int, zone: String, low: float, high: float) -> void:
	for i in count:
		var angle := rng.randf()*TAU
		var spread := sqrt(rng.randf())
		var point := center+Vector2(cos(angle)*radius.x,sin(angle)*radius.y)*spread
		if not grass_allowed(point): continue
		# Broken inner pockets create uneven clumps within each larger patch.
		var pocket := sin(point.x*0.72+cos(point.y*0.33))*cos(point.y*0.61)
		if pocket > 0.45 and i%3: continue
		if not reserve_grass_site(point): continue
		var key := "Grass" if i%10 < 6 else "Tall Grass" if i%10 < 8 else "Grass Wispy" if i%10 == 8 else "Clover"
		var height := rng.randf_range(low,high)
		if key == "Clover": height *= 0.55
		prop(key,zone,point,0.5,rng.randf()*360,false,-0.018,height)
		grass_counts[zone] = grass_counts.get(zone,0)+1

func reserve_grass_site(point: Vector2) -> bool:
	# Keep distinct roots inside clumps instead of near-identical overlapping tufts.
	var cell := Vector2i(floori(point.x/0.18),floori(point.y/0.18))
	for x in range(-1,2):
		for z in range(-1,2):
			for other: Vector2 in _grass_sites.get(cell+Vector2i(x,z),[]):
				if point.distance_squared_to(other) < 0.18*0.18: return false
	if not _grass_sites.has(cell): _grass_sites[cell] = []
	_grass_sites[cell].append(point)
	return true

func grass_allowed(point: Vector2) -> bool:
	if maxf(absf(point.x),absf(point.y)) > 55.0: return false
	if RuralTerrain.trail_distance(point) < (2.3 if point.y < 15 else 3.1): return false
	if point.distance_to(RuralTerrain.RESCUE) < 10.3: return false
	# Soil groups, veranda/house, open front yard, workshop and depot access stay clear.
	if point.x > -21.7 and point.x < -5.2 and point.y > 2.4 and point.y < 14.6: return false
	if point.x > -17.5 and point.x < -6.0 and point.y > -15.5 and point.y < 1.0: return false
	if point.x > -0.5 and point.x < 8.6 and point.y > -15.5 and point.y < -5.6: return false
	if point.x > 23 and point.x < 46 and point.y > -34.8 and point.y < -11.2: return false
	if point.x > 13.5 and point.x < 22.5 and point.y > 37.5 and point.y < 50: return false
	if point.distance_to(Vector2(-34,21)) < 4.0: return false
	var cell := Vector2i(floori(point.x/2.0),floori(point.y/2.0))
	for x in range(-1,2):
		for z in range(-1,2):
			for tree: Vector2 in _trunk_cells.get(cell+Vector2i(x,z),[]):
				if point.distance_squared_to(tree) < 0.65*0.65: return false
	for stone in _stone_footprints:
		if point.distance_to(stone.point) < stone.radius: return false
	return true

func prepare_cabin_model(model: Node3D) -> void:
	# Static wrapper adaptation: widen this supplied cabin's narrow entry to ~1.85 m.
	# Apply identical transforms to render and collision; keep the source GLB untouched.
	for part: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		var label := str(part.name)
		# Copy only exterior surface materials; never modify the furnished source asset.
		var finishes := {
			"group1586743875":{"mat22":Color("635846")}, # continuous floor / veranda
			"group14942143":{"mat21":Color("756d5c"),"mat15":Color("57554b")}, # chimney
			"group690343594":{"mat15":Color("7c715a")}, # fascia
			"group1249612197":{"mat15":Color("68604e")}, # porch roof edge
			"group155880449":{"mat17":Color("394a44")},
			"group385332886":{"mat17":Color("394a44")}
		}
		if finishes.has(label):
			for surface in part.mesh.get_surface_count():
				var source := part.mesh.surface_get_material(surface) as StandardMaterial3D
				if source == null or not finishes[label].has(str(source.resource_name)): continue
				var finish := source.duplicate() as StandardMaterial3D
				finish.albedo_color = finishes[label][str(source.resource_name)]
				finish.metallic = 0.0
				finish.roughness = 0.95
				part.set_surface_override_material(surface,finish)
		if label in ["group2096568958","group1499761262"]:
			part.hide()
			continue
		if label == "group153432663": part.position.x -= 0.07
		elif label == "group240409007": part.position.x += 0.07
		elif label == "group1467649897":
			var bounds := part.get_aabb()
			part.scale.x = (bounds.size.x+0.14)/bounds.size.x
			part.position.x = -0.07+(1.0-part.scale.x)*bounds.position.x
		else:
			var bounds := part.get_aabb()
			var minimum := bounds.position
			var maximum := bounds.end
			if minimum.z < 0.37 or maximum.z > 0.54: continue
			if minimum.x < -0.7 and maximum.x > -0.65 and maximum.x < -0.55:
				part.scale.x = (bounds.size.x-0.07)/bounds.size.x
				part.position.x = (1.0-part.scale.x)*minimum.x
			elif minimum.x > -0.38 and minimum.x < -0.3 and maximum.x > 0.1:
				part.scale.x = (bounds.size.x-0.07)/bounds.size.x
				part.position.x = (1.0-part.scale.x)*maximum.x
