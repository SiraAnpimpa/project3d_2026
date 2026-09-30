class_name PlayerVisual
extends Node3D

var animation_player: AnimationPlayer
var current_state: StringName = &""


func _ready() -> void:
	animation_player = find_child("AnimationPlayer", true, false) as AnimationPlayer
	# Matt ships with a knife attached to his hand. This prototype is unarmed.
	var knife := find_child("Knife", true, false) as Node3D
	if knife != null:
		knife.hide()
	if animation_player != null:
		for library_name in animation_player.get_animation_library_list():
			var library := animation_player.get_animation_library(library_name).duplicate(true) as AnimationLibrary
			animation_player.remove_animation_library(library_name)
			animation_player.add_animation_library(library_name, library)
		for clip in ["Idle", "Walk", "Run"]:
			var key: String = "CharacterArmature|" + clip
			if animation_player.has_animation(key):
				animation_player.get_animation(key).loop_mode = Animation.LOOP_LINEAR
	set_motion(false, false)


func set_motion(moving: bool, sprinting: bool, dead: bool = false) -> void:
	var state: StringName = &"Run" if sprinting else (&"Walk" if moving else &"Idle")
	if dead:
		state = &"Death"
	if state == current_state:
		return
	current_state = state
	if animation_player != null:
		var clip := "CharacterArmature|" + String(state)
		if animation_player.has_animation(clip):
			animation_player.play(clip, 0.2 if state == &"Idle" else 0.12)
