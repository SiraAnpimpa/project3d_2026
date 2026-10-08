extends "res://tests/phase_3_integration_test.gd"
## Exercise real hover/click input and settings shared across title/game scenes.

var game: Node3D
var graphics: Node
var _saved_config := ""
var _had_config := false

func run() -> void:
	root.size = Vector2i(1280, 720)
	graphics = root.get_node("GraphicsSettings")
	_had_config = FileAccess.file_exists(graphics.PATH)
	if _had_config: _saved_config = FileAccess.get_file_as_string(graphics.PATH)
	var menu = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu._open_settings()
	var settings: UiSettingsPanel = menu.settings
	settings.tabs.current_tab = 1
	await frames(12)
	check(settings.quality_option.item_count == 3 and settings.shadows_button.visible, "title menu exposes three quality presets and independent shadows")
	check(settings.get_global_rect().end.y <= root.get_visible_rect().size.y, "graphics controls and Back button fit the settings window")
	settings.quality_option.select(0)
	settings.quality_option.item_selected.emit(0)
	check(graphics.quality == 0 and not graphics.shadows_enabled and is_equal_approx(root.scaling_3d_scale, 0.65), "Low applies saved 65% 3D rendering and shadows off before starting")
	await capture("settings_low")
	key(KEY_ESCAPE)
	check(not settings.visible and menu._home.visible, "Esc returns from title settings")
	menu.queue_free()
	await process_frame
	set_meta("normal_play", true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	await frames(10)
	game.clock.paused = true
	var sun: DirectionalLight3D = game.get_node("MainWorld/Sun")
	var grasses := get_nodes_in_group("graphics_grass")
	check(not sun.shadow_enabled and not grasses.is_empty(), "saved Low preset reaches newly created game and grass batches")
	var collisions := game.find_children("*", "CollisionShape3D", true, false).size()
	var enemies: int = game.waves.alive.size()
	var original_transforms := (grasses[0] as MultiMeshInstance3D).multimesh.buffer
	var low_count := 0
	var total := 0
	for grass: MultiMeshInstance3D in grasses:
		low_count += grass.multimesh.visible_instance_count
		total += grass.multimesh.instance_count
	check(grasses.all(func(grass: MultiMeshInstance3D) -> bool: return grass.visibility_range_end == 44 and grass.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF), "Low grass uses distance culling without grass shadows")
	check(low_count < total * 0.4 and low_count > 0, "Low reduces decorative grass instances while retaining nearby cover")
	key(KEY_TAB)
	await frames(15)
	var bag: InventoryUI = game.inventory_ui
	check(bag.is_open and paused, "Tab opens bag and owns pause")
	check(bag.grid.get_parent().get_parent().get_parent() != bag._owned_weapons.get_parent().get_parent().get_parent(), "weapons and supplies have distinct panel windows")
	check(_cards(root).is_empty(), "no item description is permanently displayed on opening")
	var seed_before: StringName = game.inventory.selected_seed_id
	var hovered := bag.slot_buttons[1] as UiItemSlot
	await hover(hovered)
	var cards := _cards(root)
	check(cards.size() == 1 and cards[0] is ItemTooltip, "real mouse hover opens a separate item description")
	if not cards.is_empty():
		var labels := (cards[0] as Control).find_children("*", "Label", true, false)
		check(labels.any(func(label: Label) -> bool: return label.text.contains("Growth")) and labels.any(func(label: Label) -> bool: return label.text.contains("Click to select")), "hover card shows growth, harvest and accurate selection instruction")
	check(game.inventory.selected_seed_id == seed_before, "hover does not change selected seed or gameplay state")
	await capture("inventory_hover")
	await click_scaled(hovered)
	check(game.inventory.selected_seed_id == &"seed_paper", "click still selects seed for planting")
	var weapon_cell: UiItemSlot
	for cell: UiItemSlot in bag.slot_buttons:
		if cell.tooltip_item != null and cell.tooltip_item.id == &"pistol": weapon_cell = cell
	await hover(weapon_cell)
	cards = _cards(root)
	check(cards.size() == 1, "hover transfers from seed to weapon without retaining old card")
	if not cards.is_empty():
		check(cards[0].find_children("*", "Label", true, false).any(func(label: Label) -> bool: return label.text.contains("Damage  ·  20")), "weapon card reads current weapon damage")
	await capture("inventory_weapon_hover")
	await click_scaled(weapon_cell)
	await click_scaled(bag.equipment_buttons[2])
	check(game.equipment.get_equipped_weapon(2).id == &"pistol" and game.equipment.get_equipped_weapon(0) == null, "select weapon and loadout slot moves weapon without duplication")
	await click_scaled(bag.unequip_buttons[2])
	check(game.equipment.get_equipped_weapon(2) == null and game.inventory.has_item(&"pistol"), "unequip preserves ownership in weapon window")
	key(KEY_ESCAPE)
	await frames(4)
	check(not paused and _cards(root).is_empty(), "closing bag clears hover card and restores gameplay")
	key(KEY_ESCAPE)
	game.pause_menu._open_settings()
	settings = game.pause_menu.settings
	settings.tabs.current_tab = 1
	await frames(12)
	check(settings.quality_option.selected == 0, "pause settings reflect title menu graphics")
	settings.quality_option.select(2)
	settings.quality_option.item_selected.emit(2)
	check(paused and sun.shadow_enabled and root.msaa_3d == Viewport.MSAA_2X and root.scaling_3d_scale == 1.0, "High applies full resolution, shadows and antialiasing while paused")
	check(grasses.all(func(grass: MultiMeshInstance3D) -> bool: return grass.multimesh.visible_instance_count == grass.multimesh.instance_count and grass.visibility_range_end == 0), "High restores every original grass instance")
	check(original_transforms == (grasses[0] as MultiMeshInstance3D).multimesh.buffer, "switching presets preserves all authored grass transforms")
	check(game.find_children("*", "CollisionShape3D", true, false).size() == collisions and game.waves.alive.size() == enemies, "quality changes retain collisions and enemy state")
	await click_scaled(settings.shadows_button)
	check(not sun.shadow_enabled and graphics.quality == 2, "shadows can be disabled independently on High")
	settings.render_scale_slider.value = 0.75
	check(root.scaling_3d_scale == 0.75 and root.content_scale_size == Vector2i(1280,720), "3D resolution changes independently while UI resolution stays fixed")
	CameraPreferences.set_sensitivity(1.3)
	graphics.reload_preferences()
	check(graphics.quality == 2 and not graphics.shadows_enabled and graphics.render_scale == 0.75 and CameraPreferences.get_sensitivity() == 1.3, "saved graphics and camera settings preserve each other")
	await capture("settings_custom")
	key(KEY_ESCAPE)
	check(game.pause_menu.is_open and not settings.visible and paused, "Esc closes graphics settings back to pause")
	key(KEY_ESCAPE)
	check(not paused and not game.pause_menu.is_open, "second Esc resumes gameplay")
	# All seven weapons and a full inventory remain scrollable at smaller displays.
	for definition: WeaponData in game.weapons.definitions:
		if not game.inventory.has_item(definition.weapon_item.id): game.inventory.add_item(definition.weapon_item)
	game.inventory_ui.set_open(true)
	await frames(10)
	await capture("inventory_all_weapons")
	root.size = Vector2i(960, 540)
	await frames(12)
	check(bag._panel.get_global_rect().end.x <= root.get_visible_rect().size.x and bag._panel.get_global_rect().end.y <= root.get_visible_rect().size.y, "inventory remains within scaled small display")
	await capture("inventory_small")
	bag.set_open(false)
	game.queue_free()
	await frames(4)
	_restore()
	print("INVENTORY_GRAPHICS_RESULT failures=", failures)
	quit(1 if failures else 0)

func click_scaled(button: Control) -> void:
	var point := root.get_final_transform() * button.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = down
		root.push_input(event)
	await frames(2)

func hover(button: Control) -> void:
	var event := InputEventMouseMotion.new()
	event.position = root.get_final_transform() * button.get_global_rect().get_center()
	event.global_position = event.position
	root.push_input(event)
	await create_timer(0.65).timeout
	await frames(3)

func _cards(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	if node is ItemTooltip and node.is_visible_in_tree(): result.append(node)
	for child in node.get_children(true): result.append_array(_cards(child))
	return result

func _restore() -> void:
	if _had_config:
		var file := FileAccess.open(graphics.PATH, FileAccess.WRITE)
		file.store_string(_saved_config)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(graphics.PATH))
	graphics.reload_preferences()
	graphics.apply()
