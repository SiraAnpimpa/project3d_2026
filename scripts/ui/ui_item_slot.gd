class_name UiItemSlot
extends Button
## Reused cells; refresh changes art/count, never recreates the inventory grid.

var picture: TextureRect
var badge: TextureRect
var quantity: Label

func _init() -> void:
	custom_minimum_size = Vector2(76, 72)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	picture = PresentationStyle.icon(self, null, 0)
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	picture.offset_left = 12
	picture.offset_right = -12
	picture.offset_top = 8
	picture.offset_bottom = -15
	badge = PresentationStyle.icon(self, null, 0)
	badge.position = Vector2(5, 5)
	badge.size = Vector2(20, 20)
	quantity = PresentationStyle.label(self, "", 17)
	quantity.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	quantity.offset_left = -48
	quantity.offset_right = -7
	quantity.offset_top = -26
	quantity.offset_bottom = -4
	quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity.add_theme_color_override("font_shadow_color", Color.BLACK)
	quantity.add_theme_constant_override("shadow_offset_y", 1)

func display(item: ItemData, amount: int = 0, selected: bool = false, plant: PlantData = null) -> void:
	picture.texture = UiIcons.item_icon(item)
	badge.texture = UiIcons.item_icon(plant.harvest_item) if plant != null else null
	badge.visible = plant != null
	quantity.text = str(amount) if item != null else ""
	disabled = item == null
	tooltip_text = item.display_name if item != null else "Empty slot"
	var border := PresentationStyle.SAGE if item != null and item.item_type == ItemData.ItemType.SEED else PresentationStyle.GOLD
	add_theme_stylebox_override("normal", PresentationStyle.flat(Color("2b382c") if selected else Color("242e28"), border if selected else Color("3c493c"), 2 if selected else 1))
	add_theme_stylebox_override("disabled", PresentationStyle.flat(Color("1b2520"), Color("303b32"), 1))
