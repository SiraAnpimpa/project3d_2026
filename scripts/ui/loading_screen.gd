extends Control
## Resource progress is real; world preparation uses an indeterminate indicator.
@export var game_path := "res://scenes/main/GameRoot.tscn"
var _label: Label
var _bar: ProgressBar
var _preparing := false
var _game: Node3D
var _overlay: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_overlay = CanvasLayer.new()
	_overlay.layer = 100
	add_child(_overlay)
	var shade := ColorRect.new()
	shade.color = Color("102019")
	_overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	shade.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var rows := VBoxContainer.new()
	rows.theme = PresentationStyle.theme()
	rows.custom_minimum_size.x = 400
	rows.add_theme_constant_override("separation", 20)
	center.add_child(rows)
	var title := Label.new()
	title.text = "SOMCHAI’S LAST HARVEST"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 27)
	rows.add_child(title)
	_label = Label.new()
	_label.text = "Loading…"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.modulate = PresentationStyle.MUTED
	rows.add_child(_label)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size.y = 8
	_bar.show_percentage = false
	rows.add_child(_bar)
	# Render the loading UI before initiating any resource work.
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw
	if ResourceLoader.load_threaded_request(game_path) != OK:
		_fail()

func _input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if _preparing: return
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(game_path, progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if not progress.is_empty(): _bar.value = float(progress[0])*100.0
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		_preparing = true
		_prepare.call_deferred()
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		_fail()

func _prepare() -> void:
	var scene := ResourceLoader.load_threaded_get(game_path) as PackedScene
	if scene == null:
		_fail()
		return
	_label.text = "Loading…"
	_bar.indeterminate = true
	await get_tree().process_frame
	var instance := scene.instantiate()
	if not instance is Node3D or not instance.has_method("wait_until_ready"):
		instance.free()
		_fail()
		return
	_game = instance
	_game.process_mode = Node.PROCESS_MODE_DISABLED
	var camera = _game.get_node("Player/CameraPivot")
	camera._menu_open = true
	get_tree().set_meta("loading_world", true)
	# The opaque overlay remains above every game UI/world frame. Rendering each
	# newly prepared group here also warms its materials before gameplay begins.
	get_tree().root.add_child(_game)
	await _game.wait_until_ready()
	get_tree().remove_meta("loading_world")
	# The first particle render still cost ~60 ms after sharing its resources.
	# Warm the existing Basic impact behind the loading overlay; its material
	# shader is also used by the elemental variants. No shot or inventory change.
	if DisplayServer.get_name() != "headless":
		# Warm the three existing wave models, one render at a time. These disabled,
		# collision-free previews never enter the wave's spawn/alive counters.
		var scenes: Array[PackedScene] = []
		for day in _game.progression.data.days:
			if day.wave.composition.is_empty():
				if day.wave.zombie_scene != null and not scenes.has(day.wave.zombie_scene): scenes.append(day.wave.zombie_scene)
			else:
				for entry in day.wave.composition:
					if not scenes.has(entry.scene): scenes.append(entry.scene)
		for preview_scene in scenes:
			var preview := preview_scene.instantiate() as CharacterBody3D
			preview.process_mode = Node.PROCESS_MODE_DISABLED
			preview.collision_layer = 0
			preview.collision_mask = 0
			add_child(preview)
			preview.global_position = camera.camera.global_transform*Vector3(0,-0.8,-3)
			if preview.animation_player != null: preview.animation_player.advance(0)
			for mesh in preview._meshes: mesh.material_overlay = preview._hit_material
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			for mesh in preview._meshes: mesh.material_overlay = null
			preview.queue_free()
		var flash = _game.weapons._flash
		if is_instance_valid(flash):
			var weapon_visible: bool = _game.weapons.visual.visible
			var flash_transform: Transform3D = flash.transform
			_game.weapons.visual.show()
			flash.show()
			flash.global_position = camera.camera.global_transform*Vector3(0,0,-2)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			flash.transform = flash_transform
			flash.hide()
			_game.weapons.visual.visible = weapon_visible
		var impact_scene = _game.catalog.get_item(&"basic_ammo").impact_vfx
		var impact: Node3D = impact_scene.instantiate()
		add_child(impact)
		impact.global_position = camera.camera.global_transform*Vector3(0,0,-2)
		# Particle emission reaches its first visible draw after initialization.
		# Retain the burst for those renders rather than freeing it after one draw.
		for frame in 4:
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
		impact.queue_free()
	_label.text = "Ready"
	# Allow physics/navigation synchronization and the complete world to render.
	for frame in 3: await get_tree().process_frame
	var shade := _overlay.get_child(0) as Control
	var fade := create_tween()
	fade.tween_property(shade, "modulate:a", 0.0, 0.25)
	await fade.finished
	_game.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().current_scene = _game
	camera.set_menu_open(false)
	queue_free()

func _fail() -> void:
	set_process(false)
	if is_instance_valid(_game): _game.queue_free()
	if get_tree().has_meta("loading_world"): get_tree().remove_meta("loading_world")
	if get_tree().has_meta("normal_play"): get_tree().remove_meta("normal_play")
	get_node("/root/DayCheckpoint").begin_new()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().set_meta("loading_failed", true)
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
