class_name CameraAimRay
extends Node3D

signal sample_updated

@export_range(1.0, 1000.0) var aim_max_distance: float = 100.0
@export_flags_3d_physics var aim_collision_mask: int = 5

var aim_origin := Vector3.ZERO
var aim_direction := Vector3.FORWARD
var aim_point := Vector3.ZERO
var hit_normal := Vector3.ZERO
var hit_collider: Object
var has_hit := false
var camera: Camera3D
var _exclude: Array[RID] = []
var _debug: DebugControls
var _rig: ThirdPersonCamera
var _marker: MeshInstance3D


func bind(rig: ThirdPersonCamera, actor: CollisionObject3D, debug: DebugControls) -> void:
	_rig = rig
	camera = rig.camera
	_exclude = [actor.get_rid()]
	_debug = debug
	_marker = MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.045
	mesh.height = 0.09
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.3, 0.6)
	mesh.material = material
	_marker.mesh = mesh
	_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker.visible = false
	add_child(_marker)
	rig.pose_updated.connect(update_aim)
	rig.aim_changed.connect(func(_aiming: bool) -> void: _refresh_marker())
	rig.controls_changed.connect(func(_enabled: bool) -> void: _refresh_marker())
	debug.status_changed.connect(func(_active: bool, _summary: String) -> void: _refresh_marker())


func update_aim() -> void:
	if camera == null:
		return
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	aim_origin = camera.project_ray_origin(center)
	aim_direction = camera.project_ray_normal(center).normalized()
	var end := aim_origin + aim_direction * aim_max_distance
	var query := PhysicsRayQueryParameters3D.create(aim_origin, end, aim_collision_mask, _exclude)
	query.hit_from_inside = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	has_hit = not hit.is_empty()
	aim_point = hit.get("position", end)
	hit_normal = hit.get("normal", Vector3.ZERO)
	hit_collider = hit.get("collider")
	_refresh_marker()
	sample_updated.emit()


func debug_visible() -> bool:
	return _debug != null and _debug.active and _debug.debug_enabled and OS.is_debug_build() and _rig.can_control() and _rig.is_aiming


func _refresh_marker() -> void:
	if _marker == null:
		return
	_marker.visible = debug_visible()
	_marker.global_position = aim_point + hit_normal * 0.015
