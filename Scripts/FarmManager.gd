extends Node
var player_inventory = Inventory.new(32) # Sac de 32 places
#teste de triche pour le système d'inventaire
#func _ready() -> void:
	## 1. On donne un budget de départ global
	#GameState.money = 250000 # 250 000 Ar
	#
	## 2. On crée une fausse donnée d'item de catégorie "recolte" (légume)
	#var legume_test = ItemData.new()
	#legume_test.item_name = "Carotte"
	#legume_test.category = "recolte"
	#
	## 3. On crée un fausse donnée d'item de catégorie "nourriture" (élevage)
	#var elevage_test = ItemData.new()
	#elevage_test.item_name = "Oeuf Frais"
	#elevage_test.category = "nourriture"
	#
	## 4. On remplit le sac de Rakoto automatiquement
	#player_inventory.add_item(legume_test, 15)   # 15 carottes
	#player_inventory.add_item(elevage_test, 8)    # 8 œufs
