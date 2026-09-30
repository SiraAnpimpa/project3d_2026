class_name WaveEntry
extends Resource

@export var scene: PackedScene
@export var count: int = 0

func validation_errors() -> PackedStringArray:
	if scene == null or count < 0 or count > 100:
		return ["Wave entry requires a scene and count 0..100."]
	var instance := scene.instantiate()
	var enemy := instance as NormalZombie
	if enemy == null:
		instance.free()
		return ["Wave scene must use the shared zombie controller."]
	var errors := enemy.data.validation_errors() if enemy.data != null else PackedStringArray(["Missing ZombieData"])
	enemy.free()
	return errors
