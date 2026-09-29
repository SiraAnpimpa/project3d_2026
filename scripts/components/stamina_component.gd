class_name StaminaComponent
extends Node

signal changed(current: float, maximum: float)

@export_range(1.0, 10000.0) var max_stamina: float = 100.0
@export_range(0.0, 1000.0) var drain_rate: float = 22.0
@export_range(0.0, 1000.0) var recovery_rate: float = 18.0
@export_range(0.0, 10.0) var recovery_delay: float = 1.2
@export_range(0.01, 1.0) var restart_fraction: float = 0.25

var current_stamina: float = 100.0
var exhausted: bool = false
var recovery_wait: float = 0.0


func _ready() -> void:
	reset()


# Called once per player physics step; returns whether sprint is allowed this step.
func tick(delta: float, wants_sprint: bool) -> bool:
	if delta <= 0.0:
		return false
	if wants_sprint and not exhausted and current_stamina > 0.0:
		drain(drain_rate * delta)
		return not exhausted
	var recovery_delta := maxf(0.0, delta - recovery_wait)
	recovery_wait = maxf(0.0, recovery_wait - delta)
	if recovery_delta > 0.0:
		restore(recovery_rate * recovery_delta)
	return false


func drain(amount: float) -> void:
	if amount <= 0.0:
		return
	recovery_wait = recovery_delay
	_set_stamina(current_stamina - amount)
	if current_stamina <= 0.0:
		exhausted = true


func restore(amount: float) -> void:
	if amount <= 0.0:
		return
	_set_stamina(current_stamina + amount)
	if current_stamina >= max_stamina * restart_fraction:
		exhausted = false


func reset() -> void:
	current_stamina = max_stamina
	exhausted = false
	recovery_wait = 0.0
	changed.emit(current_stamina, max_stamina)


func _set_stamina(value: float) -> void:
	var next := clampf(value, 0.0, max_stamina)
	if not is_equal_approx(next, current_stamina):
		current_stamina = next
		changed.emit(current_stamina, max_stamina)
