extends Node

## A placer comme ENFANT d'un Label ou d'un Button pour le traduire
## automatiquement via LocaleManager, sans toucher au script du parent.
## Regler "text_key" dans l'Inspecteur avec la cle du CSV (ex: UI_PLAY).

@export var text_key: String = ""

func _ready() -> void:
	_apply_text()
	LocaleManager.locale_changed.connect(_on_locale_changed)

func _on_locale_changed(_locale_code: String) -> void:
	_apply_text()

func _apply_text() -> void:
	var parent := get_parent()
	if parent and text_key != "":
		parent.set("text", LocaleManager.t(text_key))
