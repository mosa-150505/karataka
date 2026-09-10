# res://scripts/ItemData.gd
class_name ItemData
extends Resource

@export var item_name: String = "Item"
@export var category: String = "general"
@export var sell_price: int = 1
@export var max_stack_size: int = 99

# MODIFICATION ICI : On enlève le type strict Texture2D pour éviter le blocage
@export var icon: Resource 
