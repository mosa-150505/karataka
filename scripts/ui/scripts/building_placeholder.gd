extends Control

var _title_key: String = ""

func _ready() -> void:
	_title_key = SceneManager.pending_scene_data.get("title_key", "")
	_apply_text()
	LocaleManager.locale_changed.connect(_on_locale_changed)

func _on_locale_changed(_locale_code: String) -> void:
	_apply_text()

func _apply_text() -> void:
	if _title_key != "":
		$title.text = LocaleManager.t(_title_key)
