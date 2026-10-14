extends SkeletonModifier3D
## Additive upper-body poses preserve the imported clip's planted feet.
var boss: Node
var weight := 0.0
func _process_modification() -> void:
	if not is_instance_valid(boss) or boss.health.is_dead: return
	var skeleton := get_skeleton()
	var phase: int = boss.charge_phase
	weight = move_toward(weight,1.0 if phase in [1,2,4,5] else 0.0,get_physics_process_delta_time()*5.0)
	if weight <= 0: return
	var leap := phase in [4,5]
	for name in ["Torso","UpperArm.L","UpperArm.R","LowerArm.L","LowerArm.R"]:
		var bone := skeleton.find_bone(name)
		if bone < 0: continue
		var rotation := Vector3.ZERO
		if name == "Torso": rotation.x = -0.10 if leap else 0.15
		elif name.begins_with("UpperArm"):
			rotation.x = -0.35 if leap else -0.18
			rotation.z = (-0.16 if name.ends_with(".L") else 0.16) if leap else 0.0
		else: rotation.x = -0.22 if leap else -0.16
		var current := skeleton.get_bone_pose_rotation(bone)
		skeleton.set_bone_pose_rotation(bone,current*Quaternion.from_euler(rotation*weight))
	# Read the final modified pose, including the upper-body lean, for eyes/hurtboxes.
	boss._update_eyes()
	boss._update_hitboxes()
