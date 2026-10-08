class_name RiflePose
extends SkeletonModifier3D
## Weapon-specific arm, palm and torso poses layered after the locomotion clips.
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
var hold_weight := 0.0
var reload_hand_weight := 0.0
var reload_progress := 0.0
var visual_recoil := 0.0
var _recoil_velocity := 0.0
var _impact := 0.0
var _clock := 0.0
var _lean := Vector2.ZERO
var _previous_velocity := Vector3.ZERO
var _previous_yaw := 0.0
var _presentation_weapon: Node3D
var _presentation_parts: Dictionary = {}
var _bones: Dictionary = {}
var _grip_rotations: Dictionary = {}
var shoulder_error := 0.0

# Ready, anticipation, contact, follow-through. Times come from WeaponRuntime;
# the last segment returns to ready at the unchanged swing completion time.
# angles = pitch/yaw/roll in degrees, body = pitch/twist/roll in radians.
# free = small counterbalance offset from the animated free wrist, not a grasp.
const MELEE_POSES := {
	WeaponData.PoseStyle.BAT: [
		{"angles":Vector3(-52,-22,-12), "reach":Vector3.ZERO, "free":Vector3.ZERO, "body":Vector3(0,-0.06,0)},
		{"angles":Vector3(-58,-82,-25), "reach":Vector3(-0.10,0.10,-0.10), "free":Vector3.ZERO, "body":Vector3(-0.025,-0.25,-0.035)},
		{"angles":Vector3(-3,-3,-8), "reach":Vector3(0.11,-0.015,0.08), "free":Vector3.ZERO, "body":Vector3(0.045,0.10,0.025)},
		{"angles":Vector3(20,78,8), "reach":Vector3(0.25,-0.07,0.03), "free":Vector3.ZERO, "body":Vector3(0.025,0.30,0.04)}],
	WeaponData.PoseStyle.SWORD: [
		{"angles":Vector3(-52,-28,-15), "reach":Vector3.ZERO, "free":Vector3.ZERO, "body":Vector3(0,-0.05,0)},
		{"angles":Vector3(-44,-86,-36), "reach":Vector3(-0.045,0.13,-0.07), "free":Vector3(0.035,0.055,-0.055), "body":Vector3(-0.02,-0.21,-0.02)},
		{"angles":Vector3(-6,-2,-18), "reach":Vector3(0.12,0.015,0.13), "free":Vector3(0,0.11,0.035), "body":Vector3(0.025,0.10,0.015)},
		{"angles":Vector3(24,80,-30), "reach":Vector3(0.36,-0.075,0.065), "free":Vector3(0.055,0.035,-0.075), "body":Vector3(0.035,0.27,0.025)}],
	WeaponData.PoseStyle.KNIFE: [
		{"angles":Vector3(-55,-20,25), "reach":Vector3.ZERO, "free":Vector3.ZERO, "body":Vector3(0,-0.06,0)},
		{"angles":Vector3(-65,-48,35), "reach":Vector3(-0.025,0.025,-0.055), "free":Vector3(0.015,0.035,-0.025), "body":Vector3(-0.005,-0.12,-0.01)},
		{"angles":Vector3(-4,8,62), "reach":Vector3(0.05,0.005,0.14), "free":Vector3(-0.015,0.08,0.055), "body":Vector3(0.025,0.08,0.005)},
		{"angles":Vector3(12,48,75), "reach":Vector3(0.17,-0.035,0.08), "free":Vector3(0.025,0.04,0.015), "body":Vector3(0.015,0.14,0.01)}]
}

func setup(controller: WeaponController, player: PlayerController) -> void:
	weapons = controller
	actor = player
	_previous_yaw = actor.visual.rotation.y
	weapons.melee_hit.connect(func() -> void: _impact = minf(_impact+0.6,1.0))
	for bone in ["Body","Torso","Foot.L","Foot.R","UpperArm.R","LowerArm.R","Middle1.R","Middle2.R","Index2.R","Pinky2.R","UpperArm.L","LowerArm.L","Middle1.L","Middle2.L","Index2.L","Pinky2.L"]:
		_bones[bone] = get_skeleton().find_bone(bone)
	# Start from the authored Gun hand pose, then close its fingers and align
	# the shared wrist without editing imported animation or skeleton data.
	var grip:=player.visual.animation_player.get_animation("CharacterArmature|Idle_Gun")
	for track in grip.get_track_count():
		var path:=grip.track_get_path(track)
		if path.get_subname_count()==0 or grip.track_get_type(track)!=Animation.TYPE_ROTATION_3D: continue
		var bone:=String(path.get_subname(0))
		if not (bone.begins_with("Pinky") or bone.begins_with("Middle") or bone.begins_with("Index") or bone.begins_with("Thumb") or bone.begins_with("Ring")): continue
		var index:=get_skeleton().find_bone(bone)
		if index>=0:
			_grip_rotations[index]=grip.rotation_track_interpolate(track,0.0)
			_bones[bone]=index

func tick(delta: float) -> void:
	_clock += delta
	# Critically damped angular spring, independent of the original gameplay recoil field.
	var spring := _recoil_velocity+28.0*visual_recoil
	var decay := exp(-28.0*delta)
	visual_recoil = (visual_recoil+spring*delta)*decay
	_recoil_velocity = (_recoil_velocity-28.0*spring*delta)*decay
	_impact *= exp(-22.0*delta)
	hold_weight = move_toward(hold_weight,1.0 if actor.visual.combat_ready else 0.0,delta*8.0)
	var local_velocity := actor.visual.global_basis.orthonormalized().inverse()*actor.velocity
	var acceleration := actor.visual.global_basis.orthonormalized().inverse()*(actor.velocity-_previous_velocity)/maxf(delta,0.0001)
	var turn_rate := wrapf(actor.visual.rotation.y-_previous_yaw,-PI,PI)/maxf(delta,0.0001)
	var goal_lean := Vector2(clampf(local_velocity.z*0.006+acceleration.z*0.001,-0.055,0.055),clampf(-turn_rate*0.018-local_velocity.x*0.008,-0.065,0.065))
	_lean = _lean.lerp(goal_lean,1.0-exp(-9.0*delta))
	_previous_velocity = actor.velocity
	_previous_yaw = actor.visual.rotation.y
	var hand_goal := 0.0
	reload_progress = 0
	var melee := weapons.current != null and weapons.current.data.is_melee()
	aim_weight = move_toward(aim_weight, 1.0 if actor.camera_rig.is_aiming and not melee else 0.0, delta * 12)
	if not actor.visual.combat_ready:
		aim_pitch = lerpf(aim_pitch,0.0,1.0-exp(-18.0*delta))
		aim_yaw = lerpf(aim_yaw,0.0,1.0-exp(-18.0*delta))
	recoil = maxf(0,recoil-delta*9)
	reload_weight = 0
	if weapons.current != null and weapons.current.is_reloading:
		var progress := 1.0-weapons.current.reload_remaining/weapons.current.data.reload_time
		reload_weight = sin(clampf(progress,0,1)*PI)
		reload_progress = clampf(progress,0,1)
		hand_goal = smoothstep(0.06,0.24,progress)*(1.0-smoothstep(0.66,0.90,progress))
	reload_hand_weight = move_toward(reload_hand_weight,hand_goal,delta*10.0)
	var velocity := actor.visual.global_basis.inverse() * actor.velocity
	var goal := 0.0
	if actor.camera_rig.is_aiming and Vector2(velocity.x,velocity.z).length() > 0.2:
		goal = atan2(velocity.x,velocity.z)
		if absf(goal) > PI/2: goal -= signf(goal)*PI
		goal = clampf(goal,-deg_to_rad(70),deg_to_rad(70))
	leg_yaw = lerpf(leg_yaw,goal,1.0-exp(-14*delta))

func kick() -> void:
	recoil = 1.0
	_recoil_velocity = minf(_recoil_velocity+3.6,5.0)

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
	aim_pitch = clampf(-atan2(local.y,Vector2(local.x,local.z).length()),-deg_to_rad(60),deg_to_rad(60))*aim_weight
	var pitch := deg_to_rad(data.ready_pitch_degrees)*(1.0-aim_weight) + aim_pitch + reload_weight*deg_to_rad(30) - recoil*deg_to_rad(2.5)
	var basis := actor.visual.global_basis.orthonormalized() * Basis(Vector3.UP,aim_yaw-reload_weight*0.1) * Basis(Vector3.RIGHT,pitch) * Basis(Vector3.FORWARD,reload_weight*0.18)
	var shoulder_rest := weapons.visual.get_node_or_null("ShoulderRest") as Node3D
	var stock_position := Vector3.ZERO
	var shoulder_anchor := Vector3.ZERO
	if shoulder_rest != null:
		var authored: Transform3D = _presentation_parts.get(shoulder_rest,shoulder_rest.transform)
		stock_position = authored.origin
		shoulder_anchor = _point("UpperArm.R")+actor.visual.global_basis.orthonormalized()*Vector3(0.02,0.015,0.025)
		point = point.lerp(shoulder_anchor-basis*stock_position,aim_weight*(1.0-reload_hand_weight))
	# Aim about the shoulder pivot, accounting for the bore's height above it.
	# A closed solution avoids oscillation with long barrels and nearby ground.
	var pivot := shoulder_anchor if shoulder_rest != null else point
	var bore_offset := weapons.muzzle.position-stock_position if shoulder_rest != null else weapons.muzzle.position
	var to_target := target-pivot
	if aim_weight > 0.99 and reload_weight == 0 and recoil == 0 and to_target.length() > maxf(1.2,bore_offset.length()+0.12) and absf(atan2(local.x,local.z)) < deg_to_rad(65) and absf(aim_pitch) <= deg_to_rad(60):
		var distance := to_target.length()
		var bore_pitch := asin(clampf(bore_offset.y/distance,-1.0,1.0))
		var horizontal := sqrt(maxf(0.001,distance*distance-bore_offset.y*bore_offset.y))
		var bore_yaw := -asin(clampf(bore_offset.x/horizontal,-1.0,1.0))
		basis = Basis.looking_at(to_target.normalized(),Vector3.UP,true)*Basis(Vector3.RIGHT,bore_pitch)*Basis(Vector3.UP,bore_yaw)
		if shoulder_rest != null: point = shoulder_anchor-basis*stock_position
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
	if actor == null or actor.health.is_dead: return
	_pose_body()
	if not is_instance_valid(weapons.visual): return
	_cache_presentation_parts()
	_restore_presentation_parts()
	if hold_weight <= 0.001: return
	update_socket()
	_apply_presentation()
	_apply_fingers()
	var primary := weapons.visual.get_node_or_null("PrimaryGrip") as Node3D
	var support := weapons.visual.get_node_or_null("SecondaryGrip") as Node3D
	if support == null: support = weapons.visual.get_node_or_null("SupportGrip") as Node3D
	if primary == null: return
	var torso := actor.visual.to_local(_point("Torso"))
	# Markers identify the centre of the grasp, rather than the wrist. This rig
	# shares the wrist across four finger roots, which can be posed as one hand.
	var right_frame := _grip_frame(primary, "R")
	var right_wrist := primary.global_position-_grasp_offset(right_frame)
	_solve_arm("R",right_wrist,actor.visual.to_global(torso+Vector3(-0.43,-0.30,-0.06)))
	_pose_hand("R",right_frame)
	right_error = (_point("Middle1.R")+_grasp_offset(right_frame)).distance_to(primary.global_position)
	if not weapons.current.data.two_handed:
		# A free hand follows the authored relaxed wrist and finger pose. Never
		# send it through the weapon-grasp frame or the magazine-hand solver.
		var free_target := _pose_free_arm(weapons.current.data)
		left_error = _point("Middle1.L").distance_to(free_target)
	elif support != null:
		var support_target := support.global_position
		var support_frame := _grip_frame(support,"L")
		var magazine := weapons.visual.get_node_or_null("MagazineGrip") as Node3D
		if magazine != null:
			support_target = support_target.lerp(magazine.global_position,reload_hand_weight)
			support_frame = support_frame.slerp(_grip_frame(magazine,"L"),reload_hand_weight)
			var withdraw := sin(smoothstep(0.25,0.60,reload_progress)*PI)*reload_hand_weight
			support_target += actor.visual.global_basis.orthonormalized()*Vector3(0,-0.075,0.025)*withdraw
		var left_wrist := support_target-_grasp_offset(support_frame)
		_solve_arm("L",left_wrist,actor.visual.to_global(torso+Vector3(0.46,-0.13,0.015)))
		_pose_hand("L",support_frame)
		left_error = (_point("Middle1.L")+_grasp_offset(support_frame)).distance_to(support_target)
	shoulder_error = 0.0
	var stock := weapons.visual.get_node_or_null("ShoulderRest") as Node3D
	if stock != null:
		var anchor := _point("UpperArm.R")+actor.visual.global_basis.orthonormalized()*Vector3(0.02,0.015,0.025)
		shoulder_error = anchor.distance_to(stock.global_position)


func _apply_fingers() -> void:
	var skeleton := get_skeleton()
	for bone: int in _grip_rotations:
		var weight := hold_weight
		if skeleton.get_bone_name(bone).ends_with(".L"):
			if not weapons.current.data.two_handed: continue
			weight *= 1.0-reload_hand_weight*0.70
		skeleton.set_bone_pose_rotation(bone,skeleton.get_bone_pose_rotation(bone).slerp(_grip_rotations[bone],weight))


func _pose_free_arm(data: WeaponData) -> Vector3:
	var wrist := _point("Middle1.L")
	var motion: Vector3 = _melee_frame(data)["free"]
	if motion.is_zero_approx(): return wrist
	# Offset the live idle/walk/run pose. The forearm carries the hand with it,
	# retaining the authored wrist alignment and relaxed fingers throughout.
	var frame := actor.visual.global_basis.orthonormalized()
	var shoulder := _point("UpperArm.L")
	var elbow := _point("LowerArm.L")
	var length := shoulder.distance_to(elbow)+elbow.distance_to(wrist)
	var target := wrist+frame*motion
	target = shoulder+(target-shoulder).limit_length(length*0.94)
	_solve_arm("L",target,elbow+frame*Vector3(0.025,-0.015,-0.035))
	return target

func _grip_frame(marker: Node3D, side: String) -> Basis:
	var forward := marker.global_basis.z.normalized()
	var normal := marker.global_basis.x.normalized()*(1.0 if side=="R" else -1.0)
	return Basis(normal,forward.cross(normal).normalized(),forward)

func _grasp_offset(frame: Basis) -> Vector3:
	return frame.z*0.075+frame.x*0.018

func _pose_hand(side: String, target: Basis) -> void:
	var skeleton := get_skeleton()
	var wrist := _point("Middle1."+side)
	var forward := (_point("Middle2."+side)-wrist).normalized()
	var normal := (_point("Index2."+side)-wrist).cross(_point("Pinky2."+side)-wrist).normalized()
	if side == "L": normal = -normal
	normal = normal.slide(forward).normalized()
	if normal.is_zero_approx(): return
	var source := Basis(normal,forward.cross(normal).normalized(),forward)
	var turn := Basis(Quaternion.IDENTITY.slerp((target*source.inverse()).get_rotation_quaternion(),hold_weight))
	var inverse := skeleton.global_transform.affine_inverse()
	for finger in ["Pinky","Middle","Index","Thumb"]:
		var bone: int = _bones[finger+"1."+side]
		var pose := skeleton.global_transform*skeleton.get_bone_global_pose(bone)
		pose.basis = turn*pose.basis
		skeleton.set_bone_global_pose(bone,inverse*pose)
	# Imported Gun clips leave Matt's fingers spread open. Close the two
	# phalanges around the handle, retaining an index finger at the trigger.
	for finger in ["Pinky","Middle","Index"]:
		var trigger: bool = finger=="Index" and side=="R" and not weapons.current.data.is_melee()
		var curl := deg_to_rad(48.0 if trigger else 70.0)
		for segment in [2,3]:
			var name: String = finger+str(segment)+"."+side
			if not _bones.has(name): continue
			var bone: int = _bones[name]
			var pose := skeleton.global_transform*skeleton.get_bone_global_pose(bone)
			var angle := curl if segment==2 else curl+deg_to_rad(65)
			var direction := target.z*cos(angle)+target.x*sin(angle)
			_rotate_joint(name,pose.basis.y,direction)

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
	var pitch := clampf(aim_pitch*0.5,-0.35,0.45)-recoil*0.025+_lean.x-visual_recoil*0.40
	var hurt := actor.visual.hurt_weight
	pitch += hurt*0.10
	var body_motion := Vector3.ZERO
	if weapons.current != null and weapons.current.data.is_melee():
		body_motion = _melee_frame(weapons.current.data)["body"]*hold_weight
	pitch += body_motion.x
	var twist := body_motion.y
	var roll_axis := actor.visual.global_basis.z.normalized()
	torso.basis = Basis(roll_axis,_lean.y+hurt*0.055+body_motion.z)*Basis(Vector3.UP,twist)*torso.basis
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
	pose.basis = Basis(Quaternion.IDENTITY.slerp(Quaternion(from.normalized(),to.normalized()),hold_weight)) * pose.basis
	skeleton.set_bone_global_pose(index, inverse * pose)


func _cache_presentation_parts() -> void:
	if _presentation_weapon == weapons.visual: return
	_presentation_weapon = weapons.visual
	_presentation_parts.clear()
	for child in weapons.visual.get_children():
		# Muzzle/Flash remain on the unchanged canonical shot transform.
		if child is Node3D and child.name != &"Muzzle": _presentation_parts[child] = child.transform

func _restore_presentation_parts() -> void:
	for part: Node3D in _presentation_parts:
		if is_instance_valid(part): part.transform = _presentation_parts[part]

func _apply_presentation() -> void:
	var cosmetic := Transform3D.IDENTITY
	if weapons.current.data.is_melee():
		var data := weapons.current.data
		var pose := _melee_frame(data)
		var angles: Vector3 = pose["angles"]*PI/180.0
		var torso := actor.visual.to_local(_point("Torso"))
		var basis := actor.visual.global_basis.orthonormalized()*Basis(Vector3.UP,angles.y-_impact*0.04)*Basis(Vector3.RIGHT,angles.x)*Basis(Vector3.BACK,angles.z)
		var desired := Transform3D(basis,actor.visual.to_global(torso+data.ready_hold_offset+pose["reach"]))
		cosmetic = weapons.get_socket().global_transform.affine_inverse()*desired
	else:
		var idle_sway := sin(_clock*1.8)*0.003*(1.0-aim_weight)
		var reload_turn := reload_hand_weight*0.11
		var settle := sin(reload_progress*PI*2.0)*0.018*reload_hand_weight
		cosmetic.basis = Basis(Vector3.RIGHT,-visual_recoil+settle)*Basis(Vector3.FORWARD,idle_sway+reload_turn)
		cosmetic.origin = Vector3(0,-reload_hand_weight*0.012,-visual_recoil*0.36)
	for part: Node3D in _presentation_parts:
		part.transform = cosmetic*_presentation_parts[part]

func _melee_frame(data: WeaponData) -> Dictionary:
	var keys: Array = MELEE_POSES.get(data.pose_style,MELEE_POSES[WeaponData.PoseStyle.BAT])
	if not weapons.current.is_swinging: return keys[0]
	var contact := data.melee_hit_delay
	var follow := contact+(data.melee_swing_duration-contact)*0.40
	var times := [0.0,contact*0.44,contact,follow,data.melee_swing_duration]
	var elapsed := clampf(weapons.current.swing_elapsed,0.0,data.melee_swing_duration)
	var index := 0
	while index < 3 and elapsed > times[index+1]: index += 1
	var duration: float = times[index+1]-times[index]
	var u: float = clampf((elapsed-times[index])/duration,0.0,1.0)
	var result := {}
	for field in ["angles","reach","free","body"]:
		var a: Vector3 = keys[index][field]
		var b: Vector3 = keys[(index+1)%4][field]
		var through: Vector3 = (keys[3][field]-keys[1][field])/(follow-times[1])
		var start := through if index == 2 else Vector3.ZERO
		var end := through if index == 1 else Vector3.ZERO
		result[field] = _vector_arc(a,b,duration,u,start,end)
	return result


func _vector_arc(a: Vector3, b: Vector3, duration: float, t: float, start: Vector3, end: Vector3) -> Vector3:
	var t2 := t*t
	var t3 := t2*t
	return (2*t3-3*t2+1)*a+(t3-2*t2+t)*duration*start+(-2*t3+3*t2)*b+(t3-t2)*duration*end
