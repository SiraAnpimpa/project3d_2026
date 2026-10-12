extends "res://tests/phase_6_zombie_test.gd"
## Run with an isolated application user directory; never overwrite player saves.

func run() -> void:
	check(OS.get_user_data_dir().contains("SomchaiAudioQA"), "audio QA has isolated user saves")
	if failures: quit(1); return
	root.size = Vector2i(1280,720)
	var ui_audio: Node = root.get_node("UiAudio")
	var menu: Control = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(8)
	var clicks: int = ui_audio.clicks_played
	click_button(menu.settings_button)
	await frames(3)
	check(ui_audio.clicks_played == clicks + 1 and menu.settings.visible, "real main-menu settings button plays supplied click once")
	menu.settings.volume_slider.value = 0
	check(AudioServer.is_bus_mute(0), "existing master-volume mute applies to all new audio")
	menu.settings.volume_slider.value = 100
	check(not AudioServer.is_bus_mute(0), "master volume restores")
	menu.queue_free()
	await frames(3)
	root.get_node("DayCheckpoint").begin_new()
	set_meta("normal_play", true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	await frames(15)
	player = game.player
	game.clock.paused = true
	game.waves.enabled = false
	var audio: GameAudio = game.audio
	check(audio.ambience.playing and audio.night_ambience.playing and audio.ambience.stream.loop, "both compressed ambience tracks loop without replay handlers")
	await frames(180)
	check(audio.ambience.volume_db > audio.night_ambience.volume_db, "day ambience fades in")
	# Actual travelled distance, including acceleration; no sound while standing.
	await place_player(RuralTerrain.ground_point(14,6) + Vector3.UP * 0.03)
	player.camera_rig.capture_mouse_from_gesture()
	await frames(10)
	var steps := audio.footsteps_played
	Input.action_press("move_backward")
	await frames(70)
	Input.action_release("move_backward")
	await frames(10)
	check(audio.footsteps_played > steps and audio.footsteps.stream == audio.streams.step_grass, "actual movement emits grass footsteps")
	steps = audio.footsteps_played
	await frames(60)
	check(audio.footsteps_played == steps, "standing still adds no steps")
	var floor := wall_at(player.global_position, Vector3(4,0.2,4))
	player.global_position += Vector3.UP * 0.25
	await frames(15)
	check(audio.footstep_surface() == "step_stone", "ground ray chooses stone on a solid platform")
	floor.queue_free()
	await frames(3)
	# A real growth/harvest transaction through interaction input.
	var plot: FarmPlot = game.get_node("MainWorld/FarmArea").get_child(0)
	game.inventory.select_seed(&"seed_lead")
	await place_player(plot.global_position + Vector3(0,0.05,1.1))
	await frames(10)
	key(KEY_E)
	game.clock.advance_game_minutes(60)
	await frames(3)
	key(KEY_E)
	check(plot.state == FarmPlot.State.EMPTY and audio.last_cue == "harvest", "E harvesting uses supplied vegetable pickup cue")
	var recipe: CraftRecipe = game.recipe_book.get_recipe(&"basic_ammo")
	for entry in recipe.ingredients: game.inventory.add_item(entry.item, entry.quantity)
	check(game.crafting_system.craft(recipe).begins_with("Crafted"), "real crafting transaction succeeds")
	check(audio.last_cue == "pickup", "successful craft plays supplied item pickup")
	key(KEY_Q)
	game.inventory.add_item(game.catalog.get_item(&"basic_ammo"),30)
	key(KEY_R)
	await frames(150)
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(15)
	var cues := audio.cues_played
	check(game.weapons.try_fire() and audio.cues_played == cues + 1 and audio.last_cue == "shot", "real pistol shot emits one trimmed shot cue")
	game.inventory.add_item(game.catalog.get_item(&"smg"),1)
	game.equipment.equip_weapon(0,game.catalog.get_item(&"smg"))
	key(KEY_R)
	await frames(150)
	mouse(MOUSE_BUTTON_RIGHT,false)
	mouse(MOUSE_BUTTON_RIGHT,true)
	await frames(15)
	check(game.weapons.try_fire() and audio.last_cue == "shot_auto", "real SMG shot uses supplied rapid-fire sample")
	mouse(MOUSE_BUTTON_RIGHT,false)
	game.clock.seek(10,18)
	await frames(180)
	check(audio.night_ambience.volume_db > audio.ambience.volume_db and audio.target_volume == -26, "final-night crossfade uses supplied night track")
	await place_player(RuralTerrain.ground_point(14,6) + Vector3.UP * 0.03)
	var enemies: Array[NormalZombie] = []
	for index in 3:
		var kind: String = ["Normal","Runner","Tank"][index]
		var enemy := load("res://scenes/enemies/%sZombie.tscn" % kind).instantiate() as NormalZombie
		game.get_node("MainWorld").add_child(enemy)
		enemy.global_position = player.global_position + Vector3(index*2 - 2,0,-4)
		enemy.bind(player)
		enemy.set_physics_process(false)
		enemy.state = NormalZombie.State.CHASE
		enemies.append(enemy)
	await frames(3)
	check(audio._zombies.size() == 3, "all three variants register without changing AI")
	for enemy in enemies: audio._vocal_wait[enemy.get_instance_id()] = 0
	await frames(3)
	check(audio.zombie_cues_played >= 3 and audio.zombie_voices.size() == 3, "three positional vocal voices cover all variants with bounded pool")
	game.pause_menu.set_open(true)
	await process_frame
	await process_frame
	check(audio.ambience.stream_paused and audio.night_ambience.stream_paused and audio.zombie_voices[0].stream_paused, "pause suspends ambience and zombie playback")
	clicks = ui_audio.clicks_played
	ui_audio.play_click()
	check(ui_audio.clicks_played == clicks + 1, "UI audio remains usable during pause")
	game.pause_menu.set_open(false)
	await frames(3)
	check(not audio.night_ambience.stream_paused, "resume restores gameplay playback")
	for enemy in enemies:
		enemy.health.take_damage(10000)
	check(audio._zombies.is_empty(), "enemy death immediately removes vocal ownership")
	for voice in audio.zombie_voices: check(not voice.playing, "dead enemies stop active vocals")
	for enemy in enemies: enemy.despawn()
	await frames(3)
	audio.set_ending()
	check(not audio.ambience.playing and not audio.night_ambience.playing, "ending stops both ambience tracks")
	audio.start_rescue_sound()
	check(audio.ambience.playing and audio.ambience.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "existing rescue sound still loops")
	game.queue_free()
	await frames(4)
	check(not is_instance_valid(audio) and ui_audio.voices.size() == 2, "game teardown leaves only bounded global UI voices")
	print("SUPPLIED_AUDIO_RESULT failures=",failures)
	quit(1 if failures else 0)
