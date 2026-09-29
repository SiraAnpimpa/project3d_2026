class_name WeaponController
extends Node3D

signal state_changed
signal feedback(message: String)
signal hit_confirmed

@export var definitions: Array[WeaponData] = []
@export_flags_3d_physics var shot_collision_mask: int = 5

var current: WeaponRuntime
var runtimes: Dictionary[StringName, WeaponRuntime] = {}
var visual: Node3D
var muzzle: Node3D
var last_shot_origin := Vector3.ZERO
var last_shot_end := Vector3.ZERO
var last_hit: Object
var shots_fired: int = 0
var _player: PlayerController
var _inventory: Inventory
var _equipment: EquipmentLoadout
var _mode: GameplayModeController
var _socket: Node3D
var _hand_anchor: BoneAttachment3D
var _fire_held := false
var _committing := false
var _valid := false
var _flash_time := 0.0
var _flash: MeshInstance3D


func bind(player: PlayerController, inventory: Inventory, equipment: EquipmentLoadout, mode: GameplayModeController, catalog: ItemCatalog) -> void:
	_player = player
	_inventory = inventory
	_equipment = equipment
	_mode = mode
	_socket = player.get_node("Visual/WeaponSocket")
	# The imported skeleton uses a scale of 100. Follow only its hand position;
	# the scene socket keeps unit scale and aims the weapon independently of idle arms.
	for skeleton in player.visual.find_children("*", "Skeleton3D", true, false):
		if skeleton.find_bone("Middle1.R") >= 0:
			_hand_anchor = BoneAttachment3D.new()
			skeleton.add_child(_hand_anchor)
			_hand_anchor.bone_name = "Middle1.R"
			break
	var errors := validation_errors(catalog)
	_valid = errors.is_empty()
	for message in errors:
		push_error("Weapon data: " + message)
	equipment.equipment_changed.connect(_select_weapon)
	inventory.inventory_changed.connect(_on_inventory_changed)
	mode.mode_changed.connect(_on_mode_changed)
	player.camera_rig.controls_changed.connect(_on_controls_changed)
	player.camera_rig.aim_changed.connect(func(aiming: bool) -> void:
		if not aiming: _fire_held = false)
	player.health.died.connect(_cancel_actions)
	_select_weapon()


func validation_errors(catalog: ItemCatalog) -> PackedStringArray:
	var errors := PackedStringArray()
	var ids := {}
	for data in definitions:
		if data == null:
			errors.append("Missing WeaponData.")
			continue
		errors.append_array(data.validation_errors())
		if ids.has(data.weapon_id): errors.append("Duplicate weapon ID: " + String(data.weapon_id))
		ids[data.weapon_id] = true
		if catalog == null or (data.weapon_item != null and catalog.get_item(data.weapon_item.id) != data.weapon_item) or (data.ammo_type != null and catalog.get_item(data.ammo_type.id) != data.ammo_type):
			errors.append("Weapon '%s' references an item outside the catalog." % data.weapon_id)
	return errors


func reserve_ammo() -> int:
	return _inventory.get_item_amount(current.data.ammo_type.id) if current != null else 0


func can_control() -> bool:
	return _valid and _player != null and _player.camera_rig.can_control() and not _mode.is_farming() and not _player.health.is_dead


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	if event.is_action_released("fire"):
		_fire_held = false
	if not can_control(): return
	if event.is_action_pressed("fire"):
		_fire_held = current != null and current.data.automatic and _player.camera_rig.is_aiming
		try_fire()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("reload"):
		start_reload()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if _player == null: return
	update_weapon_pose()
	for state in runtimes.values():
		state.fire_cooldown -= delta
		if state != current or not _fire_held:
			state.fire_cooldown = maxf(0, state.fire_cooldown)
	if current != null and current.is_reloading:
		current.reload_remaining -= delta
		if current.reload_remaining <= 0:
			_finish_reload()
	if _fire_held and current != null and current.data.automatic:
		# Preserve the remainder, so fire rate does not round to whole physics ticks.
		while current.fire_cooldown <= 0:
			if not try_fire():
				_fire_held = false
				break
	_flash_time = maxf(0, _flash_time - delta)
	if is_instance_valid(_flash): _flash.visible = _flash_time > 0


func update_weapon_pose() -> void:
	if not is_instance_valid(visual): return
	visual.visible = not _mode.is_farming() and not _player.health.is_dead
	if visual.visible:
		if _hand_anchor != null:
			_socket.global_position = _hand_anchor.global_position
		_player.aim_ray.update_aim()
		var target := _player.aim_ray.aim_point
		if _socket.global_position.distance_squared_to(target) > 0.001:
			_socket.look_at(target, Vector3.UP, true)


func try_fire() -> bool:
	if _committing or not can_control() or not _player.camera_rig.is_aiming or current == null or not is_instance_valid(muzzle):
		return false
	if current.is_reloading or current.fire_cooldown > 0.000001: return false
	if current.current_magazine <= 0:
		feedback.emit("Empty magazine — press R to reload")
		return false
	_committing = true
	update_weapon_pose()
	var state := current
	state.current_magazine -= 1
	state.fire_cooldown += 1.0 / state.data.fire_rate
	shots_fired += 1
	var aim := _player.aim_ray
	var start := muzzle.global_position
	var direction := (aim.aim_point - start).normalized()
	if direction.is_zero_approx(): direction = aim.aim_direction
	if state.data.spread_degrees > 0:
		var tangent := direction.cross(Vector3.UP).normalized()
		if tangent.is_zero_approx(): tangent = Vector3.RIGHT
		direction = direction.rotated(tangent, deg_to_rad(randf_range(-state.data.spread_degrees, state.data.spread_degrees)))
		direction = direction.rotated(Vector3.UP, deg_to_rad(randf_range(-state.data.spread_degrees, state.data.spread_degrees)))
	var end := start + direction * state.data.range_meters
	# If the model penetrates cover, stop at the cover before using the muzzle ray.
	var safety_origin := _player.global_position + Vector3.UP * 1.2
	var hit := _ray(safety_origin, start)
	if hit.is_empty(): hit = _ray(start, end)
	last_shot_origin = start
	last_shot_end = hit.get("position", end)
	last_hit = hit.get("collider")
	if is_instance_valid(last_hit):
		var receiver := (last_hit as Node).get_node_or_null("Health") as HealthComponent
		if receiver != null and not receiver.is_dead:
			receiver.take_damage(state.data.damage)
			hit_confirmed.emit()
	_flash_time = 0.07
	if is_instance_valid(_flash): _flash.show()
	if state.data.recoil_degrees > 0:
		_player.camera_rig.orbit(0, deg_to_rad(state.data.recoil_degrees))
	_committing = false
	state_changed.emit()
	return true


func _ray(start: Vector3, end: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(start, end, shot_collision_mask, [_player.get_rid()])
	query.hit_from_inside = true
	return get_world_3d().direct_space_state.intersect_ray(query)


func start_reload() -> bool:
	if _committing or not can_control() or current == null or current.is_reloading: return false
	if current.current_magazine >= current.data.magazine_size or reserve_ammo() <= 0:
		feedback.emit("Magazine full" if current.current_magazine >= current.data.magazine_size else "No reserve ammo — craft Basic Ammo")
		return false
	_fire_held = false
	current.is_reloading = true
	current.reload_remaining = current.data.reload_time
	state_changed.emit()
	return true


func _finish_reload() -> void:
	var state := current
	if state == null: return
	_committing = true
	state.is_reloading = false
	state.reload_remaining = 0
	var amount := mini(state.data.magazine_size - state.current_magazine, reserve_ammo())
	if amount > 0 and _inventory.remove_item(state.data.ammo_type.id, amount):
		state.current_magazine += amount
	_committing = false
	state_changed.emit()


func _cancel_actions() -> void:
	_fire_held = false
	if current != null:
		current.is_reloading = false
		current.reload_remaining = 0
	state_changed.emit()


func _on_controls_changed(enabled: bool) -> void:
	if not enabled: _cancel_actions()


func _on_mode_changed(_value: GameplayModeController.Mode) -> void:
	_cancel_actions()
	update_weapon_pose()


func _on_inventory_changed() -> void:
	for id in runtimes.keys():
		if not _inventory.has_item(id): runtimes.erase(id)
	state_changed.emit()


func _select_weapon() -> void:
	var item := _equipment.get_selected_weapon()
	if current != null and item == current.data.weapon_item:
		state_changed.emit()
		return
	_cancel_actions()
	current = null
	muzzle = null
	_flash = null
	if is_instance_valid(visual):
		visual.hide()
		visual.queue_free()
	visual = null
	if _valid and item != null:
		for data in definitions:
			if data.weapon_item != item: continue
			if not runtimes.has(item.id): runtimes[item.id] = WeaponRuntime.new(data)
			current = runtimes[item.id]
			visual = data.weapon_scene.instantiate() as Node3D
			_socket.add_child(visual)
			muzzle = visual.get_node_or_null(data.muzzle_path) as Node3D
			_flash = visual.get_node_or_null("Muzzle/Flash") as MeshInstance3D
			if muzzle == null: push_error("Weapon '%s' has no muzzle at %s." % [data.weapon_id, data.muzzle_path])
			break
	update_weapon_pose()
	state_changed.emit()
