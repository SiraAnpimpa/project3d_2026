extends SceneTree

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var actor := load("res://scenes/player/Player.tscn").instantiate() as PlayerController
	root.add_child(actor)
	actor.set_physics_process(false)
	var skeleton := actor.visual.find_child("Skeleton3D",true,false) as Skeleton3D
	var animation := actor.visual.animation_player
	print("AUDIT clips=", animation.get_animation_list(), " AnimationTrees=", actor.find_children("*","AnimationTree",true,false).size())
	print("AUDIT skeleton=", skeleton.get_path(), " scale=", skeleton.global_basis.get_scale())
	for index in skeleton.get_bone_count():
		print("AUDIT bone ",index," ",skeleton.get_bone_name(index)," parent=",skeleton.get_bone_parent(index)," rest=",skeleton.get_bone_global_rest(index).origin)
	for clip in animation.get_animation_list():
		if "Gun" not in clip and "Idle" not in clip and "Walk" not in clip and "Run" not in clip: continue
		animation.play(clip)
		animation.advance(0.2)
		print("AUDIT clip ",clip," length=",animation.current_animation_length)
		for bone in ["Spine","Chest","UpperArm.R","LowerArm.R","Hand.R","Middle1.R","UpperArm.L","LowerArm.L","Hand.L","Middle1.L"]:
			var index := skeleton.find_bone(bone)
			if index >= 0: print("AUDIT ",bone," pos=", actor.visual.to_local(skeleton.global_transform * skeleton.get_bone_global_pose(index).origin))
	actor.queue_free()
	await process_frame
	print("RIG_AUDIT_RESULT complete")
	quit()
