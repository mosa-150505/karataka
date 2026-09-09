extends Button

func _on_play_pressed() -> void:
	SceneManager.go_to_scene("res://scenes/maps/map.tscn")
