extends SceneTree
## Regenerate immutable particle subresources after editing their exported parameters.
## Run: godot --headless --path . --script res://tools/bake_elemental_particles.gd
func _initialize() -> void:
	var failures := 0
	for variant in ["basic_impact","fire_impact","ice_impact","poison_impact","fire_plant","ice_plant","poison_plant"]:
		var path := "res://scenes/effects/elemental/%s.tscn"%variant
		var node := load(path).instantiate() as GPUParticles3D
		node.draw_pass_1 = null
		node.process_material = null
		node._ready()
		var scene := PackedScene.new()
		var error := scene.pack(node)
		if error == OK: error = ResourceSaver.save(scene,path)
		if error != OK: failures += 1
		print("PARTICLE_BAKE ",variant," error=",error)
		node.free()
	quit(1 if failures else 0)
