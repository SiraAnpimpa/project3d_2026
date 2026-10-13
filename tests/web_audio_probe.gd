extends Node
## Minimal browser regression: real GameAudio and real sample backend, no world
## rendering/loading cost. Export only through the isolated probe project.
class ProbeActor extends Node3D:
	var health := HealthComponent.new()
class ProbeWorld extends Node3D:
	var player: ProbeActor

var elapsed := 0.0
var audio: GameAudio
var _was_paused := false
var started := false
var stage := "awaiting click"
var _last_second := -1
const EFFECTS = ["click", "shot", "shot_auto", "harvest", "pickup", "step_grass", "step_stone", "zombie_normal", "zombie_runner", "zombie_tank", "reload", "craft", "hurt", "unlock", "bat_swing", "bat_hit"]

func _ready() -> void:
	Engine.max_fps = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	var start := Button.new()
	start.text = "Start audio test"
	start.position = Vector2(450, 250)
	start.size = Vector2(300, 80)
	add_child(start)
	start.pressed.connect(func() -> void:
		start.hide()
		_begin()
		started = true)

func _begin() -> void:
	var world := ProbeWorld.new()
	world.player = ProbeActor.new()
	add_child(world)
	world.add_child(world.player)
	audio = GameAudio.new()
	add_child(audio)
	audio._game = world
	audio.streams = GameAudio.STREAMS.duplicate()
	for kind in ["normal", "runner", "tank"]:
		audio.streams["zombie_" + kind] = load("res://assets/audio/supplied/zombie_%s.wav" % kind)
	audio.set_physics_process(false)
	audio.ambience = audio._background("day")
	audio.night_ambience = audio._background("night")
	audio.footsteps = AudioStreamPlayer.new()
	audio.add_child(audio.footsteps)
	var effect := AudioStreamPlayer.new()
	audio.add_child(effect)
	audio.voices.append(effect)
	audio.cue("shot")

func _process(delta: float) -> void:
	if started: elapsed += delta
	var should_pause := (elapsed >= 4 and elapsed < 5) or (elapsed >= 16 and elapsed < 17) or (elapsed >= 56 and elapsed < 57)
	if should_pause != _was_paused:
		get_tree().paused = should_pause
		_was_paused = should_pause
	var second := int(elapsed)
	if started and second != _last_second:
		_last_second = second
		AudioServer.set_bus_mute(0, second == 8)
		if second == 12: audio._set_phase(1, 20, 0, false)
		if second == 20:
			audio.ambience.stop()
			audio.night_ambience.stop()
		if second >= 20 and second < 52 and second % 2 == 0:
			audio.cue(EFFECTS[(second - 20) / 2])
		if second == 52: audio.night_ambience.play()
	stage = "awaiting click"
	if started:
		stage = "day" if second < 4 else ("day-resumed" if second < 8 else ("day-unmuted" if second < 12 else ("night" if second < 16 else "night-resumed")))
		if second >= 20 and second < 52: stage = "effect-" + EFFECTS[(second - 20) / 2]
		elif second >= 52: stage = "loop-resumed" if second < 60 else "complete"
		if should_pause: stage = "paused"
		elif second == 8: stage = "muted"
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.webAudioProbeElapsed = %.3f; window.webAudioProbePaused = %s; window.webAudioProbeStage = '%s';" % [elapsed, "true" if should_pause else "false", stage])
