extends Area2D

var locked_color := Color(0.5, 0.5, 0.5)
var hover_color := Color(0.7, 0.7, 0.7)


func _ready() -> void:
	$Sprite2D.modulate = locked_color
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	$Sprite2D.modulate = hover_color


func _on_mouse_exited() -> void:
	$Sprite2D.modulate = locked_color
