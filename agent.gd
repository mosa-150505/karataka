extends CharacterBody2D

var _tween_texte: Tween
# --- Références aux nœuds enfants de l'Agent ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

# --- Références UI ---
@onready var dialog_box: Panel = $"../DialogUI/Panel"
@onready var dialogue_label: Label = $"../DialogUI/Panel/DialogueLabel"
@onready var answer_input: LineEdit = $"../DialogUI/Panel/AnswerInput"
@onready var btn_oui: Button = $"../DialogUI/Panel/HBoxContainer/BtnOui"
@onready var btn_non: Button = $"../DialogUI/Panel/HBoxContainer/BtnNon"
@onready var btn_cheat: Button = $"../DialogUI/Panel/BtnCheat"

# --- Référence de l'image de profil (Avatar à droite) ---
@onready var avatar_rect: TextureRect = %AvatarRect

# --- Variables d'état et de données (Initialisation) ---
var player_in_zone: bool = false
var is_talking: bool = false
var solde_ariary: int = 0
var mode_attente_choix: bool = false
var question_actuelle: Dictionary

# Base de données des questions financières de l'agent
var questions: Array = [
	{
		"theme": "Intérêts Simples",
		"enonce": "Quel est le montant de la valeur acquise d'un capital de 500 000 Ar placé à un taux annuel simple de 15 % pendant un trimestre ?",
		"interets": 18750,
		"reponse_correcte": "518750"
	},
	{
		"theme": "Intérêts Simples",
		"enonce": "Un capital de 200 000 Ar est placé pendant 60 jours au taux annuel de 9 %. Calculez la valeur acquise (base de 360 jours).",
		"interets": 3000,
		"reponse_correcte": "203000"
	},
	{
		"theme": "Intérêts Composés",
		"enonce": "Quelle est la valeur acquise d'un capital de 1 000 000 Ar placé pendant 2 ans à un taux d'intérêt composé annuel de 10 % ?",
		"interets": 210000,
		"reponse_correcte": "1210000"
	},
	{
		"theme": "Intérêts Composés",
		"enonce": "Trouvez la valeur acquise d'un capital de 600 000 Ar placé à intérêts composés pendant 3 ans au taux annuel de 5 %.",
		"interets": 94575,
		"reponse_correcte": "694575"
	},
	{
		"theme": "Annuités",
		"enonce": "Quelle est la valeur acquise d'une suite de 3 annuités constantes de fin de période de 100 000 Ar chacune, au taux de 10 % ?",
		"interets": 31000,
		"reponse_correcte": "331000"
	}
]

# ==========================================
# VIRTUAL METHODS
# ==========================================
func _ready() -> void:
	# Connexion des signaux de zone de détection
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	# Connexion des signaux d'interface utilisateur
	answer_input.text_submitted.connect(_on_answer_submitted)
	btn_oui.pressed.connect(_on_btn_oui_pressed)
	btn_non.pressed.connect(_on_btn_non_pressed)
	btn_cheat.pressed.connect(_on_btn_cheat_pressed)
	
	# Cacher l'UI de base
	dialog_box.hide()
	avatar_rect.hide()

func _input(event: InputEvent) -> void:
	# Si Rakoto est proche, appuie sur Espace/Entrée et ne parle pas déjà
	if player_in_zone and event.is_action_pressed("ui_accept") and not is_talking:
		proposer_tour()

# ==========================================
# PRIVATE METHODS (Logique du Jeu)
# ==========================================
func proposer_tour() -> void:
	is_talking = true
	mode_attente_choix = true
	dialog_box.show()
	answer_input.hide()
	btn_cheat.hide()
	btn_oui.show()
	btn_non.show()
	
	btn_oui.text = "" if solde_ariary == 0 else ""
	btn_non.text = ""
	
	var phrase = "L'Agent : Bienvenue à la Roulette Financière. Votre solde actuel est de " + str(solde_ariary) + " Ar. Voulez-vous lancer la roulette ou préférez-vous quitter le jeu ?"
	_lancer_effet_machine(phrase) 
	_mettre_a_jour_avatar(phrase)


func lancer_roulette() -> void:
	mode_attente_choix = false
	btn_oui.hide()
	btn_non.hide()
	answer_input.show()
	answer_input.clear()
	answer_input.editable = true
	answer_input.grab_focus()
	
	# Choisit une question de la liste au hasard
	question_actuelle = questions.pick_random()
	
	var question = "Le Agent : La roulette tourne... et s'arrête sur les " + question_actuelle["theme"] + " !\nVoici votre énoncé : \"" + question_actuelle["enonce"] + "\"\nEntrez le montant de la Valeur Acquise (chiffres uniquement) :"
	_lancer_effet_machine(question)
	_mettre_a_jour_avatar(question)
	

func _on_answer_submitted(player_answer: String) -> void:
	answer_input.editable = false
	var reponse_nettoye = player_answer.strip_edges()
	
	if reponse_nettoye == question_actuelle["reponse_correcte"]:
		var gain = int(question_actuelle["reponse_correcte"])
		solde_ariary += gain
		
		if animated_sprite.sprite_frames.has_animation("motion_congrat"):
			animated_sprite.play("motion_congrat")
			
		var réponse = "L'Agent : C'est une excellente réponse ! Vous gagnez la valeur acquise complète de " + str(gain) + " Ar.\nVotre nouveau solde est de : " + str(solde_ariary) + " Ar."
		_lancer_effet_machine(réponse)
	else:
		var perte = question_actuelle["interets"]
		solde_ariary -= perte
		
		if animated_sprite.sprite_frames.has_animation("motion_deception"):
			animated_sprite.play("motion_deception")
			
		var réponse = "L'Agent : Mauvaise réponse ! La réponse exacte était " + question_actuelle["reponse_correcte"] + " Ar.\nVous perdez les intérêts soit " + str(perte) + " Ar.\nVotre nouveau solde est de : " + str(solde_ariary) + " Ar."
		_lancer_effet_machine(réponse)
		btn_cheat.show()

	_mettre_a_jour_avatar(dialogue_label.text)

	# Miandry 4 secondes pour laisser lire le résultat avant le tour suivant
	await get_tree().create_timer(4.0).timeout
	proposer_tour()

func quitter_dialogue() -> void:
	dialog_box.hide()
	avatar_rect.hide()
	is_talking = false

# --- 🎲 ANALYSE TEXTUELLE ET CHARGEMENT DU PORTRAIT ---
func _mettre_a_jour_avatar(texte_complet: String) -> void:
	var nom_du_personnage: String = ""
	
	# Détection de l'interlocuteur en début de ligne
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

# ==========================================
# CALLBACK METHODS (Signaux d'UI et de zone)
# ===========================================
func _on_btn_oui_pressed() -> void:
	if mode_attente_choix:
		lancer_roulette()

func _on_btn_non_pressed() -> void:
	if mode_attente_choix:
		dialogue_label.text = "L'Agent : C'est la fin du jeu ! Vous repartez avec un montant final de " + str(solde_ariary) + " Ar. Merci d'avoir joué !"
		_mettre_a_jour_avatar(dialogue_label.text)
		btn_oui.hide()
		btn_non.hide()
		await get_tree().create_timer(3.0).timeout
		quitter_dialogue()

func _on_btn_cheat_pressed() -> void:
	dialogue_label.text = "[AIDE AGENT] La valeur acquise exacte attendue est : " + question_actuelle["reponse_correcte"] + " Ar."
	_mettre_a_jour_avatar(dialogue_label.text)
	btn_cheat.hide()

func _on_player_entered(body: Node2D) -> void:
	if body.name == "Rakoto":
		player_in_zone = true

func _on_player_exited(body: Node2D) -> void:
	if body.name == "Rakoto":
		player_in_zone = false
		quitter_dialogue()




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
