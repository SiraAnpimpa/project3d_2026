extends SceneTree

var failures: int = 0
var deaths: int = 0


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
	await frames(30)
	var player := game.get_node("Player") as PlayerController
	var health := player.health
	health.died.connect(func() -> void: deaths += 1)
	health.take_damage(25.0)
	check(is_equal_approx(health.current_hp, 75.0), "damage subtracts HP")
	health.heal(1000.0)
	check(is_equal_approx(health.current_hp, health.max_hp), "healing clamps to max HP")
	health.take_damage(-10.0)
	check(is_equal_approx(health.current_hp, health.max_hp), "negative damage is ignored")
	health.take_damage(1000.0)
	health.die()
	health.take_damage(10.0)
	health.heal(10.0)
	check(health.current_hp == 0.0 and health.is_dead and deaths == 1, "death clamps HP and emits once")
	await frames(30)
	var start := player.position
	Input.action_press("move_left")
	await frames(30)
	Input.action_release("move_left")
	check(player.position.distance_to(start) < 0.01, "dead player cannot move")
	health.reset()
	player.stamina.reset()
	Input.action_press("move_left")
	Input.action_press("sprint")
	await frames(60)
	Input.action_release("move_left")
	Input.action_release("sprint")
	check(player.stamina.current_stamina < 85.0, "sprint consumes stamina over real physics steps")
	var depleted := player.stamina.current_stamina
	await frames(30)
	check(is_equal_approx(depleted, player.stamina.current_stamina), "stamina waits before recovering")
	await frames(120)
	check(player.stamina.current_stamina > depleted, "stamina recovers while not sprinting")
	player.stamina.drain(1000.0)
	Input.action_press("move_right")
	Input.action_press("sprint")
	await frames(5)
	check(not player.is_sprinting and player.stamina.exhausted, "empty stamina prevents sprint")
	Input.action_release("move_right")
	Input.action_release("sprint")
	player.stamina.restore(1000.0)
	check(player.stamina.current_stamina == player.stamina.max_stamina and not player.stamina.exhausted, "restore clamps and clears exhaustion")
	var slow := StaminaComponent.new()
	var fast := StaminaComponent.new()
	root.add_child(slow)
	root.add_child(fast)
	for _i in 90:
		slow.tick(1.0 / 30.0, true)
	for _i in 360:
		fast.tick(1.0 / 120.0, true)
	check(absf(slow.current_stamina - fast.current_stamina) < 0.01, "stamina drain is consistent at 30 and 120 steps/sec")
	slow.queue_free()
	fast.queue_free()
	print("STAGE_3_STATS_RESULT failures=", failures)
	game.queue_free()
	await process_frame
	quit(failures)
