extends Button

func _on_play_pressed() -> void:
	SceneManager.go_to_scene_with_loading("res://scenes/maps/map.tscn")
