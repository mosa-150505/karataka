extends Node

var scene_stack: Array[Node] = []
var current_scene: Node = null

func go_to_scene(scene_path: String) -> void:
	var new_scene: Node = load(scene_path).instantiate()
	
	if current_scene:
		current_scene.visible = false
		current_scene.process_mode = Node.PROCESS_MODE_DISABLED
		scene_stack.append(current_scene)
		get_tree().root.remove_child.call_deferred(current_scene)
	
	get_tree().root.add_child(new_scene)
	current_scene = new_scene

func go_back() -> void:
	if scene_stack.is_empty():
		return
	
	current_scene.queue_free()
	
	var previous_scene: Node = scene_stack.pop_back()
	previous_scene.visible = true
	previous_scene.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().root.add_child(previous_scene)
	current_scene = previous_scene
