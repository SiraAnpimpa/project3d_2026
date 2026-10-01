extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var model := load("res://Asset/Post Apocolypse Pack.undefined-glb/Characters Matt.glb").instantiate() as Node3D
	root.add_child(model)
	model.scale = Vector3.ONE * 1.1
	await process_frame
	var animation := model.find_child("AnimationPlayer",true,false) as AnimationPlayer
	var skeleton := model.find_child("Skeleton3D",true,false) as Skeleton3D
	var foot := skeleton.find_bone("Foot.L")
	for clip in ["Walk","Run","Walk_Gun","Run_Gun"]:
		var key: String = "CharacterArmature|"+clip
		animation.play(key)
		var duration := animation.get_animation(key).length
		var samples: Array[Vector3] = []
		for i in 121:
			animation.seek(duration*float(i)/120.0,true)
			skeleton.force_update_all_bone_transforms()
			samples.append(skeleton.global_transform*skeleton.get_bone_global_pose(foot).origin)
		var low_y := INF
		var low_z := INF
		var high_z := -INF
		for point in samples:
			low_y=minf(low_y,point.y)
			low_z=minf(low_z,point.z)
			high_z=maxf(high_z,point.z)
		var stance_speed := 0.0
		var count := 0
		for i in 120:
			if samples[i].y < low_y+0.07:
				var speed: float = (samples[i+1].z-samples[i].z)/(duration/120)
				if speed < 0:
					stance_speed -= speed
					count += 1
		print("STRIDE ",clip," seconds=",duration," excursion_m=",high_z-low_z," ground_stroke_speed=",stance_speed/maxi(1,count)," samples=",count)
	var hand_clip:=animation.get_animation("CharacterArmature|Idle_Gun")
	for track in hand_clip.get_track_count():
		var path:=hand_clip.track_get_path(track)
		if path.get_subname_count()>0 and (String(path.get_subname(0)).begins_with("Middle") or String(path.get_subname(0)).begins_with("Pinky") or String(path.get_subname(0)).begins_with("Index") or String(path.get_subname(0)).begins_with("Thumb")) and hand_clip.track_get_type(track)==Animation.TYPE_ROTATION_3D:
			print("HAND_TRACK ",path.get_subname(0)," ",hand_clip.rotation_track_interpolate(track,0.0))
	print("GAMEPLAY_STRIDE_AUDIT_RESULT complete")
	quit()
