class_name DayNightEnvironment
extends Node

@export var sun: DirectionalLight3D
@export var world_environment: WorldEnvironment
@export var day_energy: float = 1.2
@export var night_energy: float = 0.22
@export var day_ambient: float = 0.65
@export var night_ambient: float = 0.5


func bind_clock(clock: GameClock) -> void:
	# A local environment prevents runtime lighting from changing shared scene resources.
	world_environment.environment = world_environment.environment.duplicate() as Environment
	clock.time_changed.connect(_on_time_changed)
	_on_time_changed(clock.current_day, clock.current_hour, clock.current_minute, clock.is_daytime)


func _on_time_changed(day: int, _hour: int, _minute: int, daytime: bool) -> void:
	var environment := world_environment.environment
	sun.light_energy = day_energy if daytime else night_energy
	sun.light_color = Color(1.0, 0.93, 0.8) if daytime else Color(0.45, 0.6, 0.95)
	environment.ambient_light_energy = day_ambient if daytime else night_ambient
	environment.ambient_light_color = Color(0.75, 0.83, 0.94) if daytime else Color(0.48, 0.57, 0.76)
	environment.background_color = Color(0.55, 0.7, 0.79) if daytime else Color(0.035, 0.05, 0.1)
	if day == 10 and not daytime:
		environment.background_color = Color(0.07, 0.045, 0.09)
		sun.light_color = Color(0.56, 0.58, 0.88)
