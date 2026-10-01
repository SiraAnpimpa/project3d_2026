@tool
class_name RuralTerrain
extends Node3D
## Authored height function shared by visible terrain, collider, props and bake.
## Level farmstead and southern evacuation plateau; fixed authored contours.

const PLAY_HALF := 56.0
const VISUAL_HALF := 120.0
const RESCUE := Vector2(29,43)
const RESCUE_HEIGHT := 0.65
const TRAILS := [
	[Vector2(0,-4),Vector2(2,-13),Vector2(4,-22),Vector2(-1,-28),Vector2(-10,-37)],
	[Vector2(4,2),Vector2(13,-1),Vector2(22,3),Vector2(32,0),Vector2(39,5)],
	[Vector2(32,0),Vector2(38,-6),Vector2(43,-11),Vector2(44,-20)],
	[Vector2(-7,4),Vector2(-17,7),Vector2(-27,12),Vector2(-36,9),Vector2(-47,15)],
	[Vector2(0,7),Vector2(7,16),Vector2(9,25),Vector2(14,33),Vector2(18,41),Vector2(20,62),Vector2(28,112)],
	[Vector2(14,33),Vector2(21,35),Vector2(25,39),Vector2(29,43)],
	[Vector2(32,0),Vector2(31,-7),Vector2(28.5,-13.5),Vector2(33,-20)],
	[Vector2(-27,12),Vector2(-31,16),Vector2(-34,21)],
	[Vector2(-16,-8),Vector2(-19,-13),Vector2(-21,-18)],
	[Vector2(-13.5,-6),Vector2(-13.5,-0.8),Vector2(-3,-1),Vector2(3,-6.5)],
	[Vector2(-13.5,-0.8),Vector2(-13.4,8.5),Vector2(-13.4,17),Vector2(-7,19),Vector2(7,16)]
]

func _ready() -> void:
	build_patch("PlayableTerrain", PLAY_HALF, 2.0, true)
	build_patch("DistantTerrain", VISUAL_HALF, 4.0, false)

static func mound(x: float, z: float, cx: float, cz: float, rx: float, rz: float) -> float:
	return exp(-pow((x-cx)/rx,2)-pow((z-cz)/rz,2))

static func height_at(x: float, z: float) -> float:
	var edge := smoothstep(18.0,32.0,maxf(absf(x),absf(z)))
	var height := 4.8*mound(x,z,-9,-43,34,15) + 4.4*mound(x,z,-45,8,16,35)
	height += 2.3*mound(x,z,39,-21,24,26) + 1.2*mound(x,z,38,42,20,22)
	height += 2.1*mound(x,z,0,-28,12,6)
	height += (0.24*sin(x*0.13+z*0.05)+0.17*cos(z*0.17-x*0.08))*edge
	var drain_x := 27.0+2.0*sin(z*0.10)
	height -= 2.4*mound(x,z,drain_x,16,6.0,21)
	height *= edge
	# Low roadside shoulder gradually hides the landing surface from the farm.
	height += 2.2*mound(x,z,18,29,12,8)
	var outside := smoothstep(52.0,78.0,maxf(absf(x),absf(z)))
	height += outside*(7.5*mound(x,z,-65,-75,40,24)+9.5*mound(x,z,63,-78,35,32)+6.0*mound(x,z,-80,35,22,48))
	height += outside*(1.0+0.9*sin(x*0.035)*cos(z*0.042))
	# Broad level farm soil and depot foundations blend into the existing slopes.
	var farm_edge := maxf(absf(x+13.4)-10.2,absf(z-8.5)-7.7)
	height *= smoothstep(0.0,5.0,farm_edge)
	var depot_edge := maxf(absf(x-35.5)-13.0,absf(z+23)-12.5)
	height = lerpf(height,1.85,1.0-smoothstep(0.0,5.5,depot_edge))
	height = lerpf(height,0.35,1.0-smoothstep(3.2,10.5,Vector2(x+21,z+18).length()))
	height = lerpf(height,2.6,1.0-smoothstep(3.1,10.5,Vector2(x+34,z-21).length()))
	# A continuous earth apron meets the veranda from all walking directions.
	var porch_edge := maxf(absf(x+12)-4.6,absf(z+10)-5.3)
	height = lerpf(height,0.135,1.0-smoothstep(0.0,1.8,porch_edge))
	var checkpoint := 1.0-smoothstep(7.5,11.5,Vector2(x-18,z-45).length())
	height = lerpf(height,RESCUE_HEIGHT,checkpoint)
	var landing_blend := 1.0-smoothstep(9.5,16.5,Vector2(x,z).distance_to(RESCUE))
	return lerpf(height,RESCUE_HEIGHT,landing_blend)

static func ground_point(x: float, z: float, lift: float = 0.0) -> Vector3:
	return Vector3(x,height_at(x,z)+lift,z)

static func trail_distance(point: Vector2) -> float:
	var result := INF
	for trail in TRAILS:
		for i in range(trail.size()-1):
			var a: Vector2 = trail[i]
			var b: Vector2 = trail[i+1]
			var t := clampf((point-a).dot(b-a)/(b-a).length_squared(),0,1)
			result = minf(result,point.distance_to(a.lerp(b,t)))
	return result

static func ground_color(x: float, z: float) -> Color:
	var variation := 0.5+0.5*sin(x*0.31+sin(z*0.19))*cos(z*0.23)
	var color := Color("475b3e").lerp(Color("646c48"),variation*0.55)
	var forest := mound(x,z,-40,6,26,35)
	color = color.lerp(Color("40513a"),forest*0.62)
	var ridge := smoothstep(2.4,5.5,height_at(x,z))
	color = color.lerp(Color("7c7864"),ridge*0.58)
	var dry := mound(x,z,34,-18,15,20)
	color = color.lerp(Color("958460"),dry*0.65)
	var drain := mound(x,z,27+2*sin(z*0.10),16,4,20)
	color = color.lerp(Color("756754"),drain*0.72)
	var point := Vector2(x,z)
	var edge_variation := 0.3*sin(x*0.63+z*0.37)+0.18*cos(z*0.71-x*0.22)
	var utility := rounded_edge(point,Vector2(3,-10),Vector2(4.8,4.5),1.2)
	color = color.lerp(Color("817358"),(1.0-smoothstep(-0.3,2.5,utility+edge_variation))*0.85)
	var distance := trail_distance(Vector2(x,z))
	var path_width := lerpf(2.2,3.1,smoothstep(8.0,20.0,z))
	color = color.lerp(Color("807155"),(1.0-smoothstep(path_width-1.0,path_width+1.6,distance+edge_variation))*0.88)
	var apron := rounded_edge(point,Vector2(-12,-10),Vector2(4.95,5.65),1.4)
	color = color.lerp(Color("81765e"),(1.0-smoothstep(0.0,2.7,apron+edge_variation))*0.8)
	var yard := rounded_edge(point,Vector2(-12,-6),Vector2(6.0,6.8),1.8)
	color = color.lerp(Color("8a7b5e"),(1.0-smoothstep(-0.3,2.2,yard+edge_variation))*0.8)
	var soil := minf(maxf(absf(x+8.9)-3.7,absf(z-8.5)-5.5),maxf(absf(x+17.9)-3.7,absf(z-8.5)-5.5))
	color = color.lerp(Color("615039"),1.0-smoothstep(-0.3,1.3,soil+edge_variation))
	# Broad uneven worn-grass boundary, rather than a bright circular pad stamped on terrain.
	var offset := point-RESCUE
	var clearing := Vector2(offset.x*0.9,offset.y*1.05).length()
	var clearing_edge := 0.8*sin(x*0.45+z*0.21)+0.45*cos(z*0.62-x*0.18)
	color = color.lerp(Color("8d8162"),(1.0-smoothstep(4.5,12.5,clearing+clearing_edge))*0.88)
	var truck_wear := point.distance_to(Vector2(18.5,41))
	color = color.lerp(Color("807154"),(1.0-smoothstep(2.5,5.2,truck_wear))*0.5)
	return color

static func rounded_edge(point: Vector2,center: Vector2,half_extents: Vector2,corner: float) -> float:
	var q := (point-center).abs()-half_extents+Vector2.ONE*corner
	return Vector2(maxf(q.x,0),maxf(q.y,0)).length()+minf(maxf(q.x,q.y),0)-corner

func build_patch(label: String, half: float, step: float, solid: bool) -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var cells := int(half*2/step)
	for iz in cells:
		for ix in cells:
			var x := -half+ix*step
			var z := -half+iz*step
			if not solid and x >= -PLAY_HALF and x < PLAY_HALF and z >= -PLAY_HALF and z < PLAY_HALF: continue
			var a := ground_point(x,z)
			var b := ground_point(x+step,z)
			var c := ground_point(x,z+step)
			var d := ground_point(x+step,z+step)
			# Godot front faces are clockwise. Terrain faces must be visible from above.
			for triangle in [[a,b,c],[b,d,c]]:
				var normal: Vector3 = -(triangle[1]-triangle[0]).cross(triangle[2]-triangle[0]).normalized()
				for point: Vector3 in triangle:
					vertices.append(point)
					normals.append(normal)
					colors.append(ground_color(point.x,point.z))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.96
	var visual := MeshInstance3D.new()
	visual.name = label
	visual.mesh = mesh
	visual.material_override = material
	add_child(visual)
	if solid:
		var body := StaticBody3D.new()
		body.name = "TerrainCollision"
		add_child(body)
		var collision := CollisionShape3D.new()
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(vertices)
		collision.shape = shape
		body.add_child(collision)
