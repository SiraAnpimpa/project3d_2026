extends "res://tests/phase_3_integration_test.gd"
## Exercise category selection with real mouse/keyboard input in both modal owners.

func run() -> void:
	root.size = Vector2i(1280, 720)
	var menu = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu._open_settings()
	var settings: UiSettingsPanel = menu.settings
	await frames(14)
	check(settings.categories.buttons[0].button_pressed, "General is selected on first opening")
	check_layout(settings, settings.categories)
	await capture("settings_general")
	await click_category(settings.categories, 1)
	check(settings.tabs.current_tab == 1 and settings.quality_option.is_visible_in_tree() and not settings.volume_slider.is_visible_in_tree(), "click Graphics reveals only graphics settings")
	await capture("settings_graphics")
	settings.categories.buttons[1].grab_focus()
	key(KEY_LEFT)
	await frames(12)
	check(settings.tabs.current_tab == 0 and settings.categories.buttons[0].has_focus(), "left arrow switches category and keeps focus on the rail")
	key(KEY_RIGHT)
	await frames(12)
	check(settings.tabs.current_tab == 1 and settings.categories.buttons[1].has_focus(), "right arrow selects Graphics with keyboard")
	settings.tabs.current_tab = 0
	await frames(12)
	check(settings.categories.buttons[0].button_pressed and not settings.categories.buttons[1].button_pressed, "programmatic page changes synchronize the selected category")
	key(KEY_ESCAPE)
	check(not settings.visible and menu._home.visible, "Esc closes title settings normally")
	menu.queue_free()
	await process_frame
	set_meta("normal_play", true)
	var game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	await frames(12)
	game.clock.paused = true
	key(KEY_T)
	await frames(14)
	var cheats: CheatMenu = game.cheats_menu
	check_layout(cheats.panel, cheats.categories)
	await capture("cheats_time")
	var day: int = game.clock.current_day
	for index in [1, 2, 0, 2, 1]: await click_category(cheats.categories, index)
	check(cheats.tabs.current_tab == 1 and cheats.item_option.is_visible_in_tree() and not cheats.zombie_option.is_visible_in_tree(), "repeated category switches keep the correct page visible")
	check(paused and cheats.tabs.get_current_tab_control().modulate.a > 0.99 and game.clock.current_day == day, "page fades finish while the game is paused without advancing the world")
	await capture("cheats_items")
	await click_category(cheats.categories, 2)
	await capture("cheats_zombies")
	PresentationStyle.reduced_motion = true
	await click_category(cheats.categories, 0, 2)
	check(cheats.tabs.get_current_tab_control().modulate.a == 1.0, "reduced motion shows the new page immediately")
	PresentationStyle.reduced_motion = false
	root.size = Vector2i(960, 540)
	await frames(14)
	check_layout(cheats.panel, cheats.categories)
	await capture("cheats_small")
	key(KEY_ESCAPE)
	key(KEY_ESCAPE)
	game.pause_menu._open_settings()
	settings = game.pause_menu.settings
	await frames(14)
	await click_category(settings.categories, 1)
	check_layout(settings, settings.categories)
	check(paused and settings.tabs.current_tab == 1, "pause settings use the same category navigation while keeping the game paused")
	await capture("settings_pause_small")
	root.size = Vector2i(1024, 768)
	await frames(14)
	check_layout(settings, settings.categories)
	await capture("settings_4_3")
	key(KEY_ESCAPE)
	key(KEY_ESCAPE)
	check(not paused and not game.pause_menu.is_open, "Esc returns through Pause to gameplay")
	game.queue_free()
	await frames(4)
	print("CATEGORY_NAVIGATION_RESULT failures=", failures)
	quit(1 if failures else 0)

func click_category(categories: UiCategoryTabs, index: int, settle: int = 14) -> void:
	var point := root.get_final_transform() * categories.buttons[index].get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = down
		root.push_input(event)
	await frames(settle)

func check_layout(panel: Control, categories: UiCategoryTabs) -> void:
	var rect := panel.get_global_rect()
	var visible := root.get_visible_rect()
	check(visible.encloses(rect), "panel and all controls fit viewport %s" % root.size)
	var width := categories.buttons[0].size.x
	check(categories.buttons.all(func(button: Button) -> bool: return absf(button.size.x - width) <= 1 and button.size.y >= 44 and button.icon != null), "category buttons have equal widths, legible icons and comfortable targets")
