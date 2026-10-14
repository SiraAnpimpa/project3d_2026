extends Node
signal state_changed
signal feedback(message: String)
var game: Node3D
var item: ItemData
var cooldown := 0.0

func bind(root_game: Node3D) -> void:
	game = root_game
	item = game.catalog.get_item(&"ice_grenade")
	set_physics_process(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_grenade") and not event.is_echo() and can_throw():
		throw_grenade()
		get_viewport().set_input_as_handled()

func can_throw() -> bool:
	return game != null and game.consumables.can_use_input() and not game.gameplay_mode.is_farming() and cooldown <= 0

func throw_grenade() -> bool:
	if not can_throw(): return false
	if not game.inventory.has_item(item.id):
		feedback.emit("No Ice Grenade")
		return false
	var start: Vector3 = game.player.global_position+Vector3.UP*1.25
	game.player.aim_ray.update_aim()
	var aim: Vector3 = game.player.aim_ray.aim_point
	var delta := aim-start
	if delta.length() > 18: aim = start + delta.normalized()*18
	var distance := start.distance_to(aim)
	var travel := clampf(distance/12,0.45,1.3)
	if not game.inventory.remove_item(item.id,1): return false
	cooldown = 0.65
	set_physics_process(true)
	var grenade = preload("res://scripts/inventory/ice_grenade.gd").new()
	grenade.item = item
	game.add_child(grenade)
	grenade.global_position = start
	grenade.linear_velocity = (aim-start)/travel+Vector3.UP*9.8*travel*0.5
	grenade.angular_velocity = Vector3(3,1,2)
	grenade.detonated.connect(func(_hits: int) -> void: game.audio.cue("bat_hit"); game.player.camera_rig.impact_shake(0.2))
	state_changed.emit()
	return true

func _physics_process(delta: float) -> void:
	cooldown = maxf(0,cooldown-delta)
	if cooldown <= 0:
		set_physics_process(false)
		state_changed.emit()
