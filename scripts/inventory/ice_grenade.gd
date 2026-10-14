extends RigidBody3D
signal detonated(hits: int)
var item: ItemData
var fuse := 1.45
var exploded := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 9
	continuous_cd = true
	linear_damp = 0.35
	mass = 0.35
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.12
	collision.shape = sphere
	add_child(collision)
	var body := CylinderMesh.new()
	body.top_radius = 0.1
	body.bottom_radius = 0.105
	body.height = 0.24
	body.radial_segments = 12
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("6dcce0")
	material.roughness = 0.7
	body.material = material
	var mesh := MeshInstance3D.new()
	mesh.mesh = body
	add_child(mesh)
	var band := CylinderMesh.new()
	band.top_radius = 0.107
	band.bottom_radius = 0.107
	band.height = 0.065
	band.radial_segments = 12
	var white := StandardMaterial3D.new()
	white.albedo_color = Color("edf5de")
	band.material = white
	var stripe := MeshInstance3D.new()
	stripe.mesh = band
	add_child(stripe)
	var cap := CylinderMesh.new()
	cap.top_radius = 0.055
	cap.bottom_radius = 0.055
	cap.height = 0.055
	cap.radial_segments = 10
	cap.material = white
	var top := MeshInstance3D.new()
	top.mesh = cap
	top.position.y = 0.15
	add_child(top)

func _physics_process(delta: float) -> void:
	fuse -= delta
	if fuse <= 0: explode()

func explode() -> int:
	if exploded or item == null: return 0
	exploded = true
	var area := SphereShape3D.new()
	area.radius = item.blast_radius
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = area
	query.transform = Transform3D(Basis.IDENTITY,global_position)
	query.collision_mask = 8
	var hits := 0
	for hit in get_world_3d().direct_space_state.intersect_shape(query,64):
		var enemy := hit.collider as NormalZombie
		if enemy == null or enemy.health.is_dead: continue
		if Vector2(enemy.global_position.x-global_position.x,enemy.global_position.z-global_position.z).length() > item.blast_radius: continue
		var ray := PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*0.25,enemy.global_position+Vector3.UP,1)
		if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty(): continue
		enemy.apply_ammo_effect(item)
		hits += 1
	var pulse = preload("res://scripts/effects/impact_ring.gd").new()
	get_parent().add_child(pulse)
	pulse.global_position = global_position
	pulse.burst(item.blast_radius, Color(0.3,0.85,1,0.85))
	if item.impact_vfx != null:
		var shards := item.impact_vfx.instantiate() as Node3D
		get_parent().add_child(shards)
		shards.global_position = global_position
		shards.scale = Vector3.ONE*2.0
	detonated.emit(hits)
	queue_free()
	return hits
