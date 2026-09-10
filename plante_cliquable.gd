extends TextureButton
# res://Scripts/PlanteCliquable.gd

@export var nom_de_la_plante: String = "Mais" # Écrire "Mais", "Riz" ou "Manioc" dans l'inspecteur
@export var quantite_a_donner: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pressed.connect(_on_plante_cliquee)
	
	# Génère dynamiquement le nom de l'animation de repos (ex: "mais_idle", "riz_idle")
	var anim_idle = nom_de_la_plante.to_lower() + "_idle"
	
	if animated_sprite.sprite_frames.has_animation(anim_idle):
		animated_sprite.play(anim_idle)

func _on_plante_cliquee() -> void:
	disabled = true # Bloque les double-clics
	
	# 1. Traitement des données et ajout dans le sac global
	var ui = get_node_or_null("/root/Home_Rakoto/InventoryUI")
	var item_a_ajouter: ItemData = null
	
	if ui != null:
		if nom_de_la_plante == "Mais": item_a_ajouter = ui.item_mais
		elif nom_de_la_plante == "Riz": item_a_ajouter = ui.item_riz
		elif nom_de_la_plante == "Viande": item_a_ajouter = ui.item_viande
		elif nom_de_la_plante == "Manioc": item_a_ajouter = ui.item_manioc
			
	if item_a_ajouter != null:
		FarmManager.player_inventory.add_item(item_a_ajouter, quantite_a_donner)
		
		if ui.status_label != null:
			ui.status_label.text = "Récolté : +%d %s !" % [quantite_a_donner, nom_de_la_plante]
			ui.status_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))
			
		if ui._inventory_open:
			ui._update_slots_display()

	# 2. Lancement visuel de l'animation de récolte correspondante (ex: "mais_recolte", "riz_recolte")
	var anim_recolte = nom_de_la_plante.to_lower() + "_recolte"
	
	if animated_sprite.sprite_frames.has_animation(anim_recolte):
		animated_sprite.play(anim_recolte)
		await animated_sprite.animation_finished # Attend la fin des images avant de détruire le nœud
	
	queue_free()
