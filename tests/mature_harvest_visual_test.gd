extends "res://tests/gameplay_plants_test.gd"
## Exercises existing E/clock/reward owners; fixture grants seeds for visual coverage.

func reward_bounds(visual: Node3D) -> AABB:
	var result := AABB()
	var found := false
	for mesh: MeshInstance3D in visual.find_children("*","MeshInstance3D",true,false):
		var box := (visual.global_transform.affine_inverse()*mesh.global_transform)*mesh.get_aabb()
		result = result.merge(box) if found else box
		found = true
	return result

func assert_stage(plot: FarmPlot, expected: int) -> void:
	var visual := plot.plant_visual
	var ready := expected == 3
	var id := String(plot.plant_data.plant_id)
	check(plot.growth_stage == expected and visual.stage == expected,"clock reaches actual growth stage %d: %s" % [expected,id])
	check(visual.harvest_visual != null and visual.harvest_visual.visible == ready,"reward is ready-only at stage %d: %s" % [expected,id])
	check(not visual.produce.visible,"generic marker does not duplicate reward: "+id)
	if visual.ambient_particles != null:
		check(visual.ambient_particles.emitting == ready and visual.ambient_particles.visible == ready,"element emitter is ready-only at stage %d: %s" % [expected,id])

func run() -> void:
	root.size = Vector2i(1600,900)
	set_meta("normal_play",true)
	game = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await game.wait_until_ready()
	player = game.player
	game.clock.paused = true
	game.waves.enabled = false
	game.progression.unlock_all()
	player.camera_rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	player.camera_rig.capture_mouse()
	var plots := game.get_node("MainWorld/FarmArea").get_children()
	var counts: Dictionary = {}
	var ready_nodes: Array[Node3D] = []
	check(game.catalog.plants.size() == 8 and game.catalog.get_plant(&"electric_plant") == null,"all actual crops covered; no Electric item/crop invented")
	for index in game.catalog.plants.size():
		var data: PlantData = game.catalog.plants[index]
		var plot: FarmPlot = plots[index]
		var id := String(data.plant_id)
		check(data.validation_errors().is_empty() and data.harvest_visual_scene != null,"valid PlantData maps reward scene: "+id)
		game.inventory.add_item(data.seed_item,1)
		game.inventory.select_seed(data.seed_item.id)
		var seeds: int = game.inventory.get_item_amount(data.seed_item.id)
		counts[data.harvest_item.id] = game.inventory.get_item_amount(data.harvest_item.id)
		await near_plot(plot)
		key(KEY_E)
		check(plot.state == FarmPlot.State.PLANTED and game.inventory.get_item_amount(data.seed_item.id) == seeds-1,"actual E plants and consumes one existing seed: "+id)
		assert_stage(plot,0)
		game.clock.advance_game_minutes(data.growth_minutes*.26)
		assert_stage(plot,1)
		game.clock.advance_game_minutes(data.growth_minutes*.4)
		assert_stage(plot,2)
		game.clock.advance_game_minutes(data.growth_minutes*.34+.001)
		assert_stage(plot,3)
		check(plot.state == FarmPlot.State.READY,"original clock marks Ready: "+id)
		var reward := plot.plant_visual.harvest_visual
		ready_nodes.append(reward)
		var box := reward_bounds(reward)
		check(box.position.x >= -.73 and box.end.x <= .73 and box.position.z >= -.73 and box.end.z <= .73 and box.position.y >= -.005 and box.end.y <= .86,"reward stays inside soil, above ground and below canopy: "+id)
		check(reward.find_children("*","CollisionObject3D",true,false).is_empty(),"reward adds no collision/pickup body: "+id)
		var scripted := reward.get_script() != null
		for node in reward.find_children("*","Node",true,false): scripted = scripted or node.get_script() != null
		check(not scripted,"reward scene has no runtime or pickup script: "+id)
		check(game.inventory.get_item_amount(data.harvest_item.id) == int(counts[data.harvest_item.id]),"viewing maturity never grants items: "+id)
	# Inspect all crops from actual movement camera, without UI/name help, day and night.
	for label in game.get_node("MainWorld").find_children("*","Label3D",true,false): label.hide()
	game.hud.get_node("Root").hide()
	for phase in ["day","night"]:
		game.clock.seek(1,10 if phase == "day" else 20,0)
		await farm_camera()
		await frames(40)
		await capture("mature_farm_"+phase+"_no_labels")
		for index in game.catalog.plants.size():
			var plot: FarmPlot = plots[index]
			await place_player(plot.global_position+Vector3(-1.05,.03,1.65))
			aim_at(player,plot.global_position+Vector3(0,.4,0))
			await frames(14)
			await capture("mature_"+String(plot.plant_data.plant_id)+"_"+phase)
	var first: FarmPlot = plots[0]
	var retained := first.plant_visual
	var capacity: int = game.inventory.capacity
	game.inventory.capacity = game.inventory.get_slots().size()
	await near_plot(first)
	key(KEY_E)
	check(first.state == FarmPlot.State.READY and first.plant_visual == retained and retained.harvest_visual.visible,"full inventory preserves ready crop and reward visual")
	game.inventory.capacity = capacity
	for index in game.catalog.plants.size():
		var plot: FarmPlot = plots[index]
		var data := plot.plant_data
		var vfx := plot.plant_visual.ambient_particles
		await near_plot(plot)
		key(KEY_E)
		await frames(3)
		check(plot.state == FarmPlot.State.EMPTY and plot.plant_visual == null and game.inventory.get_item_amount(data.harvest_item.id) == int(counts[data.harvest_item.id])+data.harvest_amount,"actual E harvest keeps exact existing item/yield: "+String(data.plant_id))
		check(not is_instance_valid(ready_nodes[index]) and not is_instance_valid(vfx),"harvest frees reward and VFX: "+String(data.plant_id))
	# Empty optional field remains compatible with existing stage-art fixtures.
	var fallback := game.catalog.plants[0].duplicate() as PlantData
	fallback.harvest_visual_scene = null
	fallback.show_produce_marker = true
	var legacy: PlantVisual = load("res://scenes/farming/Plant.tscn").instantiate()
	game.add_child(legacy)
	legacy.configure(fallback)
	legacy.set_stage(3)
	check(fallback.validation_errors().is_empty() and legacy.produce.visible,"optional reward field preserves legacy/future stage-art compatibility")
	legacy.queue_free()
	game.queue_free()
	await frames(4)
	# Drain render frames after freeing shared meshes/emitters before engine shutdown.
	for frame in 12: await process_frame
	print("MATURE_HARVEST_RESULT failures=",failures)
	quit(0 if failures == 0 else 1)
