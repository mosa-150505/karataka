extends Node

## Autoload : gere la musique et les bruitages du jeu.
##
## POUR AJOUTER TES SONS :
## - Musique de menu -> assets/audio/music/menu_theme.(ogg|mp3|wav)
## - Musique de jeu  -> assets/audio/music/game_theme.(ogg|mp3|wav)
## - Son de clic     -> assets/audio/sfx/click.(ogg|mp3|wav)
## N'importe laquelle de ces 3 extensions fonctionne, garde juste la vraie
## extension de ton fichier (ne renomme pas un .mp3 en .ogg, ca ne convertit
## rien et Godot ne pourra pas le lire).
## Tant qu'aucun fichier n'est present, le jeu fonctionne normalement, juste
## sans ce son (un avertissement s'affiche dans l'onglet Sortie).

const CONFIG_PATH := "user://settings.cfg"

const MENU_MUSIC_BASENAME := "res://assets/audio/music/menu_theme"
const GAME_MUSIC_BASENAME := "res://assets/audio/music/game_theme"
const CLICK_SFX_BASENAME := "res://assets/audio/sfx/click"

const AUDIO_EXTENSIONS: Array[String] = [".ogg", ".mp3", ".wav"]
const SFX_POOL_SIZE := 4

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_player: int = 0
var _current_music_path: String = ""

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)

	_load_saved_mute_state()

	# Connecte automatiquement le son de clic a tous les boutons deja presents...
	_auto_connect_buttons(get_tree().root)
	# ... et a tous ceux qui seront crees plus tard (changement de scene, etc.)
	get_tree().node_added.connect(_on_node_added)

## Cherche un fichier existant parmi les extensions supportees pour un nom
## de base donne (ex: "res://assets/audio/music/menu_theme").
func _resolve_path(basename: String) -> String:
	for ext in AUDIO_EXTENSIONS:
		var path: String = basename + ext
		if ResourceLoader.exists(path):
			return path
	return ""

## --- Musique ---

## Joue une musique en boucle a partir d'un nom de base (sans extension).
## Ne fait rien si aucun fichier correspondant n'existe encore.
func play_music(basename: String, loop: bool = true) -> void:
	var path := _resolve_path(basename)
	if path == "":
		push_warning("AudioManager: musique introuvable pour %s.(ogg|mp3|wav) (depose le fichier pour l'activer)" % basename)
		return
	if path == _current_music_path and _music_player.playing:
		return
	var stream: AudioStream = load(path)
	if _music_player.finished.is_connected(_on_music_finished):
		_music_player.finished.disconnect(_on_music_finished)
	_music_player.stream = stream
	if loop:
		_music_player.finished.connect(_on_music_finished)
	_music_player.play()
	_current_music_path = path

func stop_music() -> void:
	_music_player.stop()
	_current_music_path = ""

func _on_music_finished() -> void:
	_music_player.play()

## --- Bruitages ---

## Joue un bruitage a partir d'un nom de base (sans extension).
func play_sfx(basename: String) -> void:
	var path := _resolve_path(basename)
	if path == "":
		push_warning("AudioManager: son introuvable pour %s.(ogg|mp3|wav) (depose le fichier pour l'activer)" % basename)
		return
	var stream: AudioStream = load(path)
	var player := _sfx_players[_next_sfx_player]
	_next_sfx_player = (_next_sfx_player + 1) % _sfx_players.size()
	player.stream = stream
	player.play()

func play_click() -> void:
	play_sfx(CLICK_SFX_BASENAME)

## --- Volume / mute ---

func set_music_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), muted)
	_save_mute_state()

func set_sfx_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), muted)
	_save_mute_state()

func is_music_muted() -> bool:
	var idx := AudioServer.get_bus_index("Music")
	return idx != -1 and AudioServer.is_bus_mute(idx)

func is_sfx_muted() -> bool:
	var idx := AudioServer.get_bus_index("SFX")
	return idx != -1 and AudioServer.is_bus_mute(idx)

func _save_mute_state() -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value("audio", "music_muted", is_music_muted())
	config.set_value("audio", "sfx_muted", is_sfx_muted())
	config.save(CONFIG_PATH)

func _load_saved_mute_state() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	set_music_muted(config.get_value("audio", "music_muted", false))
	set_sfx_muted(config.get_value("audio", "sfx_muted", false))

## --- Clic automatique sur tous les boutons ---

func _on_node_added(node: Node) -> void:
	if node is Button:
		_connect_button(node)

func _auto_connect_buttons(node: Node) -> void:
	if node is Button:
		_connect_button(node)
	for child in node.get_children():
		_auto_connect_buttons(child)

func _connect_button(button: Button) -> void:
	if not button.pressed.is_connected(play_click):
		button.pressed.connect(play_click)
