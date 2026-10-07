extends "res://tests/phase_9_presentation_test.gd"
## Presentation contracts plus real clicks; all setup changes are fixture-only.

func run() -> void:
	root.size = Vector2i(1280,720)
	await load_menu()
	await start_play()
	var hud: PrototypeHUD = game.hud
	var bag: InventoryUI = game.inventory_ui
	var craft: CraftingUI = game.crafting_ui
	check(hud.day_label.text == "Day 1" and hud.time_label.text == "06:00", "clock and day use current game signals")
	check(hud.seed_label.visible and not hud.ammo_label.visible and not hud._wave_panel.visible, "day farming shows seeds, hides weapon and wave HUD")
	check(hud.toast_label.text.length() < 59 and not hud.toast_label.text.contains("\n"), "unlock notification is one short line")
	for plot: FarmPlot in game.get_node("MainWorld/FarmArea").get_children():
		check(not plot.status_label.visible, "floating plot text hidden by UI: " + plot.name)
	check(not hud.debug_panel.visible and not bag.get_node("%DebugActions").visible, "normal play hides developer UI")
	key(KEY_TAB)
	await frames(15)
	check(not hud._equipment_panel.visible and not hud._stats_panel.visible, "modal screens hide gameplay HUD behind the shade")
	await click_scaled(bag.slot_buttons[1])
	await frames(2)
	check(game.inventory.selected_seed_id == &"seed_paper" and bag.inspected_item.id == &"seed_paper", "seed cell selects through original Inventory API")
	check(bag._detail_info.get_child_count() >= 5 and bag._detail_icon.texture == UiIcons.item_icon(bag.inspected_item), "seed details expose growth, output and conditions")
	game.inventory.add_item(game.catalog.get_item(&"lead"), 2)
	var seed_before: StringName = game.inventory.selected_seed_id
	await click_item(&"lead")
	check(bag.inspected_item.id == &"lead" and game.inventory.selected_seed_id == seed_before, "material inspection does not change planting selection")
	await click_item(&"wooden_bat")
	check(bag.selected_owned_weapon.id == &"wooden_bat" and not bag.equipment_buttons[2].disabled, "weapon inspection enables equipment assignment")
	await click_scaled(bag.equipment_buttons[2])
	await frames(3)
	check(game.equipment.get_equipped_weapon(2).id == &"wooden_bat" and game.equipment.get_equipped_weapon(1) == null, "real slot click moves owned weapon without duplicating")
	await click_scaled(bag.unequip_buttons[2])
	await frames(3)
	check(game.equipment.get_equipped_weapon(2) == null and game.inventory.has_item(&"wooden_bat"), "real clear click retains weapon in bag")
	await click_scaled(bag.equipment_buttons[1])
	await frames(3)
	check(game.equipment.get_equipped_weapon(1).id == &"wooden_bat", "real slot click restores bat loadout")
	for cell: Button in bag.slot_buttons:
		check(cell.text.is_empty(), "inventory cell uses image/count rather than repeated name")
	key(KEY_ESCAPE)
	await frames(3)
	check(not paused and hud._stats_panel.visible, "close returns input and HUD without stuck pause")
	key(KEY_Q)
	await frames(3)
	check(not hud.seed_label.visible and hud.ammo_label.visible and not hud.prompt_panel.visible and not game.skip_day.action_button.visible, "combat hides farming, craft prompt and daytime wait button")
	check(hud.toast_label.text.is_empty(), "mode switch clears prior farming notification")
	check(hud._selected_icon.texture == UiIcons.get_icon("rifle"), "rifle uses weapon art, not an iron ingot")
	game.player.health.take_damage(80)
	check(hud.hp_bar.value == 20 and hud.hp_label.text == "20" and hud._hurt_remaining > 0, "damage updates exact HP and a short red flash")
	await frames(240)
	check(hud.toast_label.text.is_empty() and not hud._toast_panel.visible and hud.damage_flash.color.a == 0, "toast and hurt effects fully expire")
	game.player.health.reset()
	key(KEY_Q)
	# Fill output capacity while retaining more ingredients than one batch uses.
	game.inventory.clear()
	for id in [&"lead", &"paper", &"copper"]: game.inventory.add_item(game.catalog.get_item(id), 3)
	game.inventory.capacity = 3
	craft.set_open(true)
	await frames(15)
	check(craft.craft_button.disabled and craft.feedback.text.contains("Bag full"), "full bag produces clear disabled craft state")
	var amount_before: int = game.inventory.get_item_amount(&"lead")
	await click_scaled(craft.craft_button)
	check(game.inventory.get_item_amount(&"lead") == amount_before, "disabled Craft cannot consume materials")
	game.inventory.capacity = 24
	game.inventory.remove_item(&"copper", 3)
	craft.refresh()
	check(craft.craft_button.disabled and craft.feedback.text == "More materials needed", "missing material state reflects existing recipe failure")
	craft.set_open(false)
	game.inventory.clear()
	key(KEY_TAB)
	await frames(15)
	check(bag.selection_label.text == "Empty bag" and bag.slot_buttons.all(func(cell: Button) -> bool: return cell.disabled), "empty bag has an explicit empty state and disabled cells")
	key(KEY_ESCAPE)
	check(not paused, "empty bag closes safely")
	check(PresentationStyle.TILE.get_width() == 32 and PresentationStyle.TILE.get_height() == 32,"existing button source imports at the intended nine-slice size")
	check(UiIcons.get_icon("health") == UiIcons.get_icon("health") and PresentationStyle.theme() == PresentationStyle.theme(), "textures and themes are shared rather than duplicated")
	key(KEY_ESCAPE)
	await frames(15)
	await click_scaled(game.pause_menu.get_node("Screen/Panel/Rows/Resume"))
	check(not paused and not game.pause_menu.is_open and game.player.camera_rig.can_control(),"actual Resume button returns gameplay controls")
	game.clock.skip_to_night()
	await frames(20)
	for tick in 100:
		game.waves._spawn_wait = 0
		game.waves.debug_kill_active()
		await frames(2)
		if game.waves.state == NightWaveManager.State.CLEARED: break
	check(game.waves.state == NightWaveManager.State.CLEARED,"fixture clears the existing night before rest")
	var bed: ShelterBed = game.get_node("MainWorld/Bed")
	game.player.position = bed.global_position + Vector3(0,0.25,1.35)
	game.player.velocity = Vector3.ZERO
	game.player.camera_rig.rotation.y = 0
	await frames(20)
	check(game.player.interactor.target == bed and hud.prompt_label.text == "Skip Night","rest prompt identifies the actual cabin target")
	game.player.health.take_damage(20)
	key(KEY_E)
	check(game.rest.is_resting and paused and not game.player.camera_rig.can_control(),"actual E starts existing rest and fade ownership")
	await frames(60)
	check(not game.rest.is_resting and not paused and game.clock.current_day == 2 and game.clock.is_daytime and game.player.health.current_hp == 100,"rest reaches morning, heals and restores controls through existing services")
	print("UI_POLISH_TEST_RESULT failures=", failures)
	quit(1 if failures else 0)

func click_item(id: StringName) -> void:
	var slots: Array = game.inventory.get_slots()
	for index in slots.size():
		if slots[index].item.id == id:
			await click_scaled(game.inventory_ui.slot_buttons[index])
			await frames(3)
			return
	check(false, "missing fixture item " + String(id))
