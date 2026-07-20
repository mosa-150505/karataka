extends Button

@export var menu_scene: PackedScene

func _on_return_pressed() -> void:
	SceneManager.go_to_scene("res://scenes/menu.tscn")
