extends "res://tests/phase_7_full_day_test.gd"
## Reuse the real farming/crafting/rifle/rest and no-rest survival scenarios,
## entering via MainMenu and using only the new confirmed waiting action.

func new_game() -> void:
	if is_instance_valid(current_scene):
		current_scene.queue_free()
		await frames(3)
	var menu: Control = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(5)
	click_button(menu.play_button)
	await frames(20)
	game = current_scene
	player = game.player
	check(not game.debug_controls.active,"real MainMenu Play enters normal game")

func wait_for_night() -> void:
	if game.weapons.current.current_magazine > 0:
		mouse(MOUSE_BUTTON_RIGHT,true)
		await frames(12)
		var before: int = game.weapons.shots_fired
		mouse(MOUSE_BUTTON_LEFT,true)
		mouse(MOUSE_BUTTON_LEFT,false)
		check(game.weapons.shots_fired==before+1,"prepared rifle fires immediately before waiting")
		mouse(MOUSE_BUTTON_RIGHT,false)
	key(KEY_N)
	await frames(3)
	check(game.skip_night.is_open and game.clock.is_daytime,"full loop requires confirmation before night")
	click_button(game.skip_night.confirm_button)
	await frames(3)
	check(game.clock.is_nighttime and not paused,"full loop confirms waiting using actual UI input")
