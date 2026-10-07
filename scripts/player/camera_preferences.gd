class_name CameraPreferences
extends RefCounted
## One persisted multiplier shared by both Settings panels and mouse-look.

const MINIMUM := 0.2
const MAXIMUM := 2.0
const DEFAULT := 1.0
const PATH := "user://settings.cfg"
static var _sensitivity := DEFAULT
static var _loaded := false

static func get_sensitivity() -> float:
	if not _loaded:
		_loaded = true
		var config := ConfigFile.new()
		if config.load(PATH) == OK:
			var value: Variant = config.get_value("camera", "camera_sensitivity", DEFAULT)
			if (value is float or value is int) and is_finite(float(value)):
				_sensitivity = clampf(float(value), MINIMUM, MAXIMUM)
	return _sensitivity

static func set_sensitivity(value: float) -> void:
	get_sensitivity()
	if not is_finite(value): return
	_sensitivity = clampf(value, MINIMUM, MAXIMUM)
	var config := ConfigFile.new()
	config.load(PATH)
	config.set_value("camera", "camera_sensitivity", _sensitivity)
	var error := config.save(PATH)
	if error != OK: push_warning("Could not save camera sensitivity: %s" % error_string(error))
