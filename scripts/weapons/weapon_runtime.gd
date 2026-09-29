class_name WeaponRuntime
extends RefCounted

var data: WeaponData
var current_magazine: int = 0
var fire_cooldown: float = 0.0
var reload_remaining: float = 0.0
var is_reloading: bool = false


func _init(definition: WeaponData) -> void:
	data = definition
