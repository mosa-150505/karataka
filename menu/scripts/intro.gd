extends Control

var loading_screen_path: String = "res://scenes/menu.tscn"

func _ready():
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	get_tree().change_scene_to_file(loading_screen_path)
