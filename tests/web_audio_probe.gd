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

func _ready() -> void:
	Engine.max_fps = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	var world := ProbeWorld.new()
	world.player = ProbeActor.new()
	add_child(world)
	world.add_child(world.player)
	audio = GameAudio.new()
	add_child(audio)
	audio._game = world
	audio.streams = GameAudio.STREAMS.duplicate()
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
	elapsed += delta
	var should_pause := elapsed >= 4 and elapsed < 5
	if should_pause != _was_paused:
		get_tree().paused = should_pause
		_was_paused = should_pause
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.webAudioProbeElapsed = %.3f; window.webAudioProbePaused = %s;" % [elapsed, "true" if should_pause else "false"])
