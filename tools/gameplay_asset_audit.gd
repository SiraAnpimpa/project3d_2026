extends "res://tests/phase_3_integration_test.gd"
## Actual imported source inspection before selecting crop/weapon visuals.

var paths: Array[String] = []

func collect(folder: String) -> void:
	for sub in DirAccess.get_directories_at(folder): collect(folder.path_join(sub))
	for file in DirAccess.get_files_at(folder):
		if file.get_extension().to_lower() == "glb": paths.append(folder.path_join(file))

func bounds_of(model: Node3D) -> AABB:
	var found := false
	var bounds := AABB()
	for part in model.find_children("*","MeshInstance3D",true,false):
		var local: AABB = (model.global_transform.affine_inverse()*part.global_transform)*part.get_aabb()
		bounds = bounds.merge(local) if found else local
		found = true
	return bounds

func run() -> void:
	root.size = Vector2i(800,600)
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color(0.12,0.16,0.18)
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color.WHITE
	settings.ambient_light_energy = 0.75
	environment.environment = settings
	world.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40,-25,0)
	sun.light_energy = 1.2
	world.add_child(sun)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.0
	camera.position = Vector3(4,3.2,5)
	camera.look_at(Vector3(0,1.3,0))
	camera.current = true
	var canvas := CanvasLayer.new()
	world.add_child(canvas)
	var label := Label.new()
	label.position = Vector2(15,15)
	label.add_theme_font_size_override("font_size",20)
	canvas.add_child(label)
	collect("res://Asset")
	paths.sort()
	var rows: Array = []
	var index := 0
	var extra_only := "--remaining-weapons" in OS.get_cmdline_user_args()
	for path in paths:
		var file := path.get_file().to_lower()
		var nature := "Stylized Nature" in path
		var weapon := "Ultimate Guns" in path or file.contains("bat") or file.contains("rifle") or file.contains("shotgun") or file.contains("pistol") or file.contains("smg") or file.contains("knife") or file.contains("axe") or file.contains("sword") or file.contains("spear") or file.contains("hammer") or file.contains("scythe") or file.contains("bow") or file.contains("dagger") or file.contains("claymore") or file.contains("wooden torch") or file.contains("wood log") or file.contains("paddle")
		var actor := "Characters " in path or file == "lis.glb" or file.contains("zombie") or file == "big arm.glb"
		var accent := file in ["mineral.glb","snowflake.glb"]
		if extra_only:
			if not (file.contains("shield") or file == "arrow.glb" or file == "flare gun.glb"): continue
			weapon = true
		if not (nature or weapon or actor or accent): continue
		var model := load(path).instantiate() as Node3D
		check(model != null,"actual model imported: "+path)
		if model == null: continue
		world.add_child(model)
		var raw := bounds_of(model)
		var factor := minf(2.6/maxf(raw.size.x,raw.size.z),2.8/maxf(raw.size.y,0.01))
		model.scale = Vector3.ONE*factor
		model.position = -Vector3(raw.get_center().x,raw.position.y,raw.get_center().z)*factor
		var skeleton := model.find_child("Skeleton3D",true,false) as Skeleton3D
		var animation := model.find_child("AnimationPlayer",true,false) as AnimationPlayer
		var clips := []
		if animation != null:
			for name in animation.get_animation_list():
				var clip := animation.get_animation(name)
				clips.append({"name":String(name),"seconds":clip.length,"tracks":clip.get_track_count()})
		var bones: Array = []
		if skeleton != null:
			for bone in skeleton.get_bone_count(): bones.append({"name":skeleton.get_bone_name(bone),"parent":skeleton.get_bone_parent(bone)})
		var materials := {}
		var triangles := 0
		for part in model.find_children("*","MeshInstance3D",true,false):
			for surface in part.mesh.get_surface_count():
				triangles += part.mesh.surface_get_array_len(surface)/3
				var mat: Material = part.get_active_material(surface)
				if mat != null: materials[str(mat.get_instance_id())] = {"name":mat.resource_name,"type":mat.get_class()}
		var shot := "%03d_%s" % [index,path.get_file().get_basename().validate_filename()]
		if extra_only: shot = "extra_"+shot
		label.text = path.get_file()+"\n"+path.get_base_dir().get_file()
		await frames(5)
		await capture(shot)
		rows.append({"path":path,"nature":nature,"weapon":weapon,"actor":actor,"accent":accent,"bounds_position":[raw.position.x,raw.position.y,raw.position.z],"bounds_size":[raw.size.x,raw.size.y,raw.size.z],"mesh_parts":model.find_children("*","MeshInstance3D",true,false).size(),"triangle_upper_bound":triangles,"materials":materials.values(),"bones":bones,"clips":clips,"collision_nodes":model.find_children("*","CollisionObject3D",true,false).size(),"image":shot+".png"})
		world.remove_child(model)
		model.queue_free()
		await frames(1)
		index += 1
	var out := FileAccess.open("user://gameplay_asset_audit_extra.json" if extra_only else "user://gameplay_asset_audit.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(rows,"  "))
	print("GAMEPLAY_ASSET_AUDIT_RESULT failures=",failures," inspected=",rows.size()," extra_only=",extra_only)
	quit(1 if failures else 0)
