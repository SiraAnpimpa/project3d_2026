extends Node
## Persistent presentation preferences shared by the title and pause menus.
## Changes apply only to rendering; gameplay, terrain and collisions are retained.

signal changed
enum Quality { LOW, MEDIUM, HIGH }
const PATH := "user://settings.cfg"
const PRESETS := [
	{"scale":0.65, "shadows":false, "grass":0.30, "distance":44.0, "shadow_distance":25.0},
	{"scale":0.85, "shadows":true, "grass":0.65, "distance":72.0, "shadow_distance":40.0},
	{"scale":1.0, "shadows":true, "grass":1.0, "distance":0.0, "shadow_distance":60.0},
]
var quality: int = Quality.MEDIUM
var shadows_enabled := true
var render_scale := 0.85

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	reload_preferences()
	apply()

func reload_preferences() -> void:
	var config := ConfigFile.new()
	config.load(PATH)
	var saved: Variant = config.get_value("graphics", "quality", Quality.MEDIUM)
	quality = clampi(saved, Quality.LOW, Quality.HIGH) if saved is int else Quality.MEDIUM
	var shadows: Variant = config.get_value("graphics", "shadows", PRESETS[quality].shadows)
	shadows_enabled = shadows if shadows is bool else bool(PRESETS[quality].shadows)
	var scale: Variant = config.get_value("graphics", "render_scale", PRESETS[quality].scale)
	render_scale = clampf(float(scale), 0.5, 1.0) if (scale is float or scale is int) and is_finite(float(scale)) else float(PRESETS[quality].scale)

func set_quality(value: int) -> void:
	quality = clampi(value, Quality.LOW, Quality.HIGH)
	shadows_enabled = PRESETS[quality].shadows
	render_scale = PRESETS[quality].scale
	_commit()

func set_shadows(value: bool) -> void:
	shadows_enabled = value
	_commit()

func set_render_scale(value: float) -> void:
	if not is_finite(value): return
	render_scale = clampf(value, 0.5, 1.0)
	_commit()

func _commit() -> void:
	var config := ConfigFile.new()
	config.load(PATH) # Preserve camera sensitivity and other sections.
	config.set_value("graphics", "quality", quality)
	config.set_value("graphics", "shadows", shadows_enabled)
	config.set_value("graphics", "render_scale", render_scale)
	var error := config.save(PATH)
	if error != OK: push_warning("Could not save graphics settings: %s" % error_string(error))
	apply()
	changed.emit()

func apply() -> void:
	var viewport := get_tree().root
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	viewport.scaling_3d_scale = render_scale
	viewport.msaa_3d = Viewport.MSAA_2X if quality == Quality.HIGH else Viewport.MSAA_DISABLED
	get_tree().call_group("graphics_world", "apply_graphics", quality, shadows_enabled)

func summary() -> String:
	return ["Sparse grass · short grass distance · no antialiasing", "Balanced grass · medium grass distance", "Full grass · full grass distance · 2× antialiasing"][quality]
