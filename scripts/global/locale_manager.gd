extends Node

## Autoload : charge les traductions depuis localization/ui.csv "a la main"
## (sans passer par le systeme d'import de Godot), gere la langue active
## et sa persistance dans user://settings.cfg

const CSV_PATH := "res://localization/ui.csv"
const CONFIG_PATH := "user://settings.cfg"
const SUPPORTED_LOCALES: Array[String] = ["fr", "en", "mg"]
const DEFAULT_LOCALE := "fr"

signal locale_changed(locale_code: String)

var _translations: Dictionary = {} # cle -> { locale: texte }
var _current_locale: String = DEFAULT_LOCALE

func _ready() -> void:
	_load_csv()
	_current_locale = _load_saved_locale()

## Renvoie le texte traduit pour une cle donnee (ex: "UI_PLAY").
## Si la cle est introuvable, on renvoie la cle elle-meme (utile pour debugger).
func t(key: String) -> String:
	if _translations.has(key) and _translations[key].has(_current_locale):
		return _translations[key][_current_locale]
	return key

## Change la langue active, previent tous les textes traduits, et sauvegarde.
func set_language(locale_code: String) -> void:
	if locale_code not in SUPPORTED_LOCALES:
		push_warning("Langue non supportee: %s, utilisation de %s" % [locale_code, DEFAULT_LOCALE])
		locale_code = DEFAULT_LOCALE
	_current_locale = locale_code
	_save_locale(locale_code)
	locale_changed.emit(locale_code)

func get_language() -> String:
	return _current_locale

func _load_csv() -> void:
	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		push_error("LocaleManager: impossible d'ouvrir %s" % CSV_PATH)
		return

	var header: PackedStringArray = file.get_csv_line()
	var locale_columns: Dictionary = {} # index de colonne -> code de langue
	for i in range(1, header.size()):
		locale_columns[i] = header[i].strip_edges()

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 2 or row[0].strip_edges() == "":
			continue
		var key: String = row[0].strip_edges()
		var entry: Dictionary = {}
		for i in locale_columns.keys():
			if i < row.size():
				entry[locale_columns[i]] = row[i]
		_translations[key] = entry

	file.close()

func _save_locale(locale_code: String) -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH) # ignore si le fichier n'existe pas encore
	config.set_value("settings", "locale", locale_code)
	config.save(CONFIG_PATH)

func _load_saved_locale() -> String:
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)
	if err != OK:
		return DEFAULT_LOCALE
	return config.get_value("settings", "locale", DEFAULT_LOCALE)
