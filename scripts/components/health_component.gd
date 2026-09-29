class_name HealthComponent
extends Node

signal changed(current: float, maximum: float)
signal died

@export_range(1.0, 10000.0) var max_hp: float = 100.0
var current_hp: float = 100.0
var is_dead: bool = false


func _ready() -> void:
	reset()


func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	_set_hp(current_hp - amount)
	if current_hp <= 0.0:
		die()


func heal(amount: float) -> void:
	if not is_dead and amount > 0.0:
		_set_hp(current_hp + amount)


func die() -> void:
	if is_dead:
		return
	_set_hp(0.0)
	is_dead = true
	died.emit()


func reset() -> void:
	is_dead = false
	current_hp = max_hp
	changed.emit(current_hp, max_hp)


func _set_hp(value: float) -> void:
	current_hp = clampf(value, 0.0, max_hp)
	changed.emit(current_hp, max_hp)
