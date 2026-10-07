class_name DayNightEnvironment
extends Node

@export var sun: DirectionalLight3D
@export var world_environment: WorldEnvironment
@export var day_energy: float = 1.2
@export var night_energy: float = 0.22
@export var day_ambient: float = 0.65
@export var night_ambient: float = 0.5
var _sky_material: ProceduralSkyMaterial


func bind_clock(clock: GameClock) -> void:
	# A local environment prevents runtime lighting from changing shared scene resources.
	world_environment.environment = world_environment.environment.duplicate() as Environment
	var environment := world_environment.environment
	_sky_material = ProceduralSkyMaterial.new()
	_sky_material.sky_curve = 0.22
	_sky_material.ground_curve = 0.15
	_sky_material.sun_angle_max = 8.0
	_sky_material.sun_curve = 0.12
	var sky := Sky.new()
	sky.sky_material = _sky_material
	sky.radiance_size = Sky.RADIANCE_SIZE_64
	environment.sky = sky
	environment.background_mode = Environment.BG_SKY
	# Explicit ambient color keeps silhouettes readable during ordinary night combat.
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.fog_enabled = true
	environment.fog_mode = Environment.FOG_MODE_DEPTH
	environment.fog_depth_begin = 42.0
	environment.fog_depth_end = 185.0
	environment.fog_depth_curve = 1.65
	environment.fog_density = 0.42
	environment.fog_sky_affect = 0.0
	clock.time_changed.connect(_on_time_changed)
	_on_time_changed(clock.current_day, clock.current_hour, clock.current_minute, clock.is_daytime)


func _on_time_changed(day: int, hour: int, minute: int, daytime: bool) -> void:
	var environment := world_environment.environment
	var phase := clampf((hour+minute/60.0-6.0)/12.0,0.0,1.0)
	var twilight := maxf(pow(1.0-phase,5.0),pow(phase,5.0)) if daytime else 0.0
	sun.light_energy = day_energy if daytime else night_energy
	sun.light_color = Color(1.0,0.96,0.87).lerp(Color(1.0,0.80,0.56),twilight*0.8) if daytime else Color(0.45, 0.6, 0.95)
	sun.rotation_degrees = Vector3(-(28.0+36.0*sin(phase*PI)),-55.0+phase*170.0,0) if daytime else Vector3(-55,-35,0)
	environment.ambient_light_energy = day_ambient if daytime else night_ambient
	environment.ambient_light_color = Color(0.75, 0.83, 0.94) if daytime else Color(0.48, 0.57, 0.76)
	environment.background_color = Color(0.55, 0.7, 0.79) if daytime else Color(0.035, 0.05, 0.1)
	_sky_material.sky_top_color = Color("4585b6").lerp(Color("668eaf"),twilight*0.35) if daytime else Color("111c35")
	_sky_material.sky_horizon_color = Color("c7dfed").lerp(Color("f5d8b5"),twilight*0.62) if daytime else Color("344153")
	_sky_material.ground_bottom_color = Color("465340") if daytime else Color("171f2c")
	_sky_material.ground_horizon_color = _sky_material.sky_horizon_color
	_sky_material.sky_energy_multiplier = 1.0 if daytime else 0.45
	# Equal horizon colors AND energy remove the artificial seam at EYEDIR.y == 0.
	_sky_material.ground_energy_multiplier = _sky_material.sky_energy_multiplier
	environment.fog_light_color = _sky_material.sky_horizon_color if daytime else Color("344153")
	if day == 10 and not daytime:
		environment.background_color = Color(0.07, 0.045, 0.09)
		sun.light_color = Color(0.56, 0.58, 0.88)
		_sky_material.sky_top_color = Color("221b38")
		_sky_material.sky_horizon_color = Color("4c4059")
		_sky_material.ground_horizon_color = _sky_material.sky_horizon_color
		environment.fog_light_color = Color("4c4059")
