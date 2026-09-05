extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	sprite.modulate = Color(1.3, 1.3, 1.3)

func _on_mouse_exited():
	sprite.modulate = Color.WHITE
