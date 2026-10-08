class_name ItemTooltip
extends PanelContainer
## A transient, input-transparent item card. Godot positions it at the hovered cell
## and keeps the tooltip window inside the viewport, including on Web.

func _init(item: ItemData, amount: int, plant: PlantData = null, weapon: WeaponData = null, planting: bool = false) -> void:
	theme = PresentationStyle.theme()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.x = 310
	var style := PresentationStyle.flat(Color("121f18"), PresentationStyle.GOLD, 1)
	style.set_content_margin_all(16)
	add_theme_stylebox_override("panel", style)
	var rows := PresentationStyle.box(self, true, 8)
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header := PresentationStyle.box(rows, false, 10)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	PresentationStyle.icon(header, UiIcons.item_icon(item), 54)
	var title := PresentationStyle.label(header, item.display_name, 22)
	title.custom_minimum_size.x = 220
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PresentationStyle.eyebrow(rows, UiIcons.category(item))
	PresentationStyle.label(rows, "×%d in bag" % amount, 16).modulate = PresentationStyle.MUTED
	rows.add_child(HSeparator.new())
	if plant != null:
		PresentationStyle.label(rows, "Growth  ·  %.0f game min" % plant.growth_minutes, 17)
		var harvest := PresentationStyle.box(rows, false, 8)
		harvest.mouse_filter = Control.MOUSE_FILTER_IGNORE
		PresentationStyle.icon(harvest, UiIcons.item_icon(plant.harvest_item), 26)
		PresentationStyle.label(harvest, "%s  ×%d" % [plant.harvest_item.display_name, plant.harvest_amount], 17)
		_copy(rows, "Plant on an empty plot.")
		_copy(rows, "Selected for planting" if planting else "Click to select for planting", PresentationStyle.SAGE)
	else:
		if weapon != null:
			PresentationStyle.label(rows, "Damage  ·  %.0f     Range  ·  %.1f m" % [weapon.damage, weapon.range_meters], 17)
			if not weapon.is_melee():
				PresentationStyle.label(rows, "Magazine  ·  %d     Reload  ·  %.1f s" % [weapon.magazine_size, weapon.reload_time], 17)
			_copy(rows, "Click weapon, then choose a loadout slot.", PresentationStyle.SAGE)
		_copy(rows, UiIcons.use_text(item))

func _copy(parent: Node, copy: String, color: Color = PresentationStyle.MUTED) -> void:
	var label := PresentationStyle.label(parent, copy, 16)
	label.custom_minimum_size.x = 290
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = color
