extends Node3D
## Brief expanding shockwave. Visual-only; damage and slow have already committed.
func burst(radius: float, tint: Color) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = tint
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var ring := TorusMesh.new()
	ring.inner_radius = radius-0.10
	ring.outer_radius = radius
	ring.rings = 48
	ring.ring_segments = 6
	ring.material = material
	var visual := MeshInstance3D.new()
	visual.mesh = ring
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visual.position.y = 0.12
	visual.scale = Vector3(0.15, 1, 0.15)
	add_child(visual)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(visual,"scale",Vector3.ONE,0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(material,"albedo_color:a",0.0,0.5)
	tween.chain().tween_callback(queue_free)
