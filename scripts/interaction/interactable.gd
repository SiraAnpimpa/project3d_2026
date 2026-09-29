class_name Interactable
extends StaticBody3D

signal prompt_changed

signal interaction_requested(actor: Node3D)

@export var prompt: String = "Test interaction"
@export_multiline var response: String = "Interaction Successful"
@export var enabled: bool = true
@export var interaction_height: float = 0.7


func is_available(_actor: Node3D) -> bool:
	return enabled


func get_interaction_point() -> Vector3:
	return global_position + Vector3.UP * interaction_height


# Future interactables can override this method without changing the player.
func interact(actor: Node3D) -> String:
	interaction_requested.emit(actor)
	return response


func get_interaction_text(_actor: Node3D, key_hint: String) -> String:
	return "[%s]  %s" % [key_hint, prompt]
