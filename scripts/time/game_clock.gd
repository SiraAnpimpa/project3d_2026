class_name GameClock
extends Node

signal time_changed(day: int, hour: int, minute: int, daytime: bool)
signal day_started(day: int)
signal night_started(day: int)
signal new_day_started(day: int)

@export_range(1.0, 3600.0) var half_day_real_seconds: float = 600.0
@export_range(0.0, 100.0) var time_scale: float = 1.0
@export_range(1, 100) var starting_day: int = 1
@export_range(0, 23) var starting_hour: int = 6
@export_range(0, 59) var starting_minute: int = 0
@export var paused: bool = false

# Survival days run from 06:00 to 06:00. Midnight remains in the same day.
var _elapsed_minutes: float = 0.0
var _last_published_minute: int = -1
var current_day: int:
	get: return floori((_elapsed_minutes + 0.000001) / 1440.0) + 1
var current_hour: int:
	get: return floori(float((_whole_minutes() + 360) % 1440) / 60.0)
var current_minute: int:
	get: return (_whole_minutes() + 360) % 60
var is_daytime: bool:
	get: return _whole_minutes() % 1440 < 720
var is_nighttime: bool:
	get: return not is_daytime


func _ready() -> void:
	seek(starting_day, starting_hour, starting_minute)


func _process(delta: float) -> void:
	advance(delta)


func advance(real_seconds: float) -> void:
	if not paused and real_seconds > 0.0:
		advance_game_minutes(real_seconds * 720.0 / half_day_real_seconds * time_scale)


func advance_game_minutes(amount: float) -> void:
	if is_zero_approx(amount):
		return
	var destination := maxf(0.0, _elapsed_minutes + amount)
	if absf(destination - roundf(destination)) < 0.000001:
		destination = roundf(destination)
	var was_day := is_daytime
	if amount > 0.0:
		var boundary := (floorf(_elapsed_minutes / 720.0) + 1.0) * 720.0
		# Visit every dawn/dusk, including when debug time skips several days.
		while boundary <= destination:
			_elapsed_minutes = boundary
			_publish()
			if is_daytime:
				new_day_started.emit(current_day)
				day_started.emit(current_day)
			else:
				night_started.emit(current_day)
			boundary += 720.0
	_elapsed_minutes = destination
	_publish()
	if amount < 0.0 and was_day != is_daytime:
		_announce_phase()


# Debug/test seek: changes clock state without replaying progression events.
func seek(day: int, hour: int, minute: int = 0) -> void:
	var minute_of_day := clampi(hour, 0, 23) * 60 + clampi(minute, 0, 59)
	var since_dawn := posmod(minute_of_day - 360, 1440)
	_elapsed_minutes = float((maxi(day, 1) - 1) * 1440 + since_dawn)
	_publish(true)
	_announce_phase()


func skip_to_day() -> void:
	if is_nighttime:
		advance_game_minutes(1440.0 - fposmod(_elapsed_minutes, 1440.0))


func skip_to_night() -> void:
	if is_daytime:
		advance_game_minutes(720.0 - fposmod(_elapsed_minutes, 1440.0))


func get_elapsed_minutes() -> float:
	return _elapsed_minutes


func _whole_minutes() -> int:
	return floori(_elapsed_minutes + 0.000001)


func _publish(force: bool = false) -> void:
	if force or _whole_minutes() != _last_published_minute:
		_last_published_minute = _whole_minutes()
		time_changed.emit(current_day, current_hour, current_minute, is_daytime)


func _announce_phase() -> void:
	if is_daytime:
		day_started.emit(current_day)
	else:
		night_started.emit(current_day)
