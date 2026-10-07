extends "res://tests/phase_3_integration_test.gd"

func run() -> void:
	for variant in ["basic_impact","fire_impact","ice_impact","poison_impact","fire_plant","ice_plant","poison_plant"]:
		var scene := load("res://scenes/effects/elemental/%s.tscn"%variant) as PackedScene
		var first := scene.instantiate() as GPUParticles3D
		var second := scene.instantiate() as GPUParticles3D
		root.add_child(first)
		root.add_child(second)
		check(first.draw_pass_1 == second.draw_pass_1 and first.process_material == second.process_material, variant+" reuses immutable mesh/motion resources")
		# Compare the serialized resources with the original parameter builder.
		var original := scene.instantiate() as GPUParticles3D
		original.process_material = null
		original.draw_pass_1 = null
		root.add_child(original)
		var left := first.process_material as ParticleProcessMaterial
		var right := original.process_material as ParticleProcessMaterial
		var equal := true
		for property in ["emission_shape","emission_sphere_radius","direction","spread","initial_velocity_min","initial_velocity_max","gravity","angular_velocity_min","angular_velocity_max"]:
			equal = equal and left.get(property) == right.get(property)
		equal = equal and left.color_ramp.gradient.offsets == right.color_ramp.gradient.offsets and left.color_ramp.gradient.colors == right.color_ramp.gradient.colors
		check(equal and first.draw_pass_1.get_aabb() == original.draw_pass_1.get_aabb(), variant+" retains particle geometry, motion and fade")
		var emitting_before := second.emitting
		first.amount_ratio = 0.4
		first.emitting = not emitting_before
		check(second.amount_ratio == 1.0 and second.emitting == emitting_before, variant+" keeps emission state per instance")
		for node in [first,second,original]: node.queue_free()
	await frames(3)
	for kind in ["Normal","Runner","Tank"]:
		var scene := load("res://scenes/enemies/%sZombie.tscn"%kind) as PackedScene
		var enemy := scene.instantiate() as NormalZombie
		var source := enemy.data.visual_scene.instantiate()
		var animations := source.find_child("AnimationPlayer",true,false) as AnimationPlayer
		var modes := {}
		for clip in animations.get_animation_list(): modes[clip] = animations.get_animation(clip).loop_mode
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		root.add_child(enemy)
		var preserved := true
		var shared := true
		for clip in animations.get_animation_list():
			preserved = preserved and animations.get_animation(clip).loop_mode == modes[clip]
			if clip not in [enemy.data.idle_animation,enemy.data.walk_animation,enemy.data.attack_animation,enemy.data.death_animation]:
				shared = shared and animations.get_animation(clip) == enemy.animation_player.get_animation(clip)
		check(preserved and shared,kind+" preserves imported clips and shares untouched animations")
		check(enemy.animation_player.get_animation(enemy.data.walk_animation) != animations.get_animation(enemy.data.walk_animation) and enemy.animation_player.get_animation(enemy.data.walk_animation).loop_mode == Animation.LOOP_LINEAR,kind+" edits only its private used clips")
		enemy.queue_free()
		source.free()
	await frames(4)
	print("PERFORMANCE_RESOURCES_RESULT failures=",failures)
	quit(1 if failures else 0)
