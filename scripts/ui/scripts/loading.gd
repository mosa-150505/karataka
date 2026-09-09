extends Control

## Duree minimale d'affichage de l'ecran, meme si le chargement reel est
## quasi instantane (evite un flash trop rapide et illisible).
## C'est une valeur standard pour ce genre d'ecran de transition.
const MIN_DISPLAY_TIME := 1.2

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var percent_label: Label = $PercentLabel

var _elapsed := 0.0
var _load_progress := 0.0
var _resource_path: String = ""
var _loading_started := false

func _ready() -> void:
	_resource_path = SceneManager.pending_scene_path
	if _resource_path == "":
		push_error("LoadingScreen: aucune scene cible definie (pending_scene_path vide)")
		return

	var err := ResourceLoader.load_threaded_request(_resource_path)
	if err != OK:
		push_error("LoadingScreen: impossible de lancer le chargement de %s (code %d)" % [_resource_path, err])
		return

	_loading_started = true

func _process(delta: float) -> void:
	if not _loading_started:
		return

	_elapsed += delta

	var progress_array: Array = []
	var status := ResourceLoader.load_threaded_get_status(_resource_path, progress_array)
	if progress_array.size() > 0:
		_load_progress = progress_array[0]

	# La barre avance au rythme du plus lent entre le chargement reel et le
	# temps minimum d'affichage : elle reflete le vrai chargement, sans
	# jamais finir trop vite pour l'oeil humain.
	var time_ratio: float = clamp(_elapsed / MIN_DISPLAY_TIME, 0.0, 1.0)
	var display_ratio: float = min(_load_progress, time_ratio)

	progress_bar.value = display_ratio * 100.0
	percent_label.text = "%d%%" % int(display_ratio * 100.0)

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			if _elapsed >= MIN_DISPLAY_TIME:
				_loading_started = false
				var resource: PackedScene = ResourceLoader.load_threaded_get(_resource_path)
				SceneManager.finish_loading(resource)
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("LoadingScreen: echec du chargement de %s" % _resource_path)
			_loading_started = false
