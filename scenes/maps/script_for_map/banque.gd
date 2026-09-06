extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_mouse_entered():
	sprite.modulate = Color(1.3, 1.3, 1.3)

func _on_mouse_exited():
	sprite.modulate = Color.WHITE

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_click()
		SceneManager.go_to_scene_with_loading("res://scenes/maps/main_scene_bank.tscn")
