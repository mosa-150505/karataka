class_name Inventory
extends RefCounted
# res://scripts/Inventory.gd

var slots: Array[InventorySlot] = []

func _init(size: int) -> void:
	for i in range(size):
		slots.append(InventorySlot.new())

func add_item(item: ItemData, quantity: int = 1) -> bool:
	if quantity <= 0 or item == null:
		return false

	# Empiler sur un objet identique existant
	for slot in slots:
		if slot.item != null and slot.item.item_name == item.item_name:
			slot.quantity += quantity
			return true

	# Placer dans un emplacement vide
	for slot in slots:
		if slot.item == null:
			slot.item = item
			slot.quantity = quantity
			return true
	return false
