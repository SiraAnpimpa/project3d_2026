extends ThirdPersonCamera
## Models the browser's delayed permission/lock result in the native test runner.

var pointer_locked := false
var capture_requested := false

func is_web_build() -> bool:
	return true

func has_pointer_capture() -> bool:
	return pointer_locked

func _capture_pointer() -> void:
	capture_requested = true
	_capture_frame = Engine.get_process_frames()

func set_menu_open(value: bool) -> void:
	if value: pointer_locked = false
	super.set_menu_open(value)

func release_mouse() -> void:
	pointer_locked = false
	super.release_mouse()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pointer_locked = false
	super._notification(what)
