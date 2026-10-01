class_name WeaponData
extends Resource

enum WeaponType { PISTOL, RIFLE, SHOTGUN, SPECIAL, MELEE }

@export var weapon_id: StringName
@export var display_name: String
@export_multiline var description: String
@export var weapon_type: WeaponType = WeaponType.RIFLE
@export var weapon_item: ItemData
@export var ammo_type: ItemData
@export var damage: float = 20.0
@export var fire_rate: float = 5.0 # Shots per second.
@export var magazine_size: int = 10
@export var reload_time: float = 1.5
@export var range_meters: float = 60.0
@export var automatic: bool = true
@export var spread_degrees: float = 0.0
@export var recoil_degrees: float = 0.0
@export var weapon_scene: PackedScene
@export var muzzle_path: NodePath = ^"Muzzle"
@export var icon: Texture2D

@export_group("Holding presentation")
# Offsets are in Somchai visual space, relative to the animated torso.
@export var ready_hold_offset := Vector3(-0.18, -0.06, 0.24)
@export var aim_hold_offset := Vector3(-0.18, 0.04, 0.21)
@export_range(-90.0, 90.0) var ready_pitch_degrees: float = 32.0

@export_group("Melee")
@export var melee_hit_delay: float = 0.18
@export var melee_swing_duration: float = 0.48
@export var melee_radius: float = 0.65
@export var melee_arc_degrees: float = 55.0
@export var melee_animation: StringName = &"CharacterArmature|Slash"


func is_melee() -> bool:
	return weapon_type == WeaponType.MELEE


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(weapon_id).strip_edges().is_empty() or display_name.strip_edges().is_empty():
		errors.append("Weapon needs an ID and display name.")
	if weapon_type < WeaponType.PISTOL or weapon_type > WeaponType.MELEE:
		errors.append("Weapon '%s' has an invalid weapon_type." % weapon_id)
	if weapon_item == null or weapon_item.item_type != ItemData.ItemType.WEAPON or weapon_item.id != weapon_id:
		errors.append("Weapon '%s' needs a matching WEAPON ItemData." % weapon_id)
	if not is_melee() and (ammo_type == null or ammo_type.item_type != ItemData.ItemType.AMMO):
		errors.append("Weapon '%s' needs AMMO ItemData." % weapon_id)
	for item in [weapon_item, ammo_type]:
		if item != null: errors.append_array(item.validation_errors())
	if not is_finite(damage) or damage <= 0 or not is_finite(fire_rate) or fire_rate <= 0 or fire_rate > 60:
		errors.append("Weapon '%s': damage > 0 and fire_rate in (0, 60] required." % weapon_id)
	if not is_finite(range_meters) or range_meters <= 0 or (not is_melee() and (magazine_size <= 0 or not is_finite(reload_time) or reload_time < 0)):
		errors.append("Weapon '%s': invalid magazine, reload time or range." % weapon_id)
	if is_melee():
		if ammo_type != null or magazine_size != 0 or reload_time != 0 or automatic:
			errors.append("Melee '%s' must be ammo-free with no magazine/reload or automatic fire." % weapon_id)
		if not is_finite(melee_hit_delay) or not is_finite(melee_swing_duration) or melee_hit_delay <= 0 or melee_hit_delay >= melee_swing_duration or (fire_rate>0 and melee_swing_duration > 1.0/fire_rate) or melee_animation==&"":
			errors.append("Melee '%s' needs hit delay < swing duration <= attack interval." % weapon_id)
		if not is_finite(melee_radius) or melee_radius <= 0 or melee_radius > range_meters or not is_finite(melee_arc_degrees) or melee_arc_degrees <= 0 or melee_arc_degrees > 90:
			errors.append("Melee '%s' needs a bounded forward hit volume." % weapon_id)
	if not is_finite(spread_degrees) or spread_degrees < 0 or spread_degrees > 45 or not is_finite(recoil_degrees) or recoil_degrees < 0:
		errors.append("Weapon '%s': invalid spread or recoil." % weapon_id)
	if not ready_hold_offset.is_finite() or not aim_hold_offset.is_finite() or not is_finite(ready_pitch_degrees):
		errors.append("Weapon '%s' has invalid holding offsets." % weapon_id)
	if weapon_scene == null or (not is_melee() and muzzle_path.is_empty()):
		errors.append("Weapon '%s' needs a visual scene and a muzzle for ranged attacks." % weapon_id)
	else:
		var model := weapon_scene.instantiate()
		if not model is Node3D:
			errors.append("Weapon '%s': visual must be Node3D." % weapon_id)
		elif is_melee():
			for marker in ["PrimaryGrip","SecondaryGrip","HitTip"]:
				if not model.get_node_or_null(marker) is Node3D:
					errors.append("Melee '%s': missing %s marker." % [weapon_id,marker])
		elif not model.get_node_or_null(muzzle_path) is Node3D:
			errors.append("Weapon '%s': scene must be Node3D with a muzzle marker." % weapon_id)
		model.free()
	return errors
