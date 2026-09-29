extends SceneTree

var failures: int = 0
var interactions: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1


func frames(count: int) -> void:
	for _index in count:
		await physics_frame


func run() -> void:
	var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
	root.add_child(game)
	await frames(5)
	var player := game.get_node("Player") as PlayerController
	var interactor := player.get_node("Interactor") as PlayerInteractor
	var station := game.get_node("TestInteractable") as Interactable
	station.interaction_requested.connect(func(_actor: Node3D) -> void: interactions += 1)
	check(interactor.target == null, "no prompt outside interaction range")
	player.position = Vector3(0, 0.1, 1.2)
	await frames(10)
	check(interactor.target == station, "nearby interactable is selected")
	var press := InputEventAction.new()
	press.action = "interact"
	press.pressed = true
	root.push_input(press)
	await process_frame
	check(interactions == 1, "interact action invokes object once")
	station.enabled = false
	await frames(3)
	check(interactor.target == null, "disabled object clears prompt")
	station.enabled = true
	var wall := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2, 2, 0.2)
	collider.shape = shape
	wall.add_child(collider)
	game.add_child(wall)
	wall.position = Vector3(0, 1, 0)
	await frames(5)
	check(interactor.target == null, "wall blocks interaction line of sight")
	wall.queue_free()
	await frames(5)
	check(interactor.target == station, "prompt returns after obstruction is removed")
	station.queue_free()
	await frames(5)
	interactor.try_interact()
	check(not is_instance_valid(interactor.target), "removed target is safely cleared")
	print("STAGE_2_INTERACTION_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
