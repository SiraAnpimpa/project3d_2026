extends Node
## Survives menu/game transitions so button sounds finish after changing scenes.
const CLICK = preload("res://assets/audio/supplied/click.wav")
var voices: Array[AudioStreamPlayer] = []
var clicks_played := 0
var _last_frame := -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in 2:
		var voice := AudioStreamPlayer.new()
		voice.stream = CLICK
		voice.volume_db = -16
		add_child(voice)
		voices.append(voice)
	get_tree().node_added.connect(_watch_button)

func _watch_button(node: Node) -> void:
	if node is BaseButton: _connect_button.call_deferred(node)

func _connect_button(node: Node) -> void:
	if is_instance_valid(node) and node.is_inside_tree() and not node.pressed.is_connected(play_click):
		node.pressed.connect(play_click)

func play_click() -> void:
	var frame := Engine.get_process_frames()
	if frame == _last_frame: return
	_last_frame = frame
	voices[clicks_played % voices.size()].play()
	clicks_played += 1
