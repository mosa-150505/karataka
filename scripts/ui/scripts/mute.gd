extends Button

## Bouton mute reutilisable : regle "target" sur "music" ou "sfx" dans
## l'Inspecteur pour choisir quel bus il controle.

@export_enum("music", "sfx") var target: String = "music"

@onready var icon_unmuted = preload("res://assets/ui/assets/options_panel/unmute-removebg-preview.png")
@onready var icon_muted = preload("res://assets/ui/assets/options_panel/mute.png")

func _ready() -> void:
	pressed.connect(_on_pressed)
	_refresh_icon()

func _on_pressed() -> void:
	var muted := not _is_muted()
	if target == "music":
		AudioManager.set_music_muted(muted)
	else:
		AudioManager.set_sfx_muted(muted)
	_refresh_icon()

func _is_muted() -> bool:
	return AudioManager.is_music_muted() if target == "music" else AudioManager.is_sfx_muted()

func _refresh_icon() -> void:
	icon = icon_muted if _is_muted() else icon_unmuted
