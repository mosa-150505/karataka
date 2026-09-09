extends Node

var scene_stack: Array[String] = []

## Chemin de la scene que l'ecran de chargement doit charger, une fois arrive dessus.
var pending_scene_path: String = ""

## Donnees generiques transmises a la prochaine scene (lues dans son _ready()).
var pending_scene_data: Dictionary = {}

func go_to_scene(scene_path: String) -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Methode native Godot : definit correctement la scene active dans le SceneTree
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		printerr("Erreur lors du chargement de la scene : ", scene_path, " (Code : ", error, ")")

func go_to_scene_with_loading(target_scene_path: String, loading_scene_path: String = "res://scenes/ui/scenes/loading.tscn") -> void:
	pending_scene_path = target_scene_path
	go_to_scene(loading_scene_path)

func finish_loading(loaded_resource: PackedScene) -> void:
	pending_scene_path = ""
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Bascule vers la ressource prechargee en la passant comme scene principale
	var error = get_tree().change_scene_to_packed(loaded_resource)
	if error != OK:
		printerr("Erreur lors du chargement de la ressource prechargee. Code : ", error)

func go_back() -> void:
	if scene_stack.is_empty():
		return

	var previous_scene_path: String = scene_stack.pop_back()
	go_to_scene(previous_scene_path)
