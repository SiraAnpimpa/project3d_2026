class_name Workbench
extends Interactable

signal workbench_requested(actor: Node3D)


func _ready() -> void:
	prompt = "Use Workbench"


func interact(actor: Node3D) -> String:
	workbench_requested.emit(actor)
	return "Workbench opened"
