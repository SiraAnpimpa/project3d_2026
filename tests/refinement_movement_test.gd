extends "res://tests/phase_6_zombie_test.gd"

func run() -> void:
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	player = game.player
	game.clock.paused = true
	game.debug_controls.set_active(false)
	await place_player(Vector3(13,0.05,8))
	var visual := player.visual
	check(visual.current_clip == &"CharacterArmature|Idle", "Farming keeps authored relaxed Idle")
	Input.action_press("move_forward")
	await frames(24)
	check(visual.current_state == &"Walk" and visual.animation_player.speed_scale > 0.95, "Walk responds and playback reaches speed-matched rate")
	Input.action_press("sprint")
	await frames(24)
	check(visual.current_state == &"Run" and player.is_sprinting and player.stamina.current_stamina < 100, "Run and stamina respond immediately to sprint")
	Input.action_release("sprint")
	Input.action_release("move_forward")
	await frames(20)
	check(visual.current_state == &"Idle", "braking returns to Idle")
	key(KEY_Q)
	await frames(12)
	check(visual.current_clip == &"CharacterArmature|Idle_Gun", "Combat enters actual imported Gun ready clip")
	mouse(MOUSE_BUTTON_RIGHT,true)
	Input.action_press("move_backward")
	await frames(30)
	check(visual.current_clip == &"CharacterArmature|Walk_Gun" and visual.animation_player.speed_scale < -0.6, "aim backward uses reversed Gun Walk at aim speed")
	Input.action_release("move_backward")
	mouse(MOUSE_BUTTON_RIGHT,false)
	key(KEY_Q)
	await frames(20)
	check(visual.current_clip == &"CharacterArmature|Idle" and not game.weapons.visual.visible, "Farming returns to relaxed stance with rifle hidden")
	var skeleton := visual.find_child("Skeleton3D",true,false) as Skeleton3D
	check(skeleton.get_bone_count() == 43 and player.rotation.x == 0 and player.rotation.z == 0, "imported43bones retained; physics root stays upright")
	print("REFINEMENT_MOVEMENT_RESULT failures=",failures)
	quit(1 if failures else 0)
