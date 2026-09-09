extends CharacterBody2D

var _tween_texte: Tween
# --- Références @ilay nœuds ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

@onready var dialog_box: Panel = $"../DialogUI/Panel"
@onready var dialogue_label: Label = $"../DialogUI/Panel/DialogueLabel"
@onready var btn_suite: Button = $"../DialogUI/Panel/BtnSuite"

@onready var comparison_panel: PanelContainer = $"../DialogUI/ComparisonPanel"

# --- Références des cellules uniques du tableau miampy références unique @statistique ---
@onready var lbl_rakoto_solde: Label = %RakotoSolde
@onready var lbl_rakoto_animaux: Label = %RakotoAnimaux
@onready var lbl_rakoto_cultures: Label = %RakotoCultures
@onready var lbl_rakoto_energie: Label = %RakotoEnergie # Nouveau

@onready var lbl_rasoa_solde: Label = %RasoaSolde # Nouveau
@onready var lbl_rasoa_animaux: Label = %RasoaAnimaux # Nouveau
@onready var lbl_rasoa_cultures: Label = %RasoaCultures # Nouveau
@onready var lbl_rasoa_energie: Label = %RasoaEnergie # Nouveau

@onready var lbl_titre_statistique: Label = %statistique

# --- Référence de l'image de profil (Avatar à droite) ---
@onready var avatar_rect: TextureRect = %AvatarRect


# --- Variables d'état (Initialisation ana variable) ---
var player_in_zone: bool = false
var is_talking: bool = false
var index_histoire: int = 0
var rakoto_a_gagne: bool = false

# --- Données réelles ou simulées de Rakoto ---
var rakoto_solde: int = 1200000    
var rakoto_animaux: int = 18      
var rakoto_cultures: int = 12     
var rakoto_energie: int = 150 

# --- Statistiques de Rasoa (qui vont devenir aléatoires et proches de Rakoto +ou-) ---
var rasoa_solde: int = 0
var rasoa_animaux: int = 0
var rasoa_cultures: int = 0
var rasoa_energie: int = 0

var script_dialogue: Array = [
	"Rasoa : « Diversifier protège contre les mauvaises saisons. »",
	"Rakoto : « Tu cultivives et élèves à la fois ? »",
	"Rasoa : « C’est la clé de la stabilité. Voyons où tu en es par rapport à ma ferme... »"
]

# Ny état anlé scène vo milance lé jeu
func _ready() -> void:
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	btn_suite.pressed.connect(_on_btn_suite_pressed)
	
	dialog_box.hide()
	comparison_panel.hide()
	btn_suite.hide()
	lbl_titre_statistique.hide()
	avatar_rect.hide() # Cacher l'avatar au lancement du jeu


func _input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("ui_accept") and not is_talking:
		demarrer_cinematique()


func demarrer_cinematique() -> void:
	is_talking = true
	dialog_box.show()
	btn_suite.show()
	index_histoire = 0
	
	var texte_actuel = script_dialogue[index_histoire]
	_lancer_effet_machine(texte_actuel)
	_mettre_a_jour_avatar(texte_actuel)


func _on_btn_suite_pressed() -> void:
	if index_histoire < script_dialogue.size() - 1:
		index_histoire += 1
		var texte_actuel = script_dialogue[index_histoire]
		_lancer_effet_machine(texte_actuel)
		_mettre_a_jour_avatar(texte_actuel)
	elif index_histoire == script_dialogue.size() - 1:
		index_histoire += 1
		generer_valeurs_rasoa() # Eto no micalcule anlé valeur +ou- par rapport à Rakoto!
		avatar_rect.hide() # On cache le grand avatar pour libérer l'écran lors du tableau de stats
		afficher_tableau_comparatif()
	else:
		conclure_histoire()


# --- 🎲 ANALYSE TEXTUELLE ET CHARGEMENT DU PORTRAIT ---
func _mettre_a_jour_avatar(texte_complet: String) -> void:
	var nom_du_personnage: String = ""
	
	# Vérification de l'interlocuteur en début de ligne
	if texte_complet.begins_with("Rasoa"):
		nom_du_personnage = "rasoa"
	elif texte_complet.begins_with("Rakoto"):
		nom_du_personnage = "rakoto"
	elif texte_complet.begins_with("L'Agent") or texte_complet.begins_with("Le Agent"):
		nom_du_personnage = "agent"
		
	if nom_du_personnage != "":
		var chemin_texture = "res://Textures/Avatars/" + nom_du_personnage + ".png"
		
		if ResourceLoader.exists(chemin_texture):
			avatar_rect.texture = load(chemin_texture)
			avatar_rect.show()
		else:
			avatar_rect.hide() # Cache si le fichier image est absent
	else:
		# Ligne de narration pure : on masque le portrait à droite
		avatar_rect.hide()


func generer_valeurs_rasoa() -> void:
	# Ity fonction ohatra randf_range(-0.15, 0.15) migénère un écart de maximum -15% ou +15% autour du score de Rakoto
	rasoa_solde = int(rakoto_solde * (1.0 + randf_range(-0.12, 0.12)))
	rasoa_animaux = int(rakoto_animaux * (1.0 + randf_range(-0.20, 0.20)))
	rasoa_cultures = int(rakoto_cultures * (1.0 + randf_range(-0.20, 0.20)))
	rasoa_energie = int(rakoto_energie * (1.0 + randf_range(-0.15, 0.15)))
	
	# Gestion d'erreur kely : Sécurité pour ne pas avoir de valeurs négatives ou à 0
	rasoa_animaux = max(1, rasoa_animaux)
	rasoa_cultures = max(1, rasoa_cultures)
	rasoa_energie = max(1, rasoa_energie)


func afficher_tableau_comparatif() -> void:
	# Colonne an'i Rakoto
	lbl_rakoto_solde.text = str(rakoto_solde) + " Ar"
	lbl_rakoto_animaux.text = str(rakoto_animaux)
	lbl_rakoto_cultures.text = str(rakoto_cultures)
	lbl_rakoto_energie.text = str(rakoto_energie) + " W"
	
	# Colonne an'i Rasoa
	lbl_rasoa_solde.text = str(rasoa_solde) + " Ar"
	lbl_rasoa_animaux.text = str(rasoa_animaux)
	lbl_rasoa_cultures.text = str(rasoa_cultures)
	lbl_rasoa_energie.text = str(rasoa_energie) + " W"
	
	comparison_panel.show()
	lbl_titre_statistique.show()

	dialogue_label.text = "Rasoa observe attentivement les résultats de vos deux exploitations..."
	
	# Micalcul ny victoire na tsia (Rakoto doit battre Rasoa sur au moins 2 critères sur 4)
	var criteres_gagnes: int = 0
	if r_solde_superieur_ou_egal(): criteres_gagnes += 1
	if rakoto_animaux >= rasoa_animaux: criteres_gagnes += 1
	if rakoto_cultures >= rasoa_cultures: criteres_gagnes += 1
	if rakoto_energie >= rasoa_energie: criteres_gagnes += 1
	
	rakoto_a_gagne = (criteres_gagnes >= 2)


func r_solde_superieur_ou_egal() -> bool:
	return rakoto_solde >= rasoa_solde


func conclure_histoire() -> void:
	comparison_panel.hide()
	lbl_titre_statistique.hide()
	btn_suite.hide()
	
	if rakoto_a_gagne:
		dialogue_label.text = "Rasoa : « Tu avances vite. Continue. »"
	else:
		dialogue_label.text = "Rasoa : « Chaque saison enseigne. N’abandonne pas. »"
	
	_lancer_effet_machine(dialogue_label.text)
	_mettre_a_jour_avatar(dialogue_label.text)
	
	await get_tree().create_timer(4.0).timeout
	quitter_scene()


func quitter_scene() -> void:
	dialog_box.hide()
	comparison_panel.hide()
	lbl_titre_statistique.hide()
	avatar_rect.hide() # Masquer l'avatar à la fermeture du dialogue

	is_talking = false


func _on_player_entered(body: Node2D) -> void:
	if body.name == "Rakoto":
		player_in_zone = true


func _on_player_exited(body: Node2D) -> void:
	if body.name == "Rakoto":
		player_in_zone = false
		quitter_scene()

# --- Fonction magique pour l'effet typewriter à copier tout en bas du script ---
func _lancer_effet_machine(texte_a_afficher: String) -> void:
	# 1. On applique le texte au label
	dialogue_label.text = texte_a_afficher
	
	# 2. On commence avec 0 caractère visible (écran vide)
	dialogue_label.visible_characters = 0
	
	# 3. Si un ancien effet tournait encore, on le coupe pour éviter les conflits
	if _tween_texte:
		_tween_texte.kill()
		
	# 4. On crée le nouveau Tween pour animer les lettres
	_tween_texte = create_tween()
	
	# Calcule le nombre total de lettres dans la phrase
	var nombre_de_lettres = texte_a_afficher.length()
	
	# Vitesse d'écriture : par exemple 0.03 seconde par lettre (ajustez à votre guise !)
	var duree_totale = nombre_de_lettres * 0.03
	
	# Fait varier la propriété "visible_characters" de 0 jusqu'au nombre total de lettres
	_tween_texte.tween_property(dialogue_label, "visible_characters", nombre_de_lettres, duree_totale)
