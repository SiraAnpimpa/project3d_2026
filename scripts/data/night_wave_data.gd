class_name NightWaveData
extends Resource

@export var composition: Array[WaveEntry] = []
@export var max_active_zombies: int = 12
@export var day: int = 1
@export var normal_zombie_count: int = 6
@export var spawn_interval: float = 2.0
@export var minimum_spawn_distance: float = 12.0
@export var zombie_scene: PackedScene


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if day < 1 or max_active_zombies < 1 or max_active_zombies > 15 or (composition.is_empty() and (normal_zombie_count < 1 or normal_zombie_count > 100 or zombie_scene == null)):
		errors.append("Wave requires day >= 1, 1..100 zombies and a scene.")
	if not is_finite(spawn_interval) or spawn_interval <= 0 or not is_finite(minimum_spawn_distance) or minimum_spawn_distance < 0:
		errors.append("Wave spawn interval must be positive and minimum distance nonnegative.")
	for entry in composition:
		if entry == null: errors.append("Null wave entry")
		else: errors.append_array(entry.validation_errors())
	if not composition.is_empty() and spawn_queue().is_empty(): errors.append("Wave must contain enemies")
	return errors


func spawn_queue() -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	if composition.is_empty():
		for index in normal_zombie_count: result.append(zombie_scene)
		return result
	var remaining: Array[int] = []
	for entry in composition: remaining.append(entry.count if entry != null else 0)
	while true:
		var added := false
		for index in composition.size():
			if remaining[index] <= 0: continue
			result.append(composition[index].scene)
			remaining[index] -= 1
			added = true
		if not added: break
	return result

func preview() -> String:
	var parts := PackedStringArray()
	if composition.is_empty(): return "Normal x%d" % normal_zombie_count
	for entry in composition:
		if entry.count <= 0: continue
		var enemy := entry.scene.instantiate() as NormalZombie
		parts.append("%s x%d" % [enemy.data.display_name.trim_suffix(" Zombie"), entry.count])
		enemy.free()
	return "  |  ".join(parts)
