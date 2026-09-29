class_name TargetDummy
extends StaticBody3D

@onready var health: HealthComponent = $Health
@onready var mesh: MeshInstance3D = $Mesh
@onready var label: Label3D = $Label
var _flash_remaining := 0.0
var _material: StandardMaterial3D


func _ready() -> void:
	_material = mesh.get_active_material(0).duplicate() as StandardMaterial3D
	mesh.material_override = _material
	health.changed.connect(_on_health_changed)
	health.died.connect(func() -> void:
		collision_layer = 0
		queue_free())
	_on_health_changed(health.current_hp, health.max_hp)


func _on_health_changed(hp: float, maximum: float) -> void:
	label.text = "TARGET DUMMY\n%d / %d HP" % [ceili(hp), ceili(maximum)]
	if hp < maximum:
		_flash_remaining = 0.12
		_material.albedo_color = Color(1, 0.25, 0.1)


func _process(delta: float) -> void:
	_flash_remaining = maxf(0, _flash_remaining - delta)
	if _flash_remaining == 0:
		_material.albedo_color = Color(0.78, 0.63, 0.28)
