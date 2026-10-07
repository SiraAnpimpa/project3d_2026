extends "res://tests/cleanup_full_day.gd"
## Reuse the real farming/crafting/rifle/rest and no-rest survival scenarios,
## entering via MainMenu and reaching night through the production clock.

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
	await wait_for_gameplay()
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
	await super.wait_for_night()
	check(game.clock.is_nighttime and not paused,"full loop reaches night through the existing clock")
