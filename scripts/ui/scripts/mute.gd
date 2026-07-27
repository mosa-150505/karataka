extends Button

@onready var icon_unmuted = preload("res://assets/ui/assets/options_panel/unmute-removebg-preview.png")
@onready var icon_muted = preload("res://assets/ui/assets/options_panel/mute.png")

var is_muted = false

func _ready() -> void:
	pressed.connect(_on_pressed)
	icon = icon_unmuted

func _on_pressed() -> void:
	is_muted = !is_muted
	icon = icon_muted if is_muted else icon_unmuted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)
