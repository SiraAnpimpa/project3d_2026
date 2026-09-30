class_name DayConfig
extends Resource

@export var day: int = 1
@export var wave: NightWaveData
@export var seed_unlocks: Array[StringName] = []
@export var recipe_unlocks: Array[StringName] = []
@export var starter_quantity: int = 3
# Basic daily supplies keep the finite starter seeds from exhausting after Day 1.
@export var supply_seed_ids: Array[StringName] = []
@export var supply_quantity: int = 0
@export var message: String = ""
