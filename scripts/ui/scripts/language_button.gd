extends Button

## A attacher a chaque bouton de langue (FR / EN / MG).
## Regler "locale_code" dans l'Inspecteur pour chaque bouton.

@export var locale_code: String = "fr"

func _ready() -> void:
	pressed.connect(_on_pressed)
	_refresh_pressed_state()
	LocaleManager.locale_changed.connect(_on_locale_changed)

func _on_pressed() -> void:
	LocaleManager.set_language(locale_code)

func _on_locale_changed(_new_locale: String) -> void:
	_refresh_pressed_state()

func _refresh_pressed_state() -> void:
	button_pressed = LocaleManager.get_language() == locale_code
