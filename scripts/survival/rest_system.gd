class_name RestSystem
extends Node

signal changed
var waves: NightWaveManager
var player: PlayerController
var is_resting := false
var _remaining := 0.0


func bind(manager: NightWaveManager, actor: PlayerController) -> void:
	waves = manager
	player = actor
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.health.died.connect(_abort)


func request_rest(actor: Node3D) -> bool:
	if is_resting or actor != player or get_tree().paused or not waves.begin_rest(): return false
	is_resting = true
	_remaining = 0.35
	player.velocity = Vector3.ZERO
	player.camera_rig.set_menu_open(true)
	get_tree().paused = true
	changed.emit()
	return true


func _process(delta: float) -> void:
	if not is_resting: return
	_remaining -= delta
	if _remaining > 0: return
	if player.health.is_dead or waves.state != NightWaveManager.State.RESTING:
		_abort()
		return
	player.health.heal(player.health.max_hp)
	player.stamina.reset()
	# Clock owns the day increment and farm timestamp notification for both paths.
	waves.clock.skip_to_day()
	_abort()


func _abort() -> void:
	if not is_resting: return
	is_resting = false
	get_tree().paused = false
	player.camera_rig.set_menu_open(false)
	changed.emit()


func _exit_tree() -> void:
	if is_resting: get_tree().paused = false
