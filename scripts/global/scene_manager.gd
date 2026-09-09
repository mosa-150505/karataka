extends Node

var scene_stack: Array[Node] = []
var current_scene: Node = null

## Chemin de la scene que l'ecran de chargement doit charger, une fois arrive dessus.
var pending_scene_path: String = ""

## Donnees generiques transmises a la prochaine scene (lues dans son _ready()).
## Ex: SceneManager.pending_scene_data = {"title_key": "UI_BUILDING_BANK"}
var pending_scene_data: Dictionary = {}

func go_to_scene(scene_path: String) -> void:
	var new_scene: Node = load(scene_path).instantiate()
	_swap_scene(new_scene)

## Affiche un ecran de chargement, charge target_scene_path en arriere-plan
## (progression reelle affichee sur une barre), puis bascule dessus une fois pret.
func go_to_scene_with_loading(target_scene_path: String, loading_scene_path: String = "res://scenes/ui/scenes/loading.tscn") -> void:
	pending_scene_path = target_scene_path
	go_to_scene(loading_scene_path)

## Appele par l'ecran de chargement une fois la ressource prete a etre affichee.
func finish_loading(loaded_resource: PackedScene) -> void:
	pending_scene_path = ""
	var new_scene: Node = loaded_resource.instantiate()
	_swap_scene(new_scene, false) # false : on ne garde pas l'ecran de chargement dans l'historique

func go_back() -> void:
	if scene_stack.is_empty():
		return

	current_scene.queue_free()

	var previous_scene: Node = scene_stack.pop_back()
	previous_scene.visible = true
	previous_scene.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().root.add_child(previous_scene)
	current_scene = previous_scene

## keep_current_in_stack = true : l'ancienne scene est mise en pause et gardee
## (recuperable via go_back). false : elle est simplement detruite
## (utile pour l'ecran de chargement, qui n'a pas de raison d'y revenir).
func _swap_scene(new_scene: Node, keep_current_in_stack: bool = true) -> void:
	if current_scene:
		if keep_current_in_stack:
			current_scene.visible = false
			current_scene.process_mode = Node.PROCESS_MODE_DISABLED
			scene_stack.append(current_scene)
			get_tree().root.remove_child.call_deferred(current_scene)
		else:
			current_scene.queue_free()

	get_tree().root.add_child(new_scene)
	current_scene = new_scene
