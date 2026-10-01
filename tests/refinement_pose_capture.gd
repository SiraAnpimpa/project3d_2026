extends "res://tests/phase_6_zombie_test.gd"

func run() -> void:
	root.size = Vector2i(1280,720)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	player = game.player
	game.clock.paused = true
	game.debug_controls.set_active(false)
	game.hud.hide()
	await place_player(Vector3(12,0.05,6))
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.position = player.position + Vector3(2.0,1.7,-2.6)
	camera.look_at(player.position + Vector3.UP * 0.85)
	camera.fov = 42
	camera.current = true
	await frames(30)
	await capture("pose_farming")
	key(KEY_Q)
	await frames(30)
	await capture("pose_ready")
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(30)
	await capture("pose_aim")
	player.camera_rig.orbit(0,deg_to_rad(35))
	await frames(30)
	await capture("pose_aim_up")
	player.camera_rig.orbit(0,deg_to_rad(-80))
	await frames(30)
	await capture("pose_aim_down")
	var skeleton := player.visual.find_child("Skeleton3D",true,false) as Skeleton3D
	for bone in ["Head","Torso","UpperArm.R","LowerArm.R","Middle1.R","UpperArm.L","LowerArm.L","Middle1.L","Foot.R","Foot.L"]:
		print("POSE_BONE ",bone," ",player.to_local(skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone)).origin))
	print("REFINEMENT_POSE_CAPTURE_RESULT failures=",failures)
	quit(1 if failures else 0)
