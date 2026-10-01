class_name RiflePose
extends SkeletonModifier3D
## Small two-arm pose adjustment applied after Matt's existing movement clips.
## No rest bone, imported animation, physics-root transform or shot timing is changed.

var weapons: WeaponController
var actor: PlayerController
var right_error := 0.0
var left_error := 0.0
var aim_weight := 0.0
var recoil := 0.0
var aim_pitch := 0.0
var aim_yaw := 0.0
var leg_yaw := 0.0
var reload_weight := 0.0
var _bones: Dictionary = {}
var _grip_rotations: Dictionary = {}

func setup(controller: WeaponController, player: PlayerController) -> void:
	weapons = controller
	actor = player
	for bone in ["Body","Torso","Foot.L","Foot.R","UpperArm.R","LowerArm.R","Middle1.R","UpperArm.L","LowerArm.L","Middle1.L"]:
		_bones[bone] = get_skeleton().find_bone(bone)
	# Slash's free left hand is open. Reuse the existing Gun grip rotations for
	# the bat fingers; only presentation poses change, never imported/rest data.
	var grip:=player.visual.animation_player.get_animation("CharacterArmature|Idle_Gun")
	for track in grip.get_track_count():
		var path:=grip.track_get_path(track)
		if path.get_subname_count()==0 or grip.track_get_type(track)!=Animation.TYPE_ROTATION_3D: continue
		var bone:=String(path.get_subname(0))
		if not (bone.begins_with("Pinky") or bone.begins_with("Middle") or bone.begins_with("Index") or bone.begins_with("Thumb")): continue
		var index:=get_skeleton().find_bone(bone)
		if index>=0: _grip_rotations[index]=grip.rotation_track_interpolate(track,0.0)

func tick(delta: float) -> void:
	var melee := weapons.current != null and weapons.current.data.is_melee()
	aim_weight = move_toward(aim_weight, 1.0 if actor.camera_rig.is_aiming and not melee else 0.0, delta * 12)
	recoil = maxf(0,recoil-delta*9)
	reload_weight = 0
	if weapons.current != null and weapons.current.is_reloading:
		var progress := 1.0-weapons.current.reload_remaining/weapons.current.data.reload_time
		reload_weight = sin(clampf(progress,0,1)*PI)
	var velocity := actor.visual.global_basis.inverse() * actor.velocity
	var goal := 0.0
	if actor.camera_rig.is_aiming and Vector2(velocity.x,velocity.z).length() > 0.2:
		goal = atan2(velocity.x,velocity.z)
		if absf(goal) > PI/2: goal -= signf(goal)*PI
		goal = clampf(goal,-deg_to_rad(70),deg_to_rad(70))
	leg_yaw = lerpf(leg_yaw,goal,1.0-exp(-14*delta))

func kick() -> void:
	recoil = 1.0

func update_socket() -> void:
	if actor == null or weapons.visual == null or weapons.current == null: return
	var skeleton := get_skeleton()
	var torso := actor.visual.to_local(skeleton.global_transform * skeleton.get_bone_global_pose(_bones["Torso"]).origin)
	var data := weapons.current.data
	if data.is_melee():
		_update_melee_socket(data,torso)
		return
	var offset := data.ready_hold_offset.lerp(data.aim_hold_offset, aim_weight)
	var point := actor.visual.to_global(torso + offset)
	var target := actor.aim_ray.aim_point
	var direction := target-point
	# Very near/behind-barrel targets keep a forward hold instead of folding into the body.
	if direction.length() < 1.2 or direction.normalized().dot(actor.aim_ray.aim_direction) < 0.15:
		direction = actor.aim_ray.aim_direction
	var local := actor.visual.global_basis.orthonormalized().inverse() * direction.normalized()
	aim_yaw = clampf(atan2(local.x,local.z),-deg_to_rad(70),deg_to_rad(70))*aim_weight
	aim_pitch = clampf(-atan2(local.y,Vector2(local.x,local.z).length()),-deg_to_rad(45),deg_to_rad(60))*aim_weight
	var pitch := deg_to_rad(data.ready_pitch_degrees)*(1.0-aim_weight) + aim_pitch + reload_weight*deg_to_rad(30) - recoil*deg_to_rad(2.5)
	var basis := actor.visual.global_basis.orthonormalized() * Basis(Vector3.UP,aim_yaw-reload_weight*0.1) * Basis(Vector3.RIGHT,pitch) * Basis(Vector3.FORWARD,reload_weight*0.18)
	# Barrel is above the socket; converge its visible axis on ordinary-distance targets.
	if aim_weight > 0.99 and reload_weight == 0 and recoil == 0 and point.distance_to(target) > 1.2 and absf(atan2(local.x,local.z)) < deg_to_rad(65) and absf(aim_pitch) < deg_to_rad(44):
		for iteration in 3:
			var muzzle_point := point+basis*weapons.muzzle.position
			basis = Basis.looking_at((target-muzzle_point).normalized(),Vector3.UP,true)
	point -= basis.z*recoil*0.035
	weapons.get_socket().global_transform = Transform3D(basis,point)

func _update_melee_socket(data: WeaponData, torso: Vector3) -> void:
	aim_yaw = 0
	aim_pitch = 0
	var pitch := deg_to_rad(data.ready_pitch_degrees)
	var yaw := deg_to_rad(-15)
	var state := weapons.current
	if state.is_swinging:
		var elapsed := state.swing_elapsed
		if elapsed <= data.melee_hit_delay:
			var progress := clampf(elapsed/data.melee_hit_delay,0,1)
			yaw = lerpf(deg_to_rad(-85),0,progress)
			pitch = lerpf(deg_to_rad(-35),0,progress)
		else:
			var progress := clampf((elapsed-data.melee_hit_delay)/(data.melee_swing_duration-data.melee_hit_delay),0,1)
			if progress < 0.5:
				yaw = lerpf(0,deg_to_rad(70),progress*2)
				pitch = lerpf(0,deg_to_rad(12),progress*2)
			else:
				var settle := smoothstep(0.5,1.0,progress)
				yaw = lerpf(deg_to_rad(70),deg_to_rad(-15),settle)
				pitch = lerpf(deg_to_rad(12),deg_to_rad(data.ready_pitch_degrees),settle)
	var basis := actor.visual.global_basis.orthonormalized()*Basis(Vector3.UP,yaw)*Basis(Vector3.RIGHT,pitch)
	weapons.get_socket().global_transform = Transform3D(basis,actor.visual.to_global(torso+data.ready_hold_offset))

func _process_modification_with_delta(_delta: float) -> void:
	if actor == null or not actor.visual.combat_ready or not is_instance_valid(weapons.visual): return
	update_socket()
	_pose_body()
	if weapons.current.data.is_melee():
		for bone in _grip_rotations:
			get_skeleton().set_bone_pose_rotation(bone,_grip_rotations[bone])
	var primary := weapons.visual.get_node_or_null("PrimaryGrip") as Node3D
	var support := weapons.visual.get_node_or_null("SecondaryGrip") as Node3D
	if support == null: support = weapons.visual.get_node_or_null("SupportGrip") as Node3D
	if primary == null or support == null: return
	_solve_arm("R", primary.global_position, actor.visual.to_global(Vector3(-0.5,0.6,-0.08)))
	var support_target := support.global_position
	var magazine := weapons.visual.get_node_or_null("MagazineGrip") as Node3D
	if magazine != null: support_target = support_target.lerp(magazine.global_position,reload_weight)
	_solve_arm("L", support_target, actor.visual.to_global(Vector3(0.5,0.6,0.04)))
	right_error = _point("Middle1.R").distance_to(primary.global_position)
	left_error = _point("Middle1.L").distance_to(support_target)

func _pose_body() -> void:
	var skeleton := get_skeleton()
	var inverse := skeleton.global_transform.affine_inverse()
	var torso := skeleton.global_transform * skeleton.get_bone_global_pose(_bones["Torso"])
	var pivot := _point("Body")
	# Foot controllers are Root siblings of Body in this particular imported rig.
	# Rotate all three together, then restore the torso to keep upper/lower body coherent.
	var turn := Basis(Vector3.UP,leg_yaw)
	for bone in ["Body","Foot.L","Foot.R"]:
		var pose := skeleton.global_transform * skeleton.get_bone_global_pose(_bones[bone])
		pose.origin = pivot+turn*(pose.origin-pivot)
		pose.basis = turn*pose.basis
		skeleton.set_bone_global_pose(_bones[bone],inverse*pose)
	var right := actor.visual.global_basis.x.normalized()
	var pitch := clampf(aim_pitch*0.5,-0.35,0.45)-recoil*0.025
	torso.basis = Basis(Vector3.UP,aim_yaw*0.55)*Basis(right,pitch)*torso.basis
	skeleton.set_bone_global_pose(_bones["Torso"],inverse*torso)

func _point(bone: String) -> Vector3:
	var skeleton := get_skeleton()
	return skeleton.global_transform * skeleton.get_bone_global_pose(_bones[bone]).origin

func _solve_arm(side: String, target: Vector3, pole: Vector3) -> void:
	var upper := "UpperArm." + side
	var lower := "LowerArm." + side
	var wrist := "Middle1." + side
	var shoulder := _point(upper)
	var elbow := _point(lower)
	var hand := _point(wrist)
	var a := shoulder.distance_to(elbow)
	var b := elbow.distance_to(hand)
	var distance := clampf(shoulder.distance_to(target), absf(a-b)+0.001, a+b-0.002)
	var direction := (target-shoulder).normalized()
	var bend := (pole-shoulder).slide(direction).normalized()
	var along := (a*a-b*b+distance*distance)/(2*distance)
	var height := sqrt(maxf(0,a*a-along*along))
	var elbow_target := shoulder + direction*along + bend*height
	_rotate_joint(upper, elbow-shoulder, elbow_target-shoulder)
	elbow = _point(lower)
	hand = _point(wrist)
	_rotate_joint(lower, hand-elbow, (shoulder+direction*distance)-elbow)

func _rotate_joint(bone: String, from: Vector3, to: Vector3) -> void:
	if from.is_zero_approx() or to.is_zero_approx(): return
	var skeleton := get_skeleton()
	var inverse := skeleton.global_transform.affine_inverse()
	var index: int = _bones[bone]
	var pose := skeleton.global_transform * skeleton.get_bone_global_pose(index)
	pose.basis = Basis(Quaternion(from.normalized(),to.normalized())) * pose.basis
	skeleton.set_bone_global_pose(index, inverse * pose)
