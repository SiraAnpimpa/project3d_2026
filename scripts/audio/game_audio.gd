class_name GameAudio
extends Node

var voices: Array[AudioStreamPlayer] = []
var ambience: AudioStreamPlayer
var streams: Dictionary = {}
var ending := false
var target_volume := -34.0
var next_voice := 0
var cues_played := 0
var _reload_active := false

func bind(game: Node3D) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for id in ["shot", "reload", "click", "harvest", "craft", "hurt", "unlock", "rotor", "wind", "bat_swing", "bat_hit"]:
		streams[id] = load("res://assets/audio/%s.wav" % id)
	for index in 6:
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -16
		add_child(voice)
		voices.append(voice)
	ambience = AudioStreamPlayer.new()
	ambience.stream = streams["wind"]
	ambience.volume_db = -38
	add_child(ambience)
	if DisplayServer.get_name() != "headless": ambience.play()
	ambience.finished.connect(func() -> void:
		if is_inside_tree() and DisplayServer.get_name() != "headless": ambience.play())
	game.weapons.shot_fired.connect(func() -> void: cue("shot"))
	game.weapons.melee_started.connect(func() -> void: cue("bat_swing"))
	game.weapons.melee_hit.connect(func() -> void: cue("bat_hit"))
	game.weapons.state_changed.connect(func() -> void:
		var active: bool = game.weapons.current != null and game.weapons.current.is_reloading
		if active and not _reload_active: cue("reload")
		_reload_active = active)
	game.weapons.feedback.connect(func(_message: String) -> void: cue("click"))
	game.gameplay_mode.mode_changed.connect(func(_mode: GameplayModeController.Mode) -> void: cue("click"))
	game.player.interactor.interaction_completed.connect(func(message: String) -> void:
		cue("harvest" if message.begins_with("Harvested") else "click"))
	game.crafting_system.craft_completed.connect(func(_recipe: CraftRecipe) -> void: cue("craft"))
	game.progression.feedback.connect(func(_message: String) -> void: cue("unlock"))
	var hp := [game.player.health.current_hp]
	game.player.health.changed.connect(func(value: float, _max: float) -> void:
		if value < hp[0]: cue("hurt")
		hp[0] = value)
	game.clock.time_changed.connect(func(day: int, _hour: int, _minute: int, daytime: bool) -> void:
		if not ending: target_volume = -36 if daytime else (-26 if day == 10 else -30))
	for ui in [game.inventory_ui, game.crafting_ui, game.pause_menu]:
		ui.opened_changed.connect(func(_open: bool) -> void: cue("click"))

func cue(id: String) -> void:
	if ending or not streams.has(id): return
	var voice := voices[next_voice % voices.size()]
	next_voice += 1
	voice.stream = streams[id]
	if DisplayServer.get_name() != "headless": voice.play()
	cues_played += 1

func set_ending() -> void:
	if ending: return
	ending = true
	for voice in voices: voice.stop()
	ambience.stop()

func start_rescue_sound() -> void:
	ambience.stream = streams["rotor"]
	ambience.volume_db = -40
	target_volume = -22
	if DisplayServer.get_name() != "headless": ambience.play()

func _process(delta: float) -> void:
	if ambience == null: return
	ambience.volume_db = move_toward(ambience.volume_db, target_volume, delta * 8)

func _exit_tree() -> void:
	for voice in voices:
		voice.stop()
		voice.stream = null
	if ambience != null:
		ambience.stop()
		ambience.stream = null
	streams.clear()
