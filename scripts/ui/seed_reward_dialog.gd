class_name SeedRewardDialog
extends CanvasLayer
## One choice per earned morning. Full bags defer delivery, never the receipt.

const TITLES := ["Fire", "Ice", "Poison"]
const UNLOCK_DAYS := [3, 5, 7]
const COLOURS := [Color("eea078"), Color("8ecbd4"), Color("bad77c")]
const DESCRIPTIONS := ["Grow Fire Pepper\nCraft burning ammunition", "Grow Ice Plant\nCraft slowing ammunition", "Grow Poison Plant\nCraft poison ammunition"]

var game: Node3D
var is_open := false
var reward_day := 0
var selected_seed: StringName = &""
var screen: Control
var panel: PanelContainer
var context: Label
var supply_label: Label
var delivery_hint: Label
var confirm_button: Button
var cards: Array[Button] = []
var badges: Array[Label] = []
var _previous_pause := false
var _previous_interactor := true

func bind(root_game: Node3D) -> void:
	game = root_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 28
	screen = PresentationStyle.screen(self)
	screen.name = "SeedRewardScreen"
	var margin := MarginContainer.new()
	screen.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]: margin.add_theme_constant_override("margin_" + side, 24)
	var center := CenterContainer.new()
	margin.add_child(center)
	panel = PanelContainer.new()
	panel.custom_minimum_size.x = 820
	center.add_child(panel)
	var rows := PresentationStyle.box(panel, true, 16)
	context = PresentationStyle.eyebrow(rows, "MORNING SUPPLY")
	PresentationStyle.label(rows, "Choose your seeds", 32)
	supply_label = PresentationStyle.label(rows, "", 18)
	supply_label.modulate = PresentationStyle.MUTED
	rows.add_child(HSeparator.new())
	var options := PresentationStyle.box(rows, false, 14)
	for index in ProgressionManager.SPECIAL_SEED_IDS.size():
		var id := ProgressionManager.SPECIAL_SEED_IDS[index]
		var card := PresentationStyle.button(options, "", _select.bind(id))
		card.name = TITLES[index] + "Seed"
		card.custom_minimum_size = Vector2(220, 232)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var content := PresentationStyle.box(card, true, 10)
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content.offset_left = 16
		content.offset_right = -16
		content.offset_top = 18
		content.offset_bottom = -18
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		var icon := PresentationStyle.icon(content, game.catalog.get_item(id).icon, 76)
		icon.modulate = COLOURS[index]
		var title := PresentationStyle.label(content, TITLES[index] + " Seeds", 23)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var description := PresentationStyle.label(content, DESCRIPTIONS[index], 14)
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.modulate = PresentationStyle.MUTED
		var badge := PresentationStyle.label(content, "", 14)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badges.append(badge)
		# The entire card is one focusable target, including its icon/text.
		for control: Control in card.find_children("*", "Control", true, false): control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cards.append(card)
	delivery_hint = PresentationStyle.label(rows, "", 14)
	delivery_hint.modulate = PresentationStyle.MUTED
	confirm_button = PresentationStyle.button(rows, "Receive seeds", confirm_selection, "gift")
	confirm_button.theme_type_variation = "PrimaryButton"
	# The browser needs the pressed gesture to restore pointer lock after claiming.
	confirm_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	game.player.health.died.connect(_close)
	game.waves.completed.connect(_close)
	screen.hide()

func _eligible() -> bool:
	return game != null and game.preparation_complete and not game.player.health.is_dead and not game.presentation.ending_started and game.clock.current_day <= 10 and game.waves.state not in [NightWaveManager.State.GAME_OVER, NightWaveManager.State.GAME_COMPLETED]

func _process(_delta: float) -> void:
	if is_open:
		if not _eligible() or not game.progression.daily_seed_choices.has(reward_day): _close()
		return
	if not _eligible() or game.progression.next_seed_reward_day() == 0: return
	if game.rest.is_resting or game.inventory_ui.is_open or game.crafting_ui.is_open or game.pause_menu.is_open or game.skip_night.is_open: return
	# A morning choice takes priority over the Web click-to-resume overlay.
	if game.pause_menu._web_capture_waiting: game.pause_menu._finish_web_capture_wait()
	if not get_tree().paused: request_open()

func request_open() -> bool:
	if is_open or not _eligible() or get_tree().paused or game.rest.is_resting: return false
	if game.inventory_ui.is_open or game.crafting_ui.is_open or game.pause_menu.is_open or game.skip_night.is_open: return false
	reward_day = game.progression.next_seed_reward_day()
	if reward_day == 0: return false
	_previous_pause = get_tree().paused
	_previous_interactor = game.player.interactor.enabled
	is_open = true
	game.player.interactor.enabled = false
	game.player.camera_rig.set_menu_open(true)
	get_tree().paused = true
	selected_seed = game.progression.seed_reward_options(reward_day)[0]
	_refresh()
	screen.show()
	PresentationStyle.appear(panel)
	cards[ProgressionManager.SPECIAL_SEED_IDS.find(selected_seed)].grab_focus()
	return true

func _select(id: StringName) -> void:
	if not is_open or id not in game.progression.seed_reward_options(reward_day): return
	selected_seed = id
	_refresh()

func _refresh() -> void:
	var amount: int = game.progression.seed_reward_amount(reward_day)
	var available: Array[StringName] = game.progression.seed_reward_options(reward_day)
	context.text = "DAY %d / MORNING SUPPLY" % reward_day
	supply_label.text = "Choose one type · Receive %d seeds, matching today's basic seed supply." % amount
	for index in cards.size():
		var id := ProgressionManager.SPECIAL_SEED_IDS[index]
		var unlocked := id in available
		var selected := unlocked and id == selected_seed
		cards[index].disabled = not unlocked
		cards[index].focus_mode = Control.FOCUS_ALL if unlocked else Control.FOCUS_NONE
		cards[index].tooltip_text = game.catalog.get_item(id).description if unlocked else "Unlocks on Day %d" % UNLOCK_DAYS[index]
		cards[index].add_theme_stylebox_override("normal", PresentationStyle.flat(Color("26352b") if selected else Color("18271f"), COLOURS[index] if selected else Color("465044"), 2 if selected else 1))
		cards[index].add_theme_stylebox_override("disabled", PresentationStyle.flat(Color("18211c"), Color("394238"), 1))
		badges[index].text = "SELECTED · ×%d" % amount if selected else "Available · ×%d" % amount if unlocked else "Lock · Day %d" % UNLOCK_DAYS[index]
		badges[index].modulate = COLOURS[index] if unlocked else PresentationStyle.MUTED
		for child: Control in cards[index].get_child(0).get_children(): child.modulate.a = 1.0 if unlocked else 0.48
		badges[index].modulate.a = 1.0
	delivery_hint.text = "One reward each morning. If your bag is full, seeds are saved until space opens."
	confirm_button.text = "Receive %s Seeds ×%d" % [TITLES[ProgressionManager.SPECIAL_SEED_IDS.find(selected_seed)], amount]
	confirm_button.disabled = selected_seed not in available
	var enabled_cards: Array[Button] = []
	for card in cards:
		if not card.disabled: enabled_cards.append(card)
	for index in enabled_cards.size():
		var card := enabled_cards[index]
		card.focus_neighbor_left = card.get_path_to(enabled_cards[posmod(index - 1, enabled_cards.size())])
		card.focus_neighbor_right = card.get_path_to(enabled_cards[(index + 1) % enabled_cards.size()])
		card.focus_neighbor_bottom = card.get_path_to(confirm_button)
	confirm_button.focus_neighbor_top = confirm_button.get_path_to(cards[ProgressionManager.SPECIAL_SEED_IDS.find(selected_seed)])

func confirm_selection() -> void:
	if not is_open or not _eligible(): return
	var amount: int = game.progression.seed_reward_amount(reward_day)
	var item: ItemData = game.catalog.get_item(selected_seed)
	if not game.progression.choose_daily_seed(reward_day, selected_seed): return
	var queued: bool = game.progression.pending_rewards.has(selected_seed)
	_close()
	game.player.camera_rig.capture_mouse_from_gesture()
	game.audio.cue("click")
	game.hud.show_message("%s ×%d%s" % [item.display_name, amount, " · Saved until bag space opens" if queued else " · Morning supply received"])

func _close() -> void:
	if not is_open: return
	is_open = false
	screen.hide()
	get_viewport().gui_release_focus()
	get_tree().paused = _previous_pause
	game.player.interactor.enabled = _previous_interactor and not game.player.health.is_dead
	game.player.camera_rig.set_menu_open(false)

func _input(event: InputEvent) -> void:
	if not is_open: return
	if event is InputEventKey:
		for action in ["ui_accept", "ui_up", "ui_down", "ui_left", "ui_right", "ui_focus_next", "ui_focus_prev"]:
			if event.is_action(action): return
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	if is_open: get_tree().paused = _previous_pause
