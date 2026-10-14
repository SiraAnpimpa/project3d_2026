extends PanelContainer
## Compact combat-only status; selection follows the boss the player last shot.

var game: Node3D
var boss: NormalZombie
var title: Label
var hp: ProgressBar
var amount: Label
var phase: Label

func bind(root_game: Node3D) -> void:
	game = root_game
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	offset_left = -180
	offset_right = 180
	offset_top = 24
	offset_bottom = 86
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := PresentationStyle.flat(Color(0.045, 0.07, 0.055, 0.68))
	style.set_content_margin_all(10)
	add_theme_stylebox_override("panel", style)
	var rows := PresentationStyle.box(self, true, 4)
	var header := PresentationStyle.box(rows, false, 10)
	title = PresentationStyle.label(header, "Big Arm Boss", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	amount = PresentationStyle.label(header, "", 14)
	amount.modulate = PresentationStyle.RED
	hp = ProgressBar.new()
	hp.custom_minimum_size.y = 6
	hp.show_percentage = false
	hp.add_theme_stylebox_override("fill", PresentationStyle.flat(PresentationStyle.RED))
	rows.add_child(hp)
	phase = PresentationStyle.label(rows, "", 12)
	phase.modulate = PresentationStyle.RED
	game.waves.changed.connect(_select)
	game.weapons.hit_confirmed.connect(_select)
	game.player.camera_rig.controls_changed.connect(func(_enabled: bool) -> void: _refresh())
	game.player.health.died.connect(_refresh)
	_select()

func _select() -> void:
	var chosen: NormalZombie
	for enemy: NormalZombie in game.waves.alive.values():
		if enemy.data.zombie_id != &"boss_zombie" or enemy.health.is_dead: continue
		if chosen == null or game.weapons.last_hit == enemy: chosen = enemy
	if chosen != boss:
		if is_instance_valid(boss):
			boss.health.changed.disconnect(_health_changed)
			boss.charge_phase_changed.disconnect(_phase_changed)
			boss.charge_warning_changed.disconnect(_warning_changed)
		boss = chosen
		if is_instance_valid(boss):
			boss.health.changed.connect(_health_changed)
			boss.charge_phase_changed.connect(_phase_changed)
			boss.charge_warning_changed.connect(_warning_changed)
	_refresh()

func _health_changed(_current: float, _maximum: float) -> void:
	_refresh()

func _phase_changed(_value: int) -> void:
	_refresh()

func _warning_changed(_seconds: float) -> void:
	_refresh()

func _refresh() -> void:
	visible = is_instance_valid(boss) and not boss.health.is_dead and game.player.camera_rig.can_control() and not game.player.health.is_dead
	if not is_instance_valid(boss): return
	hp.max_value = boss.health.max_hp
	hp.value = boss.health.current_hp
	amount.text = "%d / %d" % [ceili(boss.health.current_hp), int(boss.health.max_hp)]
	var count := 0
	for enemy: NormalZombie in game.waves.alive.values():
		if enemy.data.zombie_id == &"boss_zombie" and not enemy.health.is_dead: count += 1
	title.text = "Big Arm Boss" + (" · ×%d" % count if count > 1 else "")
	phase.text = "CHARGE" if boss.charge_phase in [1, 2] else ""
	if boss.charge_phase in [4, 5]: phase.text = "SLAM"
	phase.visible = not phase.text.is_empty()
