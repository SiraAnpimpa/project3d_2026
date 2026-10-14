extends MeshInstance3D
## One unshaded, ground-following red mesh fills the committed charge corridor.
const MATERIAL = preload("res://resources/materials/boss_warning.tres")
var _vertices := PackedVector3Array()
var _space: PhysicsDirectSpaceState3D
var _height := 0.0

func _ready() -> void:
	top_level = true
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material_override = MATERIAL
	hide()

func rebuild(origin: Vector3, forward: Vector3, distance: float, radius: float) -> void:
	global_transform = Transform3D.IDENTITY
	_space = get_world_3d().direct_space_state
	_height = origin.y
	_vertices.clear()
	var steps := maxi(1, ceili(distance / 0.6))
	for index in steps:
		var start := origin + forward * distance * float(index) / steps
		var finish := origin + forward * distance * float(index + 1) / steps
		_strip(start, finish, radius * 2.0)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _vertices
	var shape := ArrayMesh.new()
	shape.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = shape
	show()

func _ground(point: Vector3) -> Vector3:
	var ray := PhysicsRayQueryParameters3D.create(Vector3(point.x, _height + 4, point.z), Vector3(point.x, _height - 8, point.z), 1)
	var hit := _space.intersect_ray(ray)
	point.y = float(hit.position.y) + 0.065 if not hit.is_empty() else RuralTerrain.height_at(point.x, point.z) + 0.065
	return point

func _strip(start: Vector3, finish: Vector3, width: float) -> void:
	var normal := (finish - start).cross(Vector3.UP).normalized() * width * 0.5
	var a := _ground(start - normal)
	var b := _ground(start + normal)
	var c := _ground(finish - normal)
	var d := _ground(finish + normal)
	_vertices.append_array(PackedVector3Array([a, c, b, b, c, d]))
