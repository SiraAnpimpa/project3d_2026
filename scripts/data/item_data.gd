class_name ItemData
extends Resource

enum ItemType { SEED, MATERIAL, CONSUMABLE, TOOL, WEAPON, AMMO, ARMOR, THROWABLE }
enum AmmoEffect { NONE, BURN, SLOW, POISON }

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var impact_vfx: PackedScene
@export_group("Consumable")
@export_range(0.0, 10000.0) var heal_amount: float = 0.0
@export var consume_on_use: bool = true
@export var heal_to_full: bool = false
@export_group("Armor")
@export_range(0.0, 0.95) var damage_reduction: float = 0.0
@export_group("Ammo effect")
@export var ammo_effect: AmmoEffect = AmmoEffect.NONE
@export_range(0.0, 30.0) var effect_duration: float = 0.0
@export_range(0.0, 100.0) var effect_damage_per_second: float = 0.0
@export_range(0.0, 1.0) var effect_max_health_per_second: float = 0.0
@export_range(0.0, 1000.0) var bonus_damage: float = 0.0
@export_range(0.0, 1000.0) var marksman_bonus_damage: float = 0.0
@export_range(0.1, 1.0) var effect_outgoing_damage_multiplier: float = 1.0
@export_range(0.1, 1.0) var effect_speed_multiplier: float = 1.0
@export_range(0.0, 30.0) var blast_radius: float = 0.0
@export_group("")
@export_range(1, 9999) var max_stack: int = 99
@export var item_type: ItemType = ItemType.MATERIAL
# Stable ID avoids circular Resource references: PlantData holds seed_item.
@export var plant_id: StringName
@export_group("Seed selection")
@export var plantable: bool = false
@export_range(1, 99) var tier: int = 1
@export_range(0, 9999) var display_order: int = 0


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(id).strip_edges().is_empty():
		errors.append("Item has an empty id.")
	if display_name.strip_edges().is_empty():
		errors.append("Item '%s' needs a display_name." % id)
	if max_stack <= 0:
		errors.append("Item '%s': max_stack must be greater than zero." % id)
	if item_type < ItemType.SEED or item_type > ItemType.THROWABLE:
		errors.append("Item '%s': unknown item_type." % id)
	if not is_finite(heal_amount) or heal_amount < 0 or heal_amount > 10000:
		errors.append("Item '%s': invalid heal_amount." % id)
	if heal_amount > 0 and item_type != ItemType.CONSUMABLE:
		errors.append("Item '%s': healing requires CONSUMABLE." % id)
	if not is_finite(damage_reduction) or damage_reduction < 0 or damage_reduction > 0.95 or (damage_reduction > 0 and item_type != ItemType.ARMOR):
		errors.append("Item '%s': invalid armor protection." % id)
	if item_type == ItemType.SEED and plant_id == &"":
		errors.append("Seed '%s' needs a plant_id." % id)
	if tier < 1 or display_order < 0:
		errors.append("Item '%s': tier must be positive and display_order nonnegative." % id)
	if ammo_effect < AmmoEffect.NONE or ammo_effect > AmmoEffect.POISON or not is_finite(effect_duration) or effect_duration < 0 or effect_duration > 30 or not is_finite(effect_damage_per_second) or effect_damage_per_second < 0 or effect_damage_per_second > 100 or not is_finite(effect_speed_multiplier) or effect_speed_multiplier < 0.1 or effect_speed_multiplier > 1:
		errors.append("Item '%s': invalid ammo effect parameters." % id)
	for value in [effect_max_health_per_second, bonus_damage, marksman_bonus_damage, effect_outgoing_damage_multiplier, blast_radius]:
		if not is_finite(value) or value < 0: errors.append("Item '%s': invalid elemental/throwable value." % id)
	if effect_max_health_per_second > 1 or effect_outgoing_damage_multiplier < 0.1 or effect_outgoing_damage_multiplier > 1:
		errors.append("Item '%s': effect percentage is outside its range." % id)
	if item_type == ItemType.THROWABLE and blast_radius <= 0: errors.append("Throwable needs a blast radius.")
	if ammo_effect != AmmoEffect.NONE and (item_type not in [ItemType.AMMO, ItemType.THROWABLE] or effect_duration <= 0):
		errors.append("Item '%s': effects require AMMO and a positive duration." % id)
	return errors
