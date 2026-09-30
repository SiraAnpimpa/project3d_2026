class_name ZombieData
extends Resource

@export var zombie_id: StringName = &"normal_zombie"
@export var display_name: String = "Normal Zombie"
@export var max_health: float = 100.0
@export var move_speed: float = 2.0
@export var rotation_speed: float = 8.0
@export var damage: float = 10.0
@export var attack_range: float = 1.35
@export var attack_interval: float = 1.2
@export var attack_windup: float = 0.3
@export var detection_range: float = 12.0
@export var navigation_interval: float = 0.3
@export var death_delay: float = 1.2
@export var visual_scene: PackedScene
@export var visual_tint: Color = Color.WHITE
@export var visual_scale: float = 1.1
@export var idle_animation: StringName = &"CharacterArmature|Idle"
@export var walk_animation: StringName = &"CharacterArmature|Walk"
@export var attack_animation: StringName = &"CharacterArmature|Punch"
@export var death_animation: StringName = &"CharacterArmature|Death"


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if zombie_id.is_empty() or display_name.strip_edges().is_empty() or visual_scene == null:
		errors.append("Zombie needs identity and a visual scene.")
	for value in [max_health, move_speed, rotation_speed, damage, attack_range, attack_interval, detection_range, navigation_interval, death_delay, visual_scale]:
		if not is_finite(value) or value <= 0:
			errors.append("Zombie tuning values must be finite and positive.")
	if not is_finite(attack_windup) or attack_windup < 0 or attack_windup >= attack_interval:
		errors.append("Attack windup must be nonnegative and shorter than interval.")
	if detection_range < attack_range:
		errors.append("Detection range must include attack range.")
	return errors
