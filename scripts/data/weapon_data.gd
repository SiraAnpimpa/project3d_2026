class_name WeaponData
extends Resource

enum WeaponType { PISTOL, RIFLE, SHOTGUN, SPECIAL }

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


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(weapon_id).strip_edges().is_empty() or display_name.strip_edges().is_empty():
		errors.append("Weapon needs an ID and display name.")
	if weapon_type < WeaponType.PISTOL or weapon_type > WeaponType.SPECIAL:
		errors.append("Weapon '%s' has an invalid weapon_type." % weapon_id)
	if weapon_item == null or weapon_item.item_type != ItemData.ItemType.WEAPON or weapon_item.id != weapon_id:
		errors.append("Weapon '%s' needs a matching WEAPON ItemData." % weapon_id)
	if ammo_type == null or ammo_type.item_type != ItemData.ItemType.AMMO:
		errors.append("Weapon '%s' needs AMMO ItemData." % weapon_id)
	for item in [weapon_item, ammo_type]:
		if item != null: errors.append_array(item.validation_errors())
	if not is_finite(damage) or damage <= 0 or not is_finite(fire_rate) or fire_rate <= 0 or fire_rate > 60:
		errors.append("Weapon '%s': damage > 0 and fire_rate in (0, 60] required." % weapon_id)
	if magazine_size <= 0 or not is_finite(reload_time) or reload_time < 0 or not is_finite(range_meters) or range_meters <= 0:
		errors.append("Weapon '%s': invalid magazine, reload time or range." % weapon_id)
	if not is_finite(spread_degrees) or spread_degrees < 0 or spread_degrees > 45 or not is_finite(recoil_degrees) or recoil_degrees < 0:
		errors.append("Weapon '%s': invalid spread or recoil." % weapon_id)
	if weapon_scene == null or muzzle_path.is_empty():
		errors.append("Weapon '%s' needs a visual scene and muzzle path." % weapon_id)
	else:
		var model := weapon_scene.instantiate()
		if not model is Node3D or not model.get_node_or_null(muzzle_path) is Node3D:
			errors.append("Weapon '%s': scene must be Node3D with a muzzle marker." % weapon_id)
		model.free()
	return errors
