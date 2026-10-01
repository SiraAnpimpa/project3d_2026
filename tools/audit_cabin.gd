extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1400,900)
	var scene := Node3D.new()
	root.add_child(scene)
	current_scene = scene
	var cabin := load("res://Asset/Cabin.glb").instantiate() as Node3D
	scene.add_child(cabin)
	var bounds := GamePresentation.model_bounds(cabin)
	print("CABIN_BOUNDS ",bounds)
	for node in cabin.find_children("*","",true,false):
		print("CABIN_NODE ",node.get_path()," ",node.get_class())
	var scale_factor := 8.0/maxf(bounds.size.x,bounds.size.z)
	cabin.scale = Vector3.ONE*scale_factor
	cabin.position = -Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)*scale_factor
	var sun := DirectionalLight3D.new()
	scene.add_child(sun)
	sun.rotation_degrees = Vector3(-55,-35,0)
	sun.shadow_enabled = true
	var sky := WorldEnvironment.new()
	sky.environment = Environment.new()
	sky.environment.background_mode = Environment.BG_COLOR
	sky.environment.background_color = Color("819faf")
	sky.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	sky.environment.ambient_light_energy = 0.7
	scene.add_child(sky)
	var cam := Camera3D.new()
	scene.add_child(cam)
	cam.current = true
	for view in [["front",Vector3(10,6,12)],["back",Vector3(-10,6,-12)],["door",Vector3(0,2,9)]]:
		cam.position = view[1]
		cam.look_at(Vector3(0,2,0))
		for i in 5: await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		var output: String = "user://captures/cabin_"+view[0]+".png"
		print("CABIN_CAPTURE ",output," error=",image.save_png(output))
	quit()
