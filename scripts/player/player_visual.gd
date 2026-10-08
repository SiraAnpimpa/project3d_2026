class_name PlayerVisual
extends Node3D
## AnimationTree owns playback; imported clips remain immutable per-instance copies.
## Gameplay supplies velocity/action timers. Animation never commits damage or movement.
var animation_player: AnimationPlayer
var animation_tree: AnimationTree
var current_state: StringName = &""
var current_clip: StringName = &""
var combat_ready := false
var _motion_rate := 1.0
@export var walk_cycle_speed: float = 1.31
@export var run_cycle_speed: float = 6.0
var locomotion_speed := 0.0
var armed_weight := 0.0
var action_weight := 0.0
var hurt_weight := 0.0
var hurt_elapsed := 10.0
var hurt_strength := 0.0
var _last_hp := 100.0
var _was_dead := false

func _ready() -> void:
	animation_player = find_child("AnimationPlayer",true,false) as AnimationPlayer
	var knife := find_child("Knife",true,false) as Node3D
	if knife != null: knife.hide()
	if animation_player == null: return
	for name in animation_player.get_animation_library_list():
		var library := animation_player.get_animation_library(name).duplicate(true) as AnimationLibrary
		animation_player.remove_animation_library(name)
		animation_player.add_animation_library(name,library)
	for clip in ["Idle","Walk","Run","Idle_Gun","Walk_Gun","Run_Gun"]:
		animation_player.get_animation("CharacterArmature|"+clip).loop_mode = Animation.LOOP_LINEAR
	_build_tree()
	call_deferred("_bind_health")

func _clip(name: String) -> AnimationNodeAnimation:
	var node := AnimationNodeAnimation.new()
	node.animation = "CharacterArmature|"+name
	return node

func _space(suffix: String) -> AnimationNodeBlendSpace1D:
	var space := AnimationNodeBlendSpace1D.new()
	space.min_space = 0
	space.max_space = 7
	space.sync = true
	space.add_blend_point(_clip("Idle"+suffix),0,-1,&"Idle")
	space.add_blend_point(_clip("Walk"+suffix),4,-1,&"Walk")
	space.add_blend_point(_clip("Run"+suffix),7,-1,&"Run")
	return space

func _upper_blend(clip: String, keep_free_arm := false) -> AnimationNodeBlend2:
	var blend := AnimationNodeBlend2.new()
	blend.filter_enabled = true
	var skeleton := find_child("Skeleton3D",true,false) as Skeleton3D
	var torso := skeleton.find_bone("Torso")
	var free_shoulder := skeleton.find_bone("Shoulder.L")
	var animation := animation_player.get_animation("CharacterArmature|"+clip)
	for i in animation.get_track_count():
		var path := animation.track_get_path(i)
		if path.get_subname_count() == 0: continue
		var bone := skeleton.find_bone(path.get_subname(0))
		# Keep the free arm's locomotion underneath the melee action. The bat's
		# support arm is positioned by its grip solver after this blend.
		if keep_free_arm and free_shoulder >= 0:
			var arm_ancestor := bone
			while arm_ancestor >= 0 and arm_ancestor != free_shoulder:
				arm_ancestor = skeleton.get_bone_parent(arm_ancestor)
			if arm_ancestor == free_shoulder: continue
		var ancestor := bone
		while ancestor >= 0 and ancestor != torso:
			ancestor = skeleton.get_bone_parent(ancestor)
		if ancestor == torso:
			# Keep position/root/foot tracks on locomotion; overlay upper rotations only.
			if animation.track_get_type(i) == Animation.TYPE_ROTATION_3D: blend.set_filter_path(path,true)
	return blend

func _build_tree() -> void:
	var graph := AnimationNodeBlendTree.new()
	graph.add_node("Move",_space(""))
	graph.add_node("Gun",_space("_Gun"))
	var armed := AnimationNodeBlend2.new()
	armed.sync = true
	graph.add_node("Armed",armed)
	graph.connect_node("Armed",0,"Move")
	graph.connect_node("Armed",1,"Gun")
	graph.add_node("Cadence",AnimationNodeTimeScale.new())
	graph.connect_node("Cadence",0,"Armed")
	graph.add_node("Slash",_clip("Slash"))
	graph.add_node("SlashSeek",AnimationNodeTimeSeek.new())
	graph.connect_node("SlashSeek",0,"Slash")
	graph.add_node("Action",_upper_blend("Slash",true))
	graph.connect_node("Action",0,"Cadence")
	graph.connect_node("Action",1,"SlashSeek")
	graph.add_node("Hit",_clip("HitReact"))
	graph.add_node("HitSeek",AnimationNodeTimeSeek.new())
	graph.connect_node("HitSeek",0,"Hit")
	graph.add_node("Hurt",_upper_blend("HitReact"))
	graph.connect_node("Hurt",0,"Action")
	graph.connect_node("Hurt",1,"HitSeek")
	graph.add_node("Death",_clip("Death"))
	graph.add_node("DeathSeek",AnimationNodeTimeSeek.new())
	graph.connect_node("DeathSeek",0,"Death")
	graph.add_node("Alive",AnimationNodeBlend2.new())
	graph.connect_node("Alive",0,"Hurt")
	graph.connect_node("Alive",1,"DeathSeek")
	graph.connect_node("output",0,"Alive")
	animation_player.stop()
	animation_tree = AnimationTree.new()
	animation_tree.name = "CharacterBlendTree"
	add_child(animation_tree)
	animation_tree.anim_player = animation_tree.get_path_to(animation_player)
	animation_tree.root_node = animation_tree.get_path_to(animation_player.get_node(animation_player.root_node))
	animation_tree.tree_root = graph
	animation_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	animation_tree.active = true

func _bind_health() -> void:
	var health := get_parent().get_node("Health") as HealthComponent
	_last_hp = health.current_hp
	health.changed.connect(_health_changed)
	var weapons := get_parent().get_node("WeaponController") as WeaponController
	weapons.state_changed.connect(_cancel_visual_action)

func _cancel_visual_action() -> void:
	var weapons := get_parent().get_node("WeaponController") as WeaponController
	if weapons.current == null or not weapons.current.is_swinging:
		action_weight = 0
		animation_tree.set("parameters/Action/blend_amount",0.0)

func _health_changed(hp: float, _maximum: float) -> void:
	if hp > 0 and hp < _last_hp:
		hurt_strength = clampf((_last_hp-hp)/25.0,0.35,1.0)
		hurt_elapsed = 0
		animation_tree.set("parameters/HitSeek/seek_request",0.0)
	_last_hp = hp

func set_motion(moving: bool, sprinting: bool, dead: bool = false, motion_velocity: Vector3 = Vector3.ZERO) -> void:
	if animation_tree == null: return
	var actor := get_parent() as PlayerController
	var mode := actor.get_node_or_null("GameplayMode") as GameplayModeController
	var equipment := actor.get_node_or_null("EquipmentLoadout") as EquipmentLoadout
	var weapons := actor.get_node_or_null("WeaponController") as WeaponController
	combat_ready = not dead and mode != null and not mode.is_farming() and equipment != null and equipment.get_selected_weapon() != null
	var melee := combat_ready and weapons != null and weapons.current != null and weapons.current.data.is_melee()
	var dt := actor.get_physics_process_delta_time()
	var speed := Vector2(motion_velocity.x,motion_velocity.z).length()
	locomotion_speed = lerpf(locomotion_speed,speed,1.0-exp(-14.0*dt))
	var state: StringName = &"Run" if sprinting else &"Walk" if moving else &"Idle"
	var rate := clampf(speed/(run_cycle_speed if sprinting else walk_cycle_speed),0.1,2.2) if moving and not dead else 1.0
	if moving and not sprinting and actor.camera_rig.is_aiming and motion_velocity.dot(global_basis.z) < -0.1: rate *= -1
	_motion_rate = move_toward(_motion_rate,rate,12.0*dt)
	# Public cadence diagnostic for existing stance probes; the tree owns playback.
	animation_player.speed_scale = _motion_rate
	armed_weight = lerpf(armed_weight,1.0 if combat_ready and not melee else 0.0,1.0-exp(-12.0*dt))
	animation_tree.set("parameters/Move/blend_position",locomotion_speed)
	animation_tree.set("parameters/Gun/blend_position",locomotion_speed)
	animation_tree.set("parameters/Armed/blend_amount",armed_weight)
	animation_tree.set("parameters/Cadence/scale",_motion_rate)
	action_weight = 0
	if melee and weapons.current.is_swinging:
		var elapsed := weapons.current.swing_elapsed
		var duration := weapons.current.data.melee_swing_duration
		action_weight = smoothstep(0.0,0.035,elapsed)*(1.0-smoothstep(duration-0.10,duration,elapsed))
		var length := animation_player.get_animation(String(weapons.current.data.melee_animation)).length
		animation_tree.set("parameters/SlashSeek/seek_request",clampf(elapsed/duration,0,1)*length)
		state = &"Melee"
	hurt_elapsed += dt
	hurt_weight = hurt_strength*smoothstep(0.0,0.035,hurt_elapsed)*(1.0-smoothstep(0.10,0.34,hurt_elapsed)) if not dead else 0.0
	animation_tree.set("parameters/Action/blend_amount",action_weight if not dead else 0.0)
	animation_tree.set("parameters/Hurt/blend_amount",hurt_weight)
	if dead and not _was_dead: animation_tree.set("parameters/DeathSeek/seek_request",0.0)
	animation_tree.set("parameters/Alive/blend_amount",1.0 if dead else 0.0)
	_was_dead = dead
	current_state = &"Death" if dead else state
	current_clip = &"CharacterArmature|Death" if dead else weapons.current.data.melee_animation if state == &"Melee" else StringName("CharacterArmature|"+String(state)+("_Gun" if combat_ready and not melee else ""))
