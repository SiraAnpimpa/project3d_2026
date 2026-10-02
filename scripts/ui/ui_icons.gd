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
	"quit": "Power sign 256 px.png"
}
static var _cache: Dictionary = {}

static func get_icon(key: String) -> Texture2D:
	if not _cache.has(key):
		var path: String = FREE + FILES[key] if FILES.has(key) else "res://assets/ui/icons/%s.svg" % key
		_cache[key] = load(path)
	return _cache[key] as Texture2D

static func item_icon(item: ItemData) -> Texture2D:
	if item == null: return null
	match item.id:
		&"basic_rifle": return get_icon("rifle")
		&"basic_ammo": return get_icon("ammo")
		&"basic_medicine": return get_icon("health")
		&"metal_component": return get_icon("workbench")
	return item.icon

static func use_text(item: ItemData) -> String:
	if item == null: return "Select an item to inspect."
	match item.id:
		&"basic_rifle": return "RMB  Aim   ·   LMB  Fire\nR  Reload Basic Ammo"
		&"wooden_bat": return "LMB  Swing   ·   No ammo\nChoose a weapon slot below."
		&"basic_ammo": return "Basic Rifle ammunition\nR  Reload in Combat mode"
		&"basic_medicine": return "Crafted medicine\nItem use is not available yet."
		&"metal_component": return "Crafted component\nFor future equipment recipes."
		&"fire_ammo", &"ice_ammo", &"poison_ammo": return "Special ammunition\nNot supported by the Basic Rifle."
	return "Crafting material\nUse at the workbench."
