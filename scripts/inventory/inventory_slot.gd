class_name InventorySlot
extends RefCounted

var item: ItemData
var quantity: int


func _init(definition: ItemData = null, amount: int = 0) -> void:
	item = definition
	quantity = amount
