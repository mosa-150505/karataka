extends CharacterBody2D

var _tween_texte: Tween
# --- Références aux nœuds enfants de Rasoa ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

@onready var dialog_box: Panel = $"../DialogUI/Panel"
@onready var dialogue_label: Label = $"../DialogUI/Panel/DialogueLabel"
@onready var btn_suite: Button = $"../DialogUI/Panel/BtnSuite"

@onready var comparison_panel: PanelContainer = $"../DialogUI/ComparisonPanel"

# --- Références des cellules uniques du tableau ---
@onready var lbl_rakoto_solde: Label = %RakotoSolde
@onready var lbl_rakoto_animaux: Label = %RakotoAnimaux
@onready var lbl_rakoto_cultures: Label = %RakotoCultures
@onready var lbl_rakoto_energie: Label = %RakotoEnergie 

@onready var lbl_rasoa_solde: Label = %RasoaSolde 
@onready var lbl_rasoa_animaux: Label = %RasoaAnimaux 
@onready var lbl_rasoa_cultures: Label = %RasoaCultures 
@onready var lbl_rasoa_energie: Label = %RasoaEnergie 

@onready var lbl_titre_statistique: Label = %statistique

# --- Référence de l'image de profil (Avatar à droite) ---
@onready var avatar_rect: TextureRect = %AvatarRect

# --- Variables d'état ---
var player_in_zone: bool = false
var is_talking: bool = false
var index_histoire: int = 0
var rakoto_a_gagne: bool = false

# --- Conteneurs de données dynamiques pour Rakoto ---
var rakoto_solde: int = 0    
var rakoto_animaux: int = 0      
var rakoto_cultures: int = 0     
var rakoto_energie: int = 150 # Valeur fixe exemple pour la production énergétique

# --- Statistiques de Rasoa ---
var rasoa_solde: int = 0
var rasoa_animaux: int = 0
var rasoa_cultures: int = 0
var rasoa_energie: int = 0

var script_dialogue: Array = [
	"Rasoa : « Diversifier protège contre les mauvaises saisons. »",
	"Rakoto : « Tu cultives et élèves à la fois ? »",
	"Rasoa : « C’est la clé de la stabilité. Voyons où tu en es par rapport à ma ferme... »"
]

func _ready() -> void:
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	btn_suite.pressed.connect(_on_btn_suite_pressed)
	
	dialog_box.hide()
	comparison_panel.hide()
	btn_suite.hide()
	lbl_titre_statistique.hide()
	avatar_rect.hide() 

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
		generer_valeurs_rasoa() 
		avatar_rect.hide() 
		afficher_tableau_comparatif()
	else:
		conclure_histoire()

# --- 🎲 ANALYSE TEXTUELLE ET CHARGEMENT DU PORTRAIT ---
func _mettre_a_jour_avatar(texte_complet: String) -> void:
	var nom_du_personnage: String = ""
	
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
			avatar_rect.hide() 
	else:
		avatar_rect.hide()

func generer_valeurs_rasoa() -> void:
	# Récupère d'abord le VRAI solde de Rakoto pour équilibrer le score de Rasoa
	rakoto_solde = GameState.money
	
	# Calcule des valeurs proches pour Rasoa
	rasoa_solde = int(rakoto_solde * (1.0 + randf_range(-0.12, 0.12)))
	rasoa_animaux = int(rakoto_animaux * (1.0 + randf_range(-0.20, 0.20)))
	rasoa_cultures = int(rakoto_cultures * (1.0 + randf_range(-0.20, 0.20)))
	rasoa_energie = int(rakoto_energie * (1.0 + randf_range(-0.15, 0.15)))
	
	rasoa_animaux = max(1, rasoa_animaux)
	rasoa_cultures = max(1, rasoa_cultures)
	rasoa_energie = max(1, rasoa_energie)

func afficher_tableau_comparatif() -> void:
	# 1. LIRE LES VRAIES DONNÉES DE L'INVENTAIRE GLOBAL ET DU SOLDE
	rakoto_solde = GameState.money
	rakoto_cultures = 0
	rakoto_animaux = 0
	
	# Parcourt le sac à dos de Rakoto géré par l'Autoload FarmManager
	for slot in FarmManager.player_inventory.slots:
		if slot.item != null:
			if slot.item.category == "recolte":
				rakoto_cultures += slot.quantity
			elif slot.item.category == "nourriture":
				rakoto_animaux += slot.quantity

	# 2. Remplir la colonne de Rakoto
	lbl_rakoto_solde.text = str(rakoto_solde) + " Ar"
	lbl_rakoto_animaux.text = str(rakoto_animaux)
	lbl_rakoto_cultures.text = str(rakoto_cultures)
	lbl_rakoto_energie.text = str(rakoto_energie) + " W"
	
	# 3. Remplir la colonne de Rasoa
	lbl_rasoa_solde.text = str(rasoa_solde) + " Ar"
	lbl_rasoa_animaux.text = str(rasoa_animaux)
	lbl_rasoa_cultures.text = str(rasoa_cultures)
	lbl_rasoa_energie.text = str(rasoa_energie) + " W"
	
	comparison_panel.show()
	lbl_titre_statistique.show()

	dialogue_label.text = "Rasoa observe attentivement les résultats de vos deux exploitations..."
	
	# Calcul des critères de victoire (Victoire si Rakoto bat Rasoa sur 2 critères ou plus)
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
	avatar_rect.hide() 
	is_talking = false

func _on_player_entered(body: Node2D) -> void:
	if body.name == "Rakoto":
		player_in_zone = true

func _on_player_exited(body: Node2D) -> void:
	if body.name == "Rakoto":
		player_in_zone = false
		quitter_scene()

# --- Effet machine à écrire (Typewriter) ---
func _lancer_effet_machine(texte_a_afficher: String) -> void:
	dialogue_label.text = texte_a_afficher
	dialogue_label.visible_characters = 0
	
	if _tween_texte:
		_tween_texte.kill()
		
	_tween_texte = create_tween()
	var nombre_de_lettres = texte_a_afficher.length()
	var duree_totale = nombre_de_lettres * 0.03
	_tween_texte.tween_property(dialogue_label, "visible_characters", nombre_de_lettres, duree_totale)
