class_name GameAudio
extends Node
## Event audio with bounded pools. All streams are explicit export dependencies.
const STREAMS = {
	"shot": preload("res://assets/audio/supplied/shot.wav"),
	"shot_auto": preload("res://assets/audio/supplied/shot_auto.wav"),
	"click": preload("res://assets/audio/supplied/click.wav"),
	"harvest": preload("res://assets/audio/supplied/harvest.wav"),
	"pickup": preload("res://assets/audio/supplied/pickup.wav"),
	"step_grass": preload("res://assets/audio/supplied/step_grass.wav"),
	"step_stone": preload("res://assets/audio/supplied/step_stone.wav"),
	"day": preload("res://Asset/game_sounds/เพลงประกอบพื้นหลัง/เสียงธรรมชาติ.mp3"),
	"night": preload("res://Asset/game_sounds/เพลงประกอบพื้นหลัง/เสียงตอนซอมบี้มา.mp3"),
	"reload": preload("res://assets/audio/reload.wav"),
	"craft": preload("res://assets/audio/craft.wav"),
	"hurt": preload("res://assets/audio/hurt.wav"),
	"unlock": preload("res://assets/audio/unlock.wav"),
	"rotor": preload("res://assets/audio/rotor.wav"),
	"bat_swing": preload("res://assets/audio/bat_swing.wav"),
	"bat_hit": preload("res://assets/audio/bat_hit.wav"),
}
var voices: Array[AudioStreamPlayer] = []
var zombie_voices: Array[AudioStreamPlayer3D] = []
var ambience: AudioStreamPlayer
var night_ambience: AudioStreamPlayer
var footsteps: AudioStreamPlayer
var streams: Dictionary = {}
var ending := false
var target_volume := -36.0
var next_voice := 0
var cues_played := 0
var footsteps_played := 0
var zombie_cues_played := 0
var last_cue := ""
var _reload_active := false
var _game: Node3D
var _zombies: Dictionary = {}
var _vocal_wait: Dictionary = {}
var _voice_targets: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _daytime := true
var _step_distance := 0.0
var _previous_position := Vector3.ZERO
var _suspended := false

func bind(game: Node3D) -> void:
	_game = game
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	streams = STREAMS.duplicate()
	for index in 6:
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -14
		add_child(voice)
		voices.append(voice)
	for index in 3:
		var voice := AudioStreamPlayer3D.new()
		# GameAudio owns pause/resume for every gameplay voice, including the
		# spatial players parented to the world instead of this ALWAYS node.
		voice.process_mode = Node.PROCESS_MODE_ALWAYS
		voice.volume_db = -15
		voice.unit_size = 4
		voice.max_distance = 22
		voice.panning_strength = 0.7
		game.add_child(voice)
		zombie_voices.append(voice)
		_voice_targets[voice] = 0
	ambience = _background("day")
	night_ambience = _background("night")
	footsteps = AudioStreamPlayer.new()
	footsteps.volume_db = -23
	add_child(footsteps)
	_previous_position = game.player.global_position
	_set_phase(game.clock.current_day, 0, 0, game.clock.is_daytime)
	game.weapons.shot_fired.connect(func() -> void:
		var weapon: WeaponRuntime = game.weapons.current
		cue("shot_auto" if weapon != null and weapon.data.automatic and weapon.data.fire_rate >= 8 else "shot"))
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
	game.crafting_system.craft_completed.connect(func(_recipe: CraftRecipe) -> void: cue("pickup"))
	game.progression.feedback.connect(func(_message: String) -> void: cue("unlock"))
	var hp := [game.player.health.current_hp]
	game.player.health.changed.connect(func(value: float, _max: float) -> void:
		if value < hp[0]: cue("hurt")
		hp[0] = value)
	game.player.health.died.connect(_stop_gameplay_sounds)
	game.clock.time_changed.connect(_set_phase)
	for ui in [game.inventory_ui, game.crafting_ui, game.pause_menu]:
		ui.opened_changed.connect(func(_open: bool) -> void: cue("click"))
	get_tree().node_added.connect(_watch_zombie)
	for enemy in game.find_children("*", "CharacterBody3D", true, false): _watch_zombie(enemy)

func _background(id: String) -> AudioStreamPlayer:
	var voice := AudioStreamPlayer.new()
	voice.stream = streams[id].duplicate()
	voice.stream.loop = true
	voice.volume_db = -60
	add_child(voice)
	voice.play()
	return voice

func _set_phase(day: int, _hour: int, _minute: int, daytime: bool) -> void:
	if ending: return
	_daytime = daytime
	target_volume = -36 if daytime else (-26 if day == 10 else -30)

func cue(id: String) -> void:
	if ending or not streams.has(id): return
	last_cue = id
	if id == "click":
		get_node("/root/UiAudio").play_click()
	else:
		var voice := voices[next_voice % voices.size()]
		for candidate in voices:
			if not candidate.playing:
				voice = candidate
				break
		next_voice += 1
		voice.stream = streams[id]
		voice.volume_db = -12 if id.begins_with("shot") else -17
		voice.play()
	cues_played += 1

func _watch_zombie(node: Node) -> void:
	if node is NormalZombie and _game.is_ancestor_of(node): _track_zombie.call_deferred(node)

func _track_zombie(enemy: NormalZombie) -> void:
	if not is_instance_valid(enemy) or not enemy.is_inside_tree() or enemy.health.is_dead or ending: return
	var id := enemy.get_instance_id()
	if _zombies.has(id): return
	_zombies[id] = enemy
	_vocal_wait[id] = _rng.randf_range(0.5, 2.5)
	enemy.died.connect(_forget_zombie.bind(id))
	enemy.tree_exiting.connect(_forget_zombie.bind(id))

func _forget_zombie(id: int) -> void:
	_zombies.erase(id)
	_vocal_wait.erase(id)
	for voice in zombie_voices:
		if is_instance_valid(voice) and _voice_targets.get(voice) == id:
			voice.stop()
			_voice_targets[voice] = 0

func _update_zombies(delta: float) -> void:
	for id in _zombies.keys():
		var enemy: NormalZombie = _zombies[id]
		if not is_instance_valid(enemy) or enemy.health.is_dead:
			_forget_zombie(id)
			continue
		for voice in zombie_voices:
			if _voice_targets.get(voice) == id: voice.global_position = enemy.global_position + Vector3.UP
		_vocal_wait[id] = maxf(0, _vocal_wait[id] - delta)
		if _vocal_wait[id] > 0 or enemy.data.vocal_stream == null or enemy.state == NormalZombie.State.IDLE: continue
		if enemy.global_position.distance_to(_game.player.global_position) > 20: continue
		for voice in zombie_voices:
			if voice.playing: continue
			voice.stream = enemy.data.vocal_stream
			voice.global_position = enemy.global_position + Vector3.UP
			voice.pitch_scale = _rng.randf_range(0.96, 1.04)
			voice.play()
			_voice_targets[voice] = id
			_vocal_wait[id] = _rng.randf_range(4, 8)
			zombie_cues_played += 1
			break

func _physics_process(_delta: float) -> void:
	if _game == null or ending: return
	var player: PlayerController = _game.player
	var distance := Vector2(player.global_position.x - _previous_position.x, player.global_position.z - _previous_position.z).length()
	_previous_position = player.global_position
	if get_tree().paused or player.health.is_dead or not player.is_on_floor() or not player.camera_rig.can_control() or distance > 2 or Vector2(player.velocity.x, player.velocity.z).length() < 0.5:
		_step_distance = 0
		return
	_step_distance += distance
	var stride := 1.8 if player.is_sprinting else 1.5
	if _step_distance < stride: return
	_step_distance = fmod(_step_distance, stride)
	footsteps.stream = streams[footstep_surface()]
	footsteps.pitch_scale = _rng.randf_range(0.96, 1.04)
	footsteps.play()
	footsteps_played += 1

func footstep_surface() -> String:
	var player: PlayerController = _game.player
	var query := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP * 0.2, player.global_position - Vector3.UP * 0.7, 1, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var surface := hit.get("collider") as Node
	while surface != null:
		if surface is RuralTerrain or surface is FarmPlot: return "step_grass"
		surface = surface.get_parent()
	return "step_stone" if not hit.is_empty() else "step_grass"

func _stop_gameplay_sounds() -> void:
	footsteps.stop()
	for voice in zombie_voices: voice.stop()

func set_ending() -> void:
	if ending: return
	ending = true
	for voice in voices: voice.stop()
	_stop_gameplay_sounds()
	ambience.stop()
	night_ambience.stop()
	_zombies.clear()
	_vocal_wait.clear()

func start_rescue_sound() -> void:
	var rotor: AudioStreamWAV = streams["rotor"].duplicate()
	rotor.loop_mode = AudioStreamWAV.LOOP_FORWARD
	rotor.loop_end = roundi(rotor.get_length() * rotor.mix_rate)
	ambience.stream = rotor
	ambience.volume_db = -40
	target_volume = -22
	ambience.play()

func _process(delta: float) -> void:
	if ambience == null: return
	var suspended := get_tree().paused and not ending
	# Own the requested state and send both edges exactly once. ALWAYS players
	# avoid separate SceneTree pause notifications, and tracking the transition
	# guarantees a resume request without restarting audio every frame.
	if suspended != _suspended:
		_suspended = suspended
		for voice in voices: voice.stream_paused = suspended
		for voice in zombie_voices: voice.stream_paused = suspended
		footsteps.stream_paused = suspended
		ambience.stream_paused = suspended
		night_ambience.stream_paused = suspended
	if ending:
		ambience.volume_db = move_toward(ambience.volume_db, target_volume, delta * 8)
		return
	if suspended: return
	var alive: bool = not _game.player.health.is_dead
	ambience.volume_db = move_toward(ambience.volume_db, target_volume + 18 if _daytime and alive else -60, delta * 18)
	night_ambience.volume_db = move_toward(night_ambience.volume_db, target_volume + 8 if not _daytime and alive else -60, delta * 18)
	if alive: _update_zombies(delta)

func _exit_tree() -> void:
	for voice in voices: voice.stop()
	for voice in zombie_voices:
		if is_instance_valid(voice): voice.stop()
	if ambience != null: ambience.stop()
	if night_ambience != null: night_ambience.stop()
	if footsteps != null: footsteps.stop()
	_zombies.clear()
	_vocal_wait.clear()
	streams.clear()
