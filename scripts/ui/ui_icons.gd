class_name UiIcons
extends RefCounted
## Presentation adapter. Never mutates ItemData or inventory resources.

const FREE := "res://Asset/FREE version/Icon set 1/0.5x/"
const FILES := {
	"health": "Plus 256 px.png", "stamina": "Battery - full 256 px.png",
	"wave": "bone head 256 px.png", "workbench": "Wrench 2 256 px.png",
	"rest": "House 256 px.png", "bag": "Menu 256 px.png",
	"lock": "Lock 256 px.png", "close": "Cross 256 px.png",
	"play": "Play 256 px.png", "pause": "Pause 256 px.png",
	"wait": "Next - Speed Up 256 px.png", "next": "Next 256 px.png",
	"attack": "Click - left 256 px.png", "help": "Question 256 px.png",
	"notice": "Exclamation sign 256 px.png", "gift": "Gift 256 px.png",
	"quit": "Power sign 256 px.png", "settings": "Setting 1 256 px.png"
}
static var _cache: Dictionary = {}

static func get_icon(key: String) -> Texture2D:
	if not _cache.has(key):
		var path: String = FREE + FILES[key] if FILES.has(key) else "res://assets/ui/icons/%s.svg" % key
		if key in ["rifle", "ammo"]: path = "res://assets/ui/items/basic_%s.svg" % key
		_cache[key] = load(path)
	return _cache[key] as Texture2D

static func item_icon(item: ItemData) -> Texture2D:
	if item == null: return null
	return item.icon

static func category(item: ItemData) -> String:
	if item == null: return "FIELD SUPPLIES"
	match item.item_type:
		ItemData.ItemType.SEED: return "PLANTABLE SEED"
		ItemData.ItemType.WEAPON: return "OWNED WEAPON"
		ItemData.ItemType.AMMO: return "AMMUNITION"
		ItemData.ItemType.CONSUMABLE: return "CONSUMABLE"
	return "CRAFTING MATERIAL"

static func use_text(item: ItemData) -> String:
	if item == null: return "Select an item to inspect."
	if item.item_type == ItemData.ItemType.CONSUMABLE and item.heal_amount > 0:
		return "Close menus · F Use Medicine\nRestores %s HP · No waste at full health" % str(item.heal_amount)
	if item.item_type == ItemData.ItemType.AMMO:
		var effect := "Standard rounds"
		match item.ammo_effect:
			ItemData.AmmoEffect.BURN: effect = "Burn: %s HP/s · %ss" % [str(item.effect_damage_per_second), str(item.effect_duration)]
			ItemData.AmmoEffect.SLOW: effect = "Slow: %d%% · %ss" % [roundi((1.0 - item.effect_speed_multiplier) * 100), str(item.effect_duration)]
			ItemData.AmmoEffect.POISON: effect = "Poison: %s HP/s · %ss" % [str(item.effect_damage_per_second), str(item.effect_duration)]
		return "C Switch ammo · R Reload\n" + effect
	match item.id:
		&"basic_rifle": return "RMB Aim · LMB Fire\nR Reload"
		&"wooden_bat": return "LMB Swing · No ammo"
	return item.description if not item.description.is_empty() else "Material for the workbench."
