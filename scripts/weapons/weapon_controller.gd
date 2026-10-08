class_name WeaponController
extends Node3D

signal shot_fired
signal state_changed
signal feedback(message: String)
signal hit_confirmed
signal melee_started
signal melee_hit

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
var swings_started: int = 0
var melee_hits: int = 0
var ammo_selection_used := false
var _player: PlayerController
var _inventory: Inventory
var _equipment: EquipmentLoadout
var _mode: GameplayModeController
var _socket: Node3D
var pose_driver: RiflePose
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
	# Post-animation arm pose follows the unit-scale socket and its two grip markers.
	for skeleton in player.visual.find_children("*", "Skeleton3D", true, false):
		if skeleton.find_bone("Middle1.R") >= 0:
			pose_driver = RiflePose.new()
			pose_driver.name = "RiflePose"
			skeleton.add_child(pose_driver)
			pose_driver.setup(self, player)
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
		for ammo in data.get_compatible_ammo():
			if catalog == null or catalog.get_item(ammo.id) != ammo:
				errors.append("Weapon '%s' references compatible ammo outside the catalog." % data.weapon_id)
	return errors


func reserve_ammo(ammo: ItemData = null) -> int:
	if current == null or current.data.is_melee(): return 0
	if ammo == null: ammo = current.selected_ammo_type
	return _inventory.get_item_amount(ammo.id) if ammo != null else 0


func available_ammo() -> Array[ItemData]:
	var result: Array[ItemData] = []
	if current == null or current.data.is_melee(): return result
	for ammo in current.data.get_compatible_ammo():
		if reserve_ammo(ammo) > 0 or (current.current_magazine > 0 and current.magazine_ammo_type == ammo):
			result.append(ammo)
	return result


func cycle_ammo() -> bool:
	if _committing or not can_control() or current == null or current.data.is_melee() or current.is_reloading: return false
	var choices := available_ammo()
	if choices.is_empty() or (choices.size() == 1 and choices[0] == current.selected_ammo_type): return false
	var next := choices[posmod(choices.find(current.selected_ammo_type) + 1, choices.size())]
	current.selected_ammo_type = next
	ammo_selection_used = true
	feedback.emit(next.display_name)
	state_changed.emit()
	# Swaps use the same timed reload and commit path. Cancellation keeps old rounds.
	start_reload()
	return true


func can_control() -> bool:
	return _valid and _player != null and _player.camera_rig.can_control() and not _mode.is_farming() and not _player.health.is_dead


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	if event.is_action_released("fire"):
		_fire_held = false
	if not can_control(): return
	if event.is_action_pressed("fire"):
		_fire_held = current != null and not current.data.is_melee() and current.data.automatic and _player.camera_rig.is_aiming
		try_fire()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("reload"):
		start_reload()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cycle_ammo"):
		cycle_ammo()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if _player == null: return
	if pose_driver != null: pose_driver.tick(delta)
	update_weapon_pose()
	for state in runtimes.values():
		state.fire_cooldown -= delta
		if state != current or not _fire_held:
			state.fire_cooldown = maxf(0, state.fire_cooldown)
	if current != null and current.is_reloading:
		current.reload_remaining -= delta
		if current.reload_remaining <= 0:
			_finish_reload()
	if current != null and current.is_swinging:
		if not can_control():
			_cancel_actions()
		else:
			var state := current
			state.swing_elapsed += delta
			if not state.swing_hit_committed and state.swing_elapsed >= state.data.melee_hit_delay:
				state.swing_hit_committed = true
				update_weapon_pose()
				_resolve_melee_hit(state)
			if state.swing_elapsed >= state.data.melee_swing_duration:
				state.is_swinging = false
				state_changed.emit()
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
		_player.aim_ray.update_aim()
		if pose_driver != null: pose_driver.update_socket()


func get_socket() -> Node3D:
	return _socket


func try_fire() -> bool:
	if current != null and current.data.is_melee(): return try_swing()
	if _committing or not can_control() or not _player.camera_rig.is_aiming or current == null or not is_instance_valid(muzzle):
		return false
	if current.is_reloading or current.fire_cooldown > 0.000001: return false
	if current.current_magazine <= 0:
		feedback.emit("Empty magazine — press R to reload")
		return false
	_committing = true
	update_weapon_pose()
	var state := current
	var ammo := state.magazine_ammo_type
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
			if (last_hit as Node).has_method("apply_ammo_effect"):
				last_hit.apply_ammo_effect(ammo)
			hit_confirmed.emit()
		if ammo != null and ammo.impact_vfx != null:
			var impact := ammo.impact_vfx.instantiate() as Node3D
			if impact != null:
				get_tree().current_scene.add_child(impact)
				impact.global_position = last_shot_end
				var normal: Vector3 = hit.get("normal", Vector3.UP)
				if not normal.is_zero_approx():
					impact.quaternion = Quaternion(Vector3.UP, normal.normalized())
	_flash_time = 0.07
	if is_instance_valid(_flash): _flash.show()
	if state.data.recoil_degrees > 0:
		_player.camera_rig.orbit(0, deg_to_rad(state.data.recoil_degrees))
	_committing = false
	state_changed.emit()
	shot_fired.emit()
	if pose_driver != null: pose_driver.kick()
	return true


func attack_facing() -> Vector3:
	return current.swing_direction if current != null and current.is_swinging else Vector3.ZERO


func try_swing() -> bool:
	if _committing or not can_control() or current == null or not current.data.is_melee(): return false
	if current.is_swinging or current.fire_cooldown > 0.000001 or not _inventory.has_item(current.data.weapon_id): return false
	_fire_held = false
	current.is_swinging = true
	current.swing_elapsed = 0
	current.swing_hit_committed = false
	current.swing_direction = _player.visual.global_basis.z
	current.swing_direction.y = 0
	current.swing_direction = current.swing_direction.normalized()
	current.fire_cooldown = 1.0/current.data.fire_rate
	swings_started += 1
	last_hit = null
	update_weapon_pose()
	state_changed.emit()
	melee_started.emit()
	return true


func _resolve_melee_hit(state: WeaponRuntime) -> void:
	# One short volume query per swing. Centre-distance, forward arc and cover
	# checks bound contact to the bat sweep instead of a long camera hitscan.
	var data := state.data
	var start := _player.global_position+Vector3.UP*0.85
	var query := PhysicsShapeQueryParameters3D.new()
	# Cover the whole reach so longer blades still connect with nearby enemies.
	var shape := CapsuleShape3D.new()
	shape.radius = data.melee_radius
	shape.height = maxf(data.range_meters, data.melee_radius * 2.0)
	query.shape = shape
	query.transform = Transform3D(Basis(Quaternion(Vector3.UP, state.swing_direction)), start+state.swing_direction*data.range_meters*0.5)
	query.collision_mask = shot_collision_mask
	query.exclude = [_player.get_rid()]
	var space := get_world_3d().direct_space_state
	var target: Node3D
	var closest := INF
	for hit in space.intersect_shape(query,32):
		var candidate := hit.get("collider") as Node3D
		if candidate == null: continue
		var health := candidate.get_node_or_null("Health") as HealthComponent
		if health == null or health.is_dead: continue
		var displacement := candidate.global_position-_player.global_position
		if absf(displacement.y)>0.85: continue
		displacement.y=0
		var distance := displacement.length()
		if distance > data.range_meters or distance >= closest: continue
		if distance > 0.001 and displacement.normalized().dot(state.swing_direction) < cos(deg_to_rad(data.melee_arc_degrees)): continue
		var sight := _ray(start,candidate.global_position+Vector3.UP*0.85)
		if not sight.is_empty() and sight.get("collider") != candidate: continue
		target = candidate
		closest = distance
	if target == null: return
	_committing = true
	last_hit = target
	var receiver := target.get_node("Health") as HealthComponent
	receiver.take_damage(data.damage)
	melee_hits += 1
	_committing = false
	hit_confirmed.emit()
	melee_hit.emit()


func _ray(start: Vector3, end: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(start, end, shot_collision_mask, [_player.get_rid()])
	query.hit_from_inside = true
	return get_world_3d().direct_space_state.intersect_ray(query)


func start_reload() -> bool:
	if _committing or not can_control() or current == null or current.data.is_melee() or current.is_reloading: return false
	if current.current_magazine == 0 and reserve_ammo() == 0 and current.selected_ammo_type != current.data.ammo_type and reserve_ammo(current.data.ammo_type) > 0:
		current.selected_ammo_type = current.data.ammo_type
		feedback.emit("Switched to " + current.selected_ammo_type.display_name)
	var ammo := current.selected_ammo_type
	if not current.data.supports_ammo(ammo): return false
	var swapping := current.magazine_ammo_type != ammo
	if (not swapping and current.current_magazine >= current.data.magazine_size) or reserve_ammo() <= 0:
		feedback.emit("Magazine full" if not swapping and current.current_magazine >= current.data.magazine_size else "Out of " + ammo.display_name)
		state_changed.emit()
		return false
	var amount := mini(current.data.magazine_size if swapping else current.data.magazine_size - current.current_magazine, reserve_ammo())
	if swapping and current.current_magazine > 0 and not _inventory.can_exchange_items({ammo: amount}, {current.magazine_ammo_type: current.current_magazine}):
		feedback.emit("Bag full — cannot return loaded ammo")
		state_changed.emit()
		return false
	_fire_held = false
	current.is_reloading = true
	current.reload_ammo_type = ammo
	current.reload_remaining = current.data.reload_time
	state_changed.emit()
	return true


func _finish_reload() -> void:
	var state := current
	if state == null: return
	_committing = true
	state.is_reloading = false
	state.reload_remaining = 0
	var ammo := state.reload_ammo_type
	state.reload_ammo_type = null
	var swapping := state.magazine_ammo_type != ammo
	var amount := mini(state.data.magazine_size if swapping else state.data.magazine_size - state.current_magazine, reserve_ammo(ammo))
	var transferred := false
	if amount > 0 and state.data.supports_ammo(ammo):
		if swapping and state.current_magazine > 0:
			transferred = _inventory.exchange_items({ammo: amount}, {state.magazine_ammo_type: state.current_magazine})
		else:
			transferred = _inventory.remove_item(ammo.id, amount)
	if transferred:
		state.current_magazine = amount if swapping else state.current_magazine + amount
		state.magazine_ammo_type = ammo
	else:
		feedback.emit("Ammo swap unavailable — loaded ammo kept" if swapping else "Out of " + ammo.display_name)
	_committing = false
	state_changed.emit()


func _cancel_actions() -> void:
	_fire_held = false
	if current != null:
		current.is_reloading = false
		current.reload_remaining = 0
		current.reload_ammo_type = null
		current.is_swinging = false
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
			muzzle = visual.get_node_or_null(data.muzzle_path) as Node3D if not data.is_melee() else null
			_flash = visual.get_node_or_null("Muzzle/Flash") as MeshInstance3D
			if muzzle == null and not data.is_melee(): push_error("Weapon '%s' has no muzzle at %s." % [data.weapon_id, data.muzzle_path])
			break
	update_weapon_pose()
	state_changed.emit()
