class_name UiItemSlot
extends Button
## Reused cells; refresh changes art/count, never recreates the inventory grid.

var picture: TextureRect
var badge: TextureRect
var quantity: Label
var selection_mark: TextureRect

func _init() -> void:
	custom_minimum_size = Vector2(82, 78)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	picture = PresentationStyle.icon(self, null, 0)
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	picture.offset_left = 7
	picture.offset_right = -7
	picture.offset_top = 4
	picture.offset_bottom = -15
	badge = PresentationStyle.icon(self, null, 0)
	badge.position = Vector2(5, 5)
	badge.size = Vector2(20, 20)
	quantity = PresentationStyle.label(self, "", 18)
	quantity.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	quantity.offset_left = -48
	quantity.offset_right = -7
	quantity.offset_top = -26
	quantity.offset_bottom = -4
	quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity.add_theme_color_override("font_shadow_color", Color.BLACK)
	quantity.add_theme_color_override("font_outline_color", Color(0.01, 0.03, 0.02, 0.9))
	quantity.add_theme_constant_override("outline_size", 2)
	quantity.add_theme_constant_override("shadow_offset_y", 1)
	selection_mark = PresentationStyle.icon(self, UiIcons.get_icon("selected"), 16)
	selection_mark.position = Vector2(5, 2)
	selection_mark.size = Vector2(16, 16)

func display(item: ItemData, amount: int = 0, selected: bool = false, plant: PlantData = null) -> void:
	picture.texture = UiIcons.item_icon(item)
	badge.texture = UiIcons.item_icon(plant.harvest_item) if plant != null else null
	# Seed packets already carry their harvest illustration; no competing badge.
	badge.visible = false
	selection_mark.visible = selected
	quantity.text = str(amount) if item != null else ""
	disabled = item == null
	tooltip_text = item.display_name if item != null else "Empty slot"
	var border := PresentationStyle.SAGE if item != null and item.item_type == ItemData.ItemType.SEED else PresentationStyle.GOLD
	add_theme_stylebox_override("normal", PresentationStyle.flat(Color("344b33") if selected else Color(0.13, 0.19, 0.145, 0.7), border if selected else Color(0.4, 0.47, 0.35, 0.3), 2 if selected else 1))
	add_theme_stylebox_override("hover", PresentationStyle.flat(Color("42543b"), border if selected else PresentationStyle.PAPER, 2))
	add_theme_stylebox_override("pressed", PresentationStyle.flat(Color("202e22"), border, 2))
	add_theme_stylebox_override("disabled", PresentationStyle.flat(Color(0.1, 0.15, 0.115, 0.3), Color(0.35, 0.42, 0.34, 0.18), 1))
