extends "res://tests/phase_6_zombie_test.gd"
## Captures use real input/production timers; extra frames permit reviewing complete arcs.
var camera: Camera3D
var record_motion := false
var frame_times: Dictionary = {}

func view() -> void:
	camera.position = player.position+Vector3(2.1,1.65,-2.55)
	camera.look_at(player.position+Vector3.UP*0.92)

func sequence(label: String, count: int) -> void:
	for i in count:
		await frames(1)
		view()
		if record_motion:
			var name := label+"_%03d" % i
			await capture(name)
			frame_times[name] = Engine.get_physics_frames()

func run() -> void:
	root.size = Vector2i(960,720)
	record_motion = "--motion" in OS.get_cmdline_user_args()
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(30)
	player = game.player
	game.clock.paused = true
	game.waves.enabled = false
	game.debug_controls.set_active(false)
	game.hud.hide()
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*0.03)
	player.camera_rig.rotation.y = 0
	player.visual.rotation.y = PI
	camera = Camera3D.new()
	game.add_child(camera)
	camera.fov = 42
	camera.current = true
	await frames(25)
	view()
	await capture("idle")
	Input.action_press("move_forward")
	await sequence("start_walk",30)
	await capture("walk")
	Input.action_press("sprint")
	await sequence("walk_run",24)
	await capture("run")
	for action in ["move_forward","sprint"]: Input.action_release(action)
	await sequence("stop",24)
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*0.03)
	key(KEY_Q)
	await frames(25)
	view()
	await capture("rifle_ready")
	mouse(MOUSE_BUTTON_RIGHT,true)
	await sequence("raise_rifle",20)
	await capture("rifle_aim")
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),20)
	check(game.weapons.start_reload(),"real reload starts for presentation capture")
	await sequence("reload",94)
	view()
	await capture("reload_finished")
	mouse(MOUSE_BUTTON_LEFT,true)
	mouse(MOUSE_BUTTON_LEFT,false)
	await sequence("shot",24)
	await capture("shot_recovered")
	mouse(MOUSE_BUTTON_RIGHT,false)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,true)
	mouse(MOUSE_BUTTON_WHEEL_DOWN,false)
	await frames(30)
	view()
	await capture("bat_ready")
	mouse(MOUSE_BUTTON_LEFT,true)
	mouse(MOUSE_BUTTON_LEFT,false)
	await sequence("bat",36)
	await capture("bat_recovered")
	player.health.take_damage(10)
	await sequence("hurt",36)
	await capture("hurt_recovered")
	check(not game.weapons.current.is_swinging and player.health.current_hp == 90,"visual sequences retain production swing and health state")
	if record_motion and not capture_directory.is_empty():
		var file := FileAccess.open(capture_directory.path_join("frame_times.json"),FileAccess.WRITE)
		file.store_string(JSON.stringify(frame_times,"  "))
	print("ANIMATION_CAPTURE_RESULT failures=",failures)
	quit(1 if failures else 0)
