class_name NightWaveData
extends Resource

@export var day: int = 1
@export var normal_zombie_count: int = 6
@export var spawn_interval: float = 2.0
@export var minimum_spawn_distance: float = 12.0
@export var zombie_scene: PackedScene


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if day < 1 or normal_zombie_count < 1 or normal_zombie_count > 100 or zombie_scene == null:
		errors.append("Wave requires day >= 1, 1..100 zombies and a scene.")
	if not is_finite(spawn_interval) or spawn_interval <= 0 or not is_finite(minimum_spawn_distance) or minimum_spawn_distance < 0:
		errors.append("Wave spawn interval must be positive and minimum distance nonnegative.")
	return errors
