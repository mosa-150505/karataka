extends ScrollContainer

## Rend les barres de defilement invisibles sans desactiver le scroll
## (molette souris / glisser toujours fonctionnels).

func _ready() -> void:
	get_v_scroll_bar().modulate = Color(1, 1, 1, 0)
	get_h_scroll_bar().modulate = Color(1, 1, 1, 0)
