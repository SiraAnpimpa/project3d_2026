extends "res://tests/arsenal_test.gd"
## Presentation-only setup; the farming fixture proves weapon acquisition.
func run() -> void:
	root.size = Vector2i(1280,720)
	await new_game()
	for id in [&"knife",&"sword",&"pistol",&"smg",&"marksman_rifle"]:
		bag.add_item(game.catalog.get_item(id))
	await place_player(RuralTerrain.ground_point(14,6)+Vector3.UP*.03)
	for id in [&"knife",&"sword",&"pistol",&"smg",&"marksman_rifle"]:
		await equip(id)
		player.visual.rotation.y = PI
		player.camera_rig.rotation.y = PI-.65
		await frames(25)
		check(weapons.current.data.is_melee()==(id in [&"knife",&"sword"]),"weapon role matches authored data "+String(id))
		check(weapons.pose_driver.right_error<.15,"right hand reaches grip "+String(id))
		check(weapons.pose_driver.left_error<.15,"support hand follows configured hold "+String(id))
		check(weapons.current.data.two_handed == (id in [&"pistol",&"smg",&"marksman_rifle"]),"one/two-hand stance is data driven "+String(id))
		await capture("arsenal_day_"+String(id))
	key(KEY_TAB)
	await frames(15)
	check(Rect2(Vector2.ZERO,Vector2(root.size)).encloses(game.inventory_ui._panel.get_global_rect()),"seven-weapon inventory fits 720p")
	await capture("arsenal_inventory_720")
	root.size = Vector2i(1920,1080)
	await frames(15)
	check(Rect2(Vector2.ZERO,Vector2(root.size)).encloses(game.inventory_ui._panel.get_global_rect()),"seven-weapon inventory fits 1080p")
	await capture("arsenal_inventory_1080")
	key(KEY_TAB)
	game.queue_free()
	await frames(5)
	print("ARSENAL_PRESENTATION_RESULT failures=",failures)
	quit(1 if failures else 0)
