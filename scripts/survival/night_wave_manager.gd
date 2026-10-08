class_name NightWaveManager
extends Node

signal completed
signal changed
signal wave_cleared
signal morning_started(day: int, rested: bool)
signal feedback(message: String)

enum State { DAY, ACTIVE, CLEARED, RESTING, GAME_OVER, GAME_COMPLETED }
@export var enabled: bool = true
@export var data: NightWaveData
var progression: ProgressionManager
var pending: Array[PackedScene] = []
var _enemy_scenes: Dictionary = {}
var state: State = State.DAY
var total_zombies: int = 0
var spawned_zombies: int = 0
var alive: Dictionary[int, NormalZombie] = {}
var tracked: Dictionary[int, NormalZombie] = {}
var remaining_zombies: int:
	get: return total_zombies - spawned_zombies + alive.size()
var clock: GameClock
var player: PlayerController
var spawn_points: Node3D
var _spawn_wait := 0.0
var _next_point := 0
var _last_started_day := 0
var _ending := false
var _warned_day := 0


func bind(time: GameClock, actor: PlayerController, points: Node3D) -> void:
	clock = time
	player = actor
	spawn_points = points
	if not enabled: return
	if data == null or not data.validation_errors().is_empty() or spawn_points.get_child_count() == 0:
		push_error("NightWaveManager requires valid wave data and spawn points.")
		enabled = false
		return
	clock.night_started.connect(_on_night)
	clock.day_started.connect(_on_day)
	clock.time_changed.connect(_on_time_changed)
	player.health.died.connect(_on_game_over)
	if clock.is_nighttime: _on_night(clock.current_day)


func _on_time_changed(day: int, hour: int, _minute: int, daytime: bool) -> void:
	if daytime and hour == 17 and _warned_day != day and state == State.DAY:
		_warned_day = day
		feedback.emit("FINAL NIGHT APPROACHING - Prepare for the last night." if day == 10 else "Night approaching. Craft ammo and prepare.")


func _on_night(day: int) -> void:
	if not enabled or player.health.is_dead or state in [State.GAME_OVER, State.GAME_COMPLETED] or not clock.is_nighttime or day <= _last_started_day: return
	if progression != null:
		var config := progression.data.get_day(day)
		if config == null:
			push_error("Missing DayConfig for Day %d" % day)
			return
		if config.wave == null or not config.wave.validation_errors().is_empty():
			push_error("Invalid wave for Day %d" % day)
			return
		data = config.wave
	_cleanup()
	pending = data.spawn_queue()
	_last_started_day = day
	total_zombies = pending.size()
	spawned_zombies = 0
	_next_point = 0
	_spawn_wait = 0
	state = State.ACTIVE
	changed.emit()
	feedback.emit("FINAL NIGHT - Survive until rescue at dawn." if day == 10 else "NIGHT %d - Zombies are approaching" % day)


func _physics_process(delta: float) -> void:
	if not enabled or state != State.ACTIVE or pending.is_empty() or alive.size() >= data.max_active_zombies: return
	_spawn_wait -= delta
	if _spawn_wait > 0: return
	_spawn_wait = data.spawn_interval
	# One attempt per interval; try every marker once, then retry later if all are blocked.
	for _index in spawn_points.get_child_count():
		var point := spawn_points.get_child(_next_point % spawn_points.get_child_count()) as Node3D
		_next_point += 1
		var zombie := ZombieSpawnFactory.spawn(spawn_points.get_parent(), pending[0], player, point.global_position, data.minimum_spawn_distance)
		if zombie == null: continue
		zombie.pursue_target = true
		var id := zombie.get_instance_id()
		_enemy_scenes[id] = pending.pop_front()
		alive[id] = zombie
		tracked[id] = zombie
		spawned_zombies += 1
		zombie.died.connect(_on_zombie_died.bind(id))
		zombie.tree_exiting.connect(_on_zombie_exiting.bind(id))
		changed.emit()
		break


func _on_zombie_died(id: int) -> void:
	if _ending or state != State.ACTIVE or not alive.has(id): return
	alive.erase(id)
	_enemy_scenes.erase(id)
	changed.emit()
	if state == State.ACTIVE and spawned_zombies == total_zombies and alive.is_empty() and clock.is_nighttime and not player.health.is_dead:
		state = State.CLEARED
		changed.emit()
		wave_cleared.emit()
		feedback.emit("NIGHT CLEARED - Rest at the shelter bed")


func _on_zombie_exiting(id: int) -> void:
	tracked.erase(id)
	if _ending or not alive.has(id):
		_enemy_scenes.erase(id)
		return
	alive.erase(id)
	# Unexpected removal is not a kill. Return it to pending rather than award a clear.
	if state == State.ACTIVE:
		pending.push_front(_enemy_scenes[id])
		spawned_zombies -= 1
	_enemy_scenes.erase(id)
	changed.emit()


func _on_day(day: int) -> void:
	if not enabled or state in [State.GAME_OVER, State.GAME_COMPLETED] or state == State.DAY: return
	if progression != null and day > progression.data.days.size() and _last_started_day == progression.data.days.size() and not player.health.is_dead:
		state = State.GAME_COMPLETED
		clock.paused = true
		_cleanup()
		total_zombies = 0
		spawned_zombies = 0
		changed.emit()
		completed.emit()
		return
	var rested := state == State.RESTING
	state = State.DAY
	_cleanup()
	total_zombies = 0
	spawned_zombies = 0
	changed.emit()
	morning_started.emit(day, rested)
	feedback.emit("DAY %d - %s" % [day, "Rested. HP and stamina restored." if rested else "No rest. Surviving zombies dispersed."])


func begin_rest() -> bool:
	if state != State.CLEARED or not clock.is_nighttime or player.health.is_dead: return false
	state = State.RESTING
	changed.emit()
	return true


func _on_game_over() -> void:
	state = State.GAME_OVER
	clock.paused = true
	_cleanup()
	changed.emit()


func _cleanup() -> void:
	_ending = true
	var enemies := tracked.values()
	alive.clear()
	tracked.clear()
	pending.clear()
	_enemy_scenes.clear()
	for zombie in enemies:
		if is_instance_valid(zombie): zombie.despawn()
	_ending = false


func debug_kill_active() -> void:
	for zombie in alive.values():
		if is_instance_valid(zombie): zombie.health.take_damage(zombie.health.max_hp)

func debug_clear_wave() -> void:
	if state in [State.GAME_OVER, State.GAME_COMPLETED]: return
	var was_active := state == State.ACTIVE
	_cleanup()
	spawned_zombies = total_zombies
	if was_active: state = State.CLEARED
	changed.emit()
	if was_active:
		wave_cleared.emit()
		feedback.emit("NIGHT CLEARED - Rest at the shelter bed")


func debug_set_day(day: int) -> void:
	if state in [State.GAME_OVER, State.GAME_COMPLETED] or day < 1 or day > 10: return
	state = State.DAY
	_cleanup()
	total_zombies = 0
	spawned_zombies = 0
	_last_started_day = day - 1
	_warned_day = 0
	clock.seek(day, 6, 0)
	changed.emit()
