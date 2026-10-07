extends "res://tests/phase_5_weapon_test.gd"

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(15)
	game.clock.set_process(false)
	game.debug_controls.set_active(false)
	game.waves.enabled = false
	game.progression.unlock_all()
	var plots := game.get_node("MainWorld/FarmArea").get_children()
	var ids := ["fire_pepper", "ice_plant", "poison_plant"]
	var particles: Array[GPUParticles3D] = []
	for index in plots.size():
		var data: PlantData = load("res://resources/plants/%s.tres" % ids[index % 3])
		game.inventory.add_item(data.seed_item, 1)
		game.inventory.select_seed(data.seed_item.id)
		plots[index].interact(game.player)
		var particle: GPUParticles3D = plots[index].plant_visual.ambient_particles
		particles.append(particle)
		check(particle != null and not particle.emitting, "seed emitter off %d" % index)
	for advance in [15,21,18]:
		game.clock.advance_game_minutes(advance)
		for index in plots.size():
			var visual: PlantVisual = plots[index].plant_visual
			var particle := particles[index]
			check(visual.ambient_particles == particle and particle.emitting == (visual.stage == visual.data.growth_stages.size()-1), "growth reuses emitter with stage emission %d/%d" % [index,visual.stage])
			check(particle.amount == 12 and particle.scale.is_equal_approx(Vector3.ONE * visual.data.stage_scales[visual.stage]), "bounded count and growth scale")
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	for phase in ["day", "night"]:
		if phase == "night": game.clock.skip_to_night()
		for index in 3:
			var anchor: Vector3 = plots[index].plant_visual.global_position
			camera.position = anchor + Vector3(0,1.4,2.2)
			camera.look_at(anchor + Vector3.UP * 0.55)
			await frames(140)
			await capture(ids[index] + "_" + phase)
	for element in ["basic", "fire", "ice", "poison"]:
		var effect: GPUParticles3D = load("res://scenes/effects/elemental/%s_impact.tscn" % element).instantiate()
		game.add_child(effect)
		effect.global_position = plots[2].plant_visual.global_position + Vector3.UP
		await frames(8)
		await capture(element + "_impact")
		await frames(100)
		check(not is_instance_valid(effect), element + " impact expires")
	for plot in plots:
		plot.interact(game.player)
	await frames(3)
	for particle in particles:
		check(not is_instance_valid(particle), "harvest frees owned emitter")
	var basic: PlantData = load("res://resources/plants/lead.tres")
	check(basic.ambient_vfx == null, "basic crop has no elemental emitter")
	game.queue_free()
	await frames(3)
	print("ELEMENTAL VFX failures: ", failures)
	quit(0 if failures == 0 else 1)
