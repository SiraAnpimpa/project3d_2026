extends "res://tests/phase_6_zombie_test.gd"

func model_bounds(plant: PlantVisual) -> AABB:
	var result := AABB()
	var found := false
	for mesh: MeshInstance3D in plant.model_root.find_children("*","MeshInstance3D",true,false):
		var local: AABB = (plant.global_transform.affine_inverse()*mesh.global_transform)*mesh.get_aabb()
		result = result.merge(local) if found else local
		found = true
	return result

func near_plot(plot: FarmPlot) -> void:
	await place_player(plot.global_position+Vector3(0,0.03,0.95))
	await frames(8)

func farm_camera() -> void:
	await place_player(RuralTerrain.ground_point(-13.4,17.5)+Vector3.UP*0.03)
	player.camera_rig.rotation.y=0
	player.camera_rig.pitch_pivot.rotation.x=-0.35
	player.camera_rig.update_pose(1)
	player.camera_rig.camera.current=true
	await frames(12)

func run() -> void:
	root.size=Vector2i(1600,900)
	set_meta("normal_play",true)
	game=load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene=game
	await frames(30)
	player=game.player
	game.clock.paused=true
	game.debug_controls.set_active(false)
	game.clock.seek(7,6,0) # Visual/seed availability fixture, not earned progression evidence.
	game.clock.paused=true
	var plots:=game.get_node("MainWorld/FarmArea").get_children()
	var sources: Dictionary={}
	var yields: Dictionary={}
	check(game.catalog.plants.size()==8 and game.catalog.get_plant(&"water_plant")==null and game.catalog.get_plant(&"electric_plant")==null,"all eight actual plant definitions covered; absent Water/Electric not invented")
	for index in game.catalog.plants.size():
		var data: PlantData=game.catalog.plants[index]
		var plot: FarmPlot=plots[index]
		check(data.validation_errors().is_empty(),"valid existing PlantData "+String(data.plant_id))
		game.inventory.add_item(data.seed_item,1)
		check(game.inventory.select_seed(data.seed_item.id),"existing seed selection accepts "+String(data.seed_item.id))
		var before: int=game.inventory.get_item_amount(data.seed_item.id)
		yields[data.plant_id]=game.inventory.get_item_amount(data.harvest_item.id)
		await near_plot(plot)
		key(KEY_E)
		check(plot.state==FarmPlot.State.PLANTED and plot.plant_data==data and game.inventory.get_item_amount(data.seed_item.id)==before-1,"actual E plants correct data and consumes one seed: "+String(data.plant_id))
		check(plot.plant_visual.seed_marker.visible and not plot.plant_visual.model_root.visible and not plot.plant_visual.produce.visible,"stage zero remains a tiny seed marker")
		sources[data.visual_scene.resource_path]=true
	check(sources.size()==8,"eight different visual scene resources are actually configured")
	await farm_camera()
	await capture("farm_stage_0")
	var records: Array=[]
	for stage in [1,2,3]:
		for index in game.catalog.plants.size():
			var plot: FarmPlot=plots[index]
			plot.plant_visual.set_stage(stage)
			plot.status_label.text=plot.plant_data.display_name+"\nDEBUG "+plot.plant_data.growth_stages[stage]
		await frames(3)
		for index in game.catalog.plants.size():
			var plot: FarmPlot=plots[index]
			var visual:=plot.plant_visual
			var bounds:=model_bounds(visual)
			check(visual.model_root.get_child_count()==1 and visual.model_root.visible and not visual.seed_marker.visible and not visual.produce.visible,"one grounded native model replaces seed/old produce marker at stage%d for %s" % [stage,plot.plant_data.plant_id])
			check(absf(bounds.position.y)<0.001 and maxf(bounds.size.x,bounds.size.z)<=1.102 and bounds.size.y<=0.861,"bounded scale/orientation/contact at stage%d for %s" % [stage,plot.plant_data.plant_id])
			check(visual.find_children("*","CollisionObject3D",true,false).is_empty(),"plant visuals add no physics colliders")
			records.append({"plant":String(plot.plant_data.plant_id),"stage":stage,"bounds_position":[bounds.position.x,bounds.position.y,bounds.position.z],"bounds_size":[bounds.size.x,bounds.size.y,bounds.size.z],"mesh_parts":visual.model_root.find_children("*","MeshInstance3D",true,false).size()})
		await capture("farm_stage_"+str(stage))
	# Inspect each mature source from a closer actual shoulder camera as well.
	for index in game.catalog.plants.size():
		var plot: FarmPlot=plots[index]
		await place_player(plot.position+Vector3(0,0.03,2.1))
		player.camera_rig.rotation.y=0
		player.camera_rig.pitch_pivot.rotation.x=-0.32
		player.camera_rig.update_pose(1)
		await frames(10)
		await capture("plant_"+String(plot.plant_data.plant_id))
	# Clock-driven real growth restores actual Ready status after visual-stage fixtures.
	game.clock.advance_game_minutes(60)
	await frames(3)
	for index in game.catalog.plants.size():
		var plot: FarmPlot=plots[index]
		check(plot.state==FarmPlot.State.READY and plot.growth_stage==3 and plot.growth_progress==1 and plot.status_label.text.contains("Ready"),"real clock reaches ready without altering growth/yield: "+String(plot.plant_data.plant_id))
	await farm_camera()
	await capture("farm_ready_actual")
	# Ready visual must remain intact when the existing atomic inventory add fails.
	var first: FarmPlot=plots[0]
	var retained:=first.plant_visual
	var capacity: int=game.inventory.capacity
	game.inventory.capacity=game.inventory.get_slots().size()
	await near_plot(first)
	key(KEY_E)
	check(first.state==FarmPlot.State.READY and first.plant_visual==retained,"full inventory preserves ready plant and visual atomically")
	game.inventory.capacity=capacity
	for index in game.catalog.plants.size():
		var plot: FarmPlot=plots[index]
		var data:=plot.plant_data
		await near_plot(plot)
		key(KEY_E)
		await frames(2)
		check(plot.state==FarmPlot.State.EMPTY and plot.plant_visual==null and game.inventory.get_item_amount(data.harvest_item.id)==int(yields[data.plant_id])+data.harvest_amount,"actual E harvest yields existing item/count and removes model: "+String(data.plant_id))
	check(game.inventory.has_item(&"wooden_bat") and game.inventory.has_item(&"basic_rifle"),"farming preserves owned weapons")
	# Future art can select a separate stage scene using the existing data array.
	var custom:=game.catalog.plants[0].duplicate() as PlantData
	custom.stage_visuals=[null,game.catalog.plants[4].visual_scene,null,null]
	var future:=load("res://scenes/farming/Plant.tscn").instantiate() as PlantVisual
	game.add_child(future)
	future.configure(custom)
	future.set_stage(1)
	await frames(2)
	check(custom.validation_errors().is_empty() and future.model_root.get_child(0).scene_file_path==game.catalog.plants[4].visual_scene.resource_path,"future stage art changes through PlantData without FarmPlot code")
	future.queue_free()
	var file:=FileAccess.open("user://gameplay_plant_geometry.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(records,"  "))
	print("GAMEPLAY_PLANTS_RESULT failures=",failures)
	quit(1 if failures else 0)
