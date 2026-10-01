extends SceneTree
## Opens every original GLB in Godot; previews are evidence, never source replacements.

var output := ""
var rows: Array = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
	if output.is_empty(): quit(1); return
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(360, 320)
	var stage := Node3D.new()
	root.add_child(stage)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("aebbb5")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_energy = 0.8
	stage.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -40, 0)
	stage.add_child(sun)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.position = Vector3(4.5, 3.7, 5.8)
	camera.look_at(Vector3(0, 1.2, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	camera.current = true
	var packs := DirAccess.get_directories_at("res://Asset")
	packs.sort()
	for pack in packs:
		var files := DirAccess.get_files_at("res://Asset/" + pack)
		files.sort()
		for filename in files:
			if not filename.ends_with(".glb"): continue
			var path := "res://Asset/" + pack + "/" + filename
			var model := (load(path) as PackedScene).instantiate() as Node3D
			stage.add_child(model)
			var bounds := GamePresentation.model_bounds(model)
			var row := {"path":path,"size":[bounds.size.x,bounds.size.y,bounds.size.z],"meshes":model.find_children("*","MeshInstance3D",true,false).size(),"colliders":model.find_children("*","CollisionShape3D",true,false).size(),"animations":model.find_children("*","AnimationPlayer",true,false).size()}
			var factor := 3.2 / maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
			model.scale *= factor
			model.position -= Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z) * factor
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var preview := "%03d.png" % rows.size()
			root.get_texture().get_image().save_png(output.path_join(preview))
			row["preview"] = preview
			rows.append(row)
			model.free()
	var file := FileAccess.open(output.path_join("godot_inventory.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(rows,"  "))
	print("ENVIRONMENT_AUDIT_RESULT opened=",rows.size()," failures=0")
	quit()
