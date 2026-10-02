class_name AimCrosshair
extends Control

var rig: ThirdPersonCamera
var ray: CameraAimRay
var debug_label: Label
var player: PlayerController
var hit_time := 0.0


func flash_hit() -> void:
	hit_time = 0.16
	queue_redraw()


func _process(delta: float) -> void:
	if hit_time > 0:
		hit_time = maxf(0, hit_time - delta)
		queue_redraw()


func bind(target_player: PlayerController, aim_ray: CameraAimRay, label: Label) -> void:
	player = target_player
	rig = player.camera_rig
	ray = aim_ray
	debug_label = label
	rig.aim_changed.connect(func(_aiming: bool) -> void: refresh())
	rig.controls_changed.connect(func(_enabled: bool) -> void: refresh())
	ray.sample_updated.connect(refresh)
	refresh()


func refresh() -> void:
	visible = rig.can_control() and rig.is_combat_enabled()
	debug_label.visible = OS.is_debug_build() and ray.debug_visible()
	if debug_label.visible:
		var distance := ray.aim_origin.distance_to(ray.aim_point)
		debug_label.text = "AIM %s  /  %.1f m\nCamera forward: %.2f, %.2f, %.2f\nPlayer forward: %.2f, %.2f, %.2f" % [
			"HIT" if ray.has_hit else "CLEAR", distance,
			ray.aim_direction.x, ray.aim_direction.y, ray.aim_direction.z,
			player.visual.global_basis.z.x, player.visual.global_basis.z.y, player.visual.global_basis.z.z]
	queue_redraw()


func _draw() -> void:
	if rig == null:
		return
	var center := size * 0.5
	var tint := Color(1, 0.97, 0.85, 1.0 if rig.is_aiming else 0.32)
	if not rig.is_aiming:
		draw_circle(center, 2.0, tint)
	else:
		for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			draw_line(center + direction * 5, center + direction * 12, Color(0.05, 0.07, 0.06, 0.9), 4.0)
			draw_line(center + direction * 5, center + direction * 12, tint, 2.0)
		draw_circle(center, 1.5, tint)
	if hit_time > 0:
		for direction in [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
			draw_line(center + direction * 7, center + direction * 13, PresentationStyle.GOLD, 2)
