class_name PlayerVisual
extends Node3D

var animation_player: AnimationPlayer
var current_state: StringName = &""
var current_clip: StringName = &""
var combat_ready := false
# Matt has a short walk stride. Runtime stance samples favor a modest run cadence;
# the walk cap avoids frantic steps while reducing drift at the existing speeds.
var _motion_rate := 1.0
@export var walk_cycle_speed: float = 1.31
@export var run_cycle_speed: float = 6.0


func _ready() -> void:
	animation_player = find_child("AnimationPlayer", true, false) as AnimationPlayer
	# Matt ships with a knife; gameplay supplies separate equipment visuals.
	var knife := find_child("Knife", true, false) as Node3D
	if knife != null:
		knife.hide()
	if animation_player != null:
		for library_name in animation_player.get_animation_library_list():
			var library := animation_player.get_animation_library(library_name).duplicate(true) as AnimationLibrary
			animation_player.remove_animation_library(library_name)
			animation_player.add_animation_library(library_name, library)
		for clip in ["Idle", "Walk", "Run", "Idle_Gun", "Walk_Gun", "Run_Gun"]:
			var key: String = "CharacterArmature|" + clip
			if animation_player.has_animation(key):
				animation_player.get_animation(key).loop_mode = Animation.LOOP_LINEAR
	set_motion(false, false)


func set_motion(moving: bool, sprinting: bool, dead: bool = false, motion_velocity: Vector3 = Vector3.ZERO) -> void:
	var state: StringName = &"Run" if sprinting else (&"Walk" if moving else &"Idle")
	if dead:
		state = &"Death"
	var actor := get_parent() as PlayerController
	var mode := actor.get_node_or_null("GameplayMode") as GameplayModeController
	var equipment := actor.get_node_or_null("EquipmentLoadout") as EquipmentLoadout
	combat_ready = not dead and mode != null and not mode.is_farming() and equipment != null and equipment.get_selected_weapon() != null
	current_state = state
	if animation_player != null:
		var weapons := actor.get_node_or_null("WeaponController") as WeaponController
		var melee := combat_ready and weapons != null and weapons.current != null and weapons.current.data.is_melee()
		var clip := "CharacterArmature|" + String(state) + ("_Gun" if combat_ready and not melee else "")
		var speed := Vector2(motion_velocity.x, motion_velocity.z).length()
		var rate := clampf(speed / (run_cycle_speed if sprinting else walk_cycle_speed), 0.1, 2.2) if moving and not dead else 1.0
		# Reversed Walk gives a backward step while the character still faces the target.
		if moving and not sprinting and actor.camera_rig.is_aiming and motion_velocity.dot(global_basis.z) < -0.1:
			rate *= -1.0
		_motion_rate = move_toward(_motion_rate,rate,12.0*actor.get_physics_process_delta_time()) if moving and not dead else 1.0
		if melee and weapons.current.is_swinging:
			clip = String(weapons.current.data.melee_animation)
			current_state = &"Melee"
			if animation_player.has_animation(clip):
				_motion_rate = animation_player.get_animation(clip).length/weapons.current.data.melee_swing_duration
		animation_player.speed_scale = _motion_rate
		if animation_player.has_animation(clip):
			if current_clip != clip:
				current_clip = clip
				animation_player.play(clip, 0.06 if current_state == &"Melee" else (0.14 if state == &"Idle" else 0.12), 1.0, rate < 0 and current_state != &"Melee")
