extends SceneTree
## Offline mesh authoring. Shared static scenes preserve the existing harvest owners.
const OUT := "res://scenes/farming/harvest/"
const ART := "res://assets/farming/harvest/"
const NATURE := "res://Asset/Stylized Nature MegaKit.undefined-glb/"
const RPG := "res://Asset/Ultimate RPG Items Bundle-glb/"
var composition: Node3D
var manifest: Array = []
var painted_meshes: Dictionary = {}

func _initialize() -> void: call_deferred("build")

func own(node: Node, parent: Node) -> void:
	parent.add_child(node)
	node.owner = composition

func material(id: String, color: String, metal := 0.0, rough := .8, glow := 0.0, painted := false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.resource_name = id
	mat.albedo_color = Color(color)
	mat.metallic = metal
	mat.roughness = rough
	mat.vertex_color_use_as_albedo = painted
	mat.vertex_color_is_srgb = painted
	if glow > 0:
		mat.emission_enabled = true
		mat.emission = Color(color) if not painted else Color(.35,.35,.35)
		mat.emission_energy_multiplier = glow
	ResourceSaver.save(mat,ART+id+".tres")
	return mat

func begin(id: String) -> void:
	composition = Node3D.new()
	composition.name = id.to_pascal_case()+"Harvest"
	root.add_child(composition)

func mesh_bounds(parent: Node3D) -> AABB:
	var result := AABB()
	var found := false
	for mesh: MeshInstance3D in parent.find_children("*","MeshInstance3D",true,false):
		var box := (parent.global_transform.affine_inverse()*mesh.global_transform)*mesh.get_aabb()
		result = result.merge(box) if found else box
		found = true
	return result

func paint_facets(source: Mesh, key: String) -> ArrayMesh:
	if painted_meshes.has(key): return painted_meshes[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for surface in source.get_surface_count():
		var arrays := source.surface_get_arrays(surface)
		var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		if indices.is_empty():
			for index in points.size(): indices.append(index)
		for offset in range(0,indices.size(),3):
			var variation: int = (offset/3*7+surface*3)%13
			var pigment := 1.08 if variation == 1 or variation == 4 else (.9 if variation == 8 else 1.0)
			for corner in 3:
				var index := indices[offset+corner]
				st.set_color(Color(pigment,pigment,pigment))
				st.set_normal(normals[index])
				st.add_vertex(points[index])
	var result := st.commit()
	ResourceSaver.save(result,ART+key+".tres")
	painted_meshes[key] = result
	return result

func native(id: String, path: String, size: Vector3, point: Vector3, yaw: float, mat: Material = null, pigment_key := "") -> void:
	var imported: Node3D = load(path).instantiate()
	root.add_child(imported)
	var box := mesh_bounds(imported)
	var fit := size/box.size
	var center := Vector3(box.get_center().x,box.position.y,box.get_center().z)
	var anchor := Node3D.new()
	anchor.name = id
	own(anchor,composition)
	anchor.position = point
	anchor.rotation_degrees.y = yaw
	var part := 0
	for source: MeshInstance3D in imported.find_children("*","MeshInstance3D",true,false):
		var mesh := MeshInstance3D.new()
		mesh.name = source.name
		mesh.mesh = source.mesh if pigment_key.is_empty() else paint_facets(source.mesh,pigment_key+"_"+str(part))
		mesh.material_override = mat
		var source_pose := imported.global_transform.affine_inverse()*source.global_transform
		mesh.transform = Transform3D(Basis.from_scale(fit),-center*fit)*source_pose
		own(mesh,anchor)
		part += 1
	imported.free()

func shape(id: String, geometry: Mesh, mat: Material, point: Vector3, rotation: Vector3 = Vector3.ZERO, size: Vector3 = Vector3.ONE, ground := false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = id
	mesh.mesh = geometry
	mesh.material_override = mat
	mesh.position = point
	mesh.rotation_degrees = rotation
	mesh.scale = size
	own(mesh,composition)
	if ground:
		var box := mesh.transform*mesh.get_aabb()
		mesh.position.y -= box.position.y
	return mesh

func finish(id: String, sources: Array, read: String) -> void:
	var scene := PackedScene.new()
	assert(scene.pack(composition) == OK)
	assert(ResourceSaver.save(scene,OUT+id+"_harvest.tscn") == OK)
	var box := mesh_bounds(composition)
	manifest.append({"approval_status":"Review again after rebuilding assets","plant":id,"scene":OUT+id+"_harvest.tscn","sources":sources,"bounds":{"position":var_to_str(box.position),"size":var_to_str(box.size)},"collision":false,"pickup_logic":false,"variation":"fixed authored anchors; no runtime construction","visual_read":read,"technical_frame":{"engine":"Godot 4.7 Compatibility / Web","camera":"third-person; 1600x900 acceptance capture; 1280x720 game viewport","soil_width_m":1.65,"pivot":"soil contact, Y up","textures":"none added; shared native meshes and vertex pigments","detail":"broad low-poly facets, restrained accents, no labels"},"provenance":"Source supplied GLB geometry terms: ASSET_CREDITS.md. Native mesh derivatives and new sheet/pepper/ice/mushroom geometry authored with this offline SurfaceTool builder; no downloads or generated raster images.","revision":"2026-10-07 harvest asset polish"})
	print("HARVEST_BUILT ",id," ",box)
	composition.free()

func triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, outward: Vector3, color: Color) -> void:
	var normal := (b-a).cross(c-a)
	if normal.length_squared() < .0000000001: return
	# Godot front faces use clockwise winding; normals point out of closed solids.
	if normal.dot(outward) < 0: normal = -normal
	var vertices := [a,b,c] if (b-a).cross(c-a).dot(normal) < 0 else [a,c,b]
	for vertex in vertices:
		st.set_normal(normal.normalized())
		st.set_color(color)
		st.add_vertex(vertex)

func sheet_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points := [Vector3(-.17,0,-.24),Vector3(.17,0,-.24),Vector3(-.17,.023,0),Vector3(.17,.023,0),Vector3(-.17,.045,.24),Vector3(.105,.045,.24),Vector3(.17,.095,.17)]
	var faces := [[0,2,1],[1,2,3],[2,4,3],[3,4,5],[3,5,6]]
	for index in faces.size():
		var face: Array = faces[index]
		triangle(st,points[face[0]],points[face[1]],points[face[2]],Vector3.UP,Color("e0d1ac") if index < 4 else Color("f0e3c6"))
		triangle(st,points[face[0]]-Vector3.UP*.008,points[face[1]]-Vector3.UP*.008,points[face[2]]-Vector3.UP*.008,Vector3.DOWN,Color("c2ad85"))
	var edge := [0,1,3,6,5,4,2]
	for index in edge.size():
		var a: Vector3 = points[edge[index]]
		var b: Vector3 = points[edge[(index+1)%edge.size()]]
		var c := b-Vector3.UP*.008
		var d := a-Vector3.UP*.008
		var out := Vector3((a+b).x,0,(a+b).z)
		triangle(st,a,b,c,out,Color("bda67b"))
		triangle(st,a,c,d,out,Color("bda67b"))
	return st.commit()

func patched_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, hint: Vector3, color: Color) -> void:
	# Subdivide the actual roof face: markings share its plane and cannot float.
	var outer := [a,b,c]
	var inner := [a*.5+b*.25+c*.25,b*.5+c*.25+a*.25,c*.5+a*.25+b*.25]
	for index in 3:
		var next := (index+1)%3
		triangle(st,outer[index],outer[next],inner[next],hint,color)
		triangle(st,outer[index],inner[next],inner[index],hint,color)
	triangle(st,inner[0],inner[1],inner[2],hint,Color("c2cf94"))

func ring_solid(st: SurfaceTool, profiles: Array, sides: int, palette: Array, offset := Vector3.ZERO, bend := 0.0, patches := false) -> void:
	for ring in profiles.size()-1:
		for side in sides:
			var vertices: Array[Vector3] = []
			for pair in [[ring,side],[ring+1,side],[ring+1,side+1],[ring,side+1]]:
				var profile: Vector2 = profiles[pair[0]]
				var angle: float = pair[1]*TAU/sides
				vertices.append(offset+Vector3(cos(angle)*profile.y+bend*pow(1-profile.x/float(profiles[-1].x),2),profile.x,sin(angle)*profile.y))
			var angle_mid := (side+.5)*TAU/sides
			var hint := Vector3(cos(angle_mid),0,sin(angle_mid))
			var color: Color = palette[side%palette.size()]
			triangle(st,vertices[0],vertices[1],vertices[2],hint,color)
			if patches and ring == profiles.size()-2 and side in [0,3,6]:
				patched_triangle(st,vertices[0],vertices[2],vertices[3],hint,color)
			else:
				triangle(st,vertices[0],vertices[2],vertices[3],hint,color)

func pepper_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	ring_solid(st,[Vector2(0,0),Vector2(.08,.031),Vector2(.21,.067),Vector2(.34,.077),Vector2(.4,.047),Vector2(.425,0)],8,[Color("c94929"),Color("d65c2b"),Color("c54725"),Color("b83724")],Vector3.ZERO,.065)
	# A five-point calyx shares the fruit mesh/material and visibly connects the stem.
	for side in 5:
		var angle := side*TAU/5
		var a := Vector3(cos(angle-.45)*.025,.427,sin(angle-.45)*.025)
		var b := Vector3(cos(angle)*.068,.394,sin(angle)*.068)
		var c := Vector3(cos(angle+.45)*.025,.427,sin(angle+.45)*.025)
		triangle(st,a,b,c,Vector3.UP,Color("59763c"))
		triangle(st,a,b,c,Vector3.DOWN,Color("465e32"))
	return st.commit()

func ice_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	ring_solid(st,[Vector2(0,0),Vector2(.025,.1),Vector2(.13,.14),Vector2(.46,.12),Vector2(.64,0)],6,[Color("a6d6df"),Color("74b8cd"),Color("9acede"),Color("c5e5e7"),Color("82bdcf"),Color("92c7d7")])
	return st.commit()

func mushroom_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	ring_solid(st,[Vector2(0,0),Vector2(.006,.072),Vector2(.12,.057),Vector2(.34,.052),Vector2(.4,0)],8,[Color("a7b496"),Color("909d84"),Color("929285")])
	ring_solid(st,[Vector2(.335,0),Vector2(.34,.08),Vector2(.37,.25),Vector2(.435,.28),Vector2(.54,.17),Vector2(.59,0)],10,[Color("7d9d45"),Color("92ad4f"),Color("88a746"),Color("a0b95a")],Vector3.ZERO,0,true)
	return st.commit()

func branch(id: String, from: Vector3, to: Vector3, mat: Material) -> void:
	var geometry := CylinderMesh.new()
	geometry.top_radius = .009
	geometry.bottom_radius = .013
	geometry.height = from.distance_to(to)
	geometry.radial_segments = 6
	var node := shape(id,geometry,mat,(from+to)*.5)
	node.quaternion = Quaternion(Vector3.UP,(to-from).normalized())

func build() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ART))
	var paper := material("paper_cream","b7b7b7",0,.94,0,true)
	var steel := material("iron_steel","697c83",.42,.59,0,true)
	var copper := material("copper_warm","c77941",.48,.56,0,true)
	var lead := material("lead_blue","555d77",.19,.81,0,true)
	var ice := material("ice_cyan","bdbdbd",0,.37,.09,true)
	var toxic := material("poison_lime","aaaaaa",0,.82,.045,true)
	var stem := material("pepper_stem","526c35",0,.9)
	var fruit := material("pepper_red","c2c2c2",0,.55,.04,true)
	var herb := material("herb_leaf","6f963f",0,.92,0,true)
	var paper_mesh := sheet_mesh()
	var pepper := pepper_mesh()
	var shard := ice_mesh()
	var mushroom := mushroom_mesh()
	ResourceSaver.save(paper_mesh,ART+"paper_sheet.tres")
	ResourceSaver.save(pepper,ART+"pepper_fruit.tres")
	ResourceSaver.save(shard,ART+"ice_shard.tres")
	ResourceSaver.save(mushroom,ART+"poison_mushroom.tres")
	begin("paper")
	shape("PaperSheetA",paper_mesh,paper,Vector3(-.29,0,.24),Vector3(13,-19,-8),Vector3(.95,1,.95),true)
	shape("PaperSheetB",paper_mesh,paper,Vector3(.29,0,.22),Vector3(48,22,8),Vector3(.9,1,.92),true)
	shape("PaperSheetC",paper_mesh,paper,Vector3(-.12,0,-.3),Vector3(8,34,-7),Vector3(.72,1,.72),true)
	native("PaperScroll",RPG+"Scroll.glb",Vector3(.36,.072,.1),Vector3(-.29,0,-.12),-25)
	finish("paper",[RPG+"Scroll.glb","authored folded solid paper_sheet.tres"],"Cream folded rectangles with thin darker edges; two clear foreground sheets, one smaller rear sheet and a restrained scroll.")
	begin("iron")
	native("IronChunkA",NATURE+"Pebble Square.glb",Vector3(.44,.29,.36),Vector3(-.29,0,.27),-18,steel,"iron_chunk")
	native("IronChunkB",NATURE+"Pebble Square-s71L3q1nXN.glb",Vector3(.29,.19,.25),Vector3(.3,0,.26),25,steel,"iron_chip")
	native("IronChunkC",NATURE+"Pebble Square.glb",Vector3(.22,.14,.2),Vector3(.25,0,-.3),62,steel,"iron_chunk")
	finish("iron",[NATURE+"Pebble Square.glb",NATURE+"Pebble Square-s71L3q1nXN.glb"],"Broad angular steel-gray chunks; restrained metal response, sparse facet pigment variation and air between all three.")
	begin("copper")
	native("CopperOreA",RPG+"Mineral.glb",Vector3(.43,.36,.39),Vector3(-.3,0,.23),-20,copper,"copper_mineral")
	native("CopperOreB",RPG+"Mineral.glb",Vector3(.28,.24,.26),Vector3(.3,0,.28),48,copper,"copper_mineral")
	finish("copper",[RPG+"Mineral.glb"],"Two squat warm copper clusters; tighter broad points distinguish ore from tall cold ice needles.")
	begin("lead")
	native("LeadNoduleA",NATURE+"Pebble Round.glb",Vector3(.46,.235,.35),Vector3(-.29,0,.27),-22,lead,"lead_nodule")
	native("LeadNoduleB",NATURE+"Pebble Round-KYtJ6JNXh2.glb",Vector3(.32,.17,.27),Vector3(.31,0,.23),36,lead,"lead_pebble")
	native("LeadNoduleC",NATURE+"Pebble Round.glb",Vector3(.24,.125,.2),Vector3(.23,0,-.29),-55,lead,"lead_nodule")
	finish("lead",[NATURE+"Pebble Round.glb",NATURE+"Pebble Round-KYtJ6JNXh2.glb"],"Low rounded dense blue-violet nodules with matte facets, clearly flatter than Iron and separated from the purple base foliage.")
	begin("small_herb")
	native("HarvestLeaves",NATURE+"Clover-u5SOgBFiut.glb",Vector3(.43,.43,.36),Vector3(-.13,0,.16),-20,herb,"herb_clover")
	native("HerbFlower",NATURE+"Flower Single.glb",Vector3(.13,.26,.13),Vector3(.23,0,.2),25)
	finish("small_herb",[NATURE+"Clover-u5SOgBFiut.glb",NATURE+"Flower Single.glb"],"Broad matte olive-green herb leaves and one small flower; lower detail density and no glow.")
	begin("fire_pepper")
	for index in 3:
		var point: Vector3 = [Vector3(-.29,.055,.3),Vector3(.29,.09,.29),Vector3(.03,.19,-.3)][index]
		var size: float = [1.0,.9,.82][index]
		var node := shape("PepperFruit"+str(index+1),pepper,fruit,point,Vector3(0,index*53,-12 if index%2 == 0 else 13),Vector3.ONE*size)
		branch("PepperStem"+str(index+1),Vector3(0,.46,0),node.transform*Vector3(0,.427,0),stem)
	finish("fire_pepper",["authored tapered pepper_fruit.tres with green calyx","support stems; existing fire base and particles unchanged"],"Three hanging tapered deep red peppers with warm facets, pointed curved tails and green calyx/stem connections; no floating fruit.")
	begin("ice_plant")
	shape("IceShardA",shard,ice,Vector3(-.28,0,.29),Vector3(0,-15,-8),Vector3.ONE,true)
	shape("IceShardB",shard,ice,Vector3(.28,0,.3),Vector3(0,30,10),Vector3(.8,.73,.8),true)
	shape("IceShardC",shard,ice,Vector3(.07,0,-.3),Vector3(0,65,-13),Vector3(.6,.49,.6),true)
	finish("ice_plant",["authored ice_shard.tres; visual family based on existing Mineral.glb"],"Three clean six-sided pale cyan shards, primary/secondary/tertiary heights, broad readable cold facets and minimal emission.")
	begin("poison_plant")
	shape("PoisonMushroomA",mushroom,toxic,Vector3(-.17,0,.28),Vector3(0,-15,0),Vector3.ONE,true)
	shape("PoisonMushroomB",mushroom,toxic,Vector3(.3,0,.26),Vector3(0,45,0),Vector3(.62,.68,.62),true)
	finish("poison_plant",["authored poison_mushroom.tres; existing mushroom base and spores unchanged"],"Two stout mushrooms with broad green umbrella caps, pale sage stems and a few restrained cap markings; visible cap/stem contrast instead of flat uniform green shapes.")
	var file := FileAccess.open(ART+"manifest.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"  "))
	quit()
