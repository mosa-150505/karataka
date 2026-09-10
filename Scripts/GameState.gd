extends Node
# res://scripts/GameState.gd

signal money_changed(new_amount: int)

var money: int = 0 # Commencer à 0 Ar comme convenu

func add_money(amount: int) -> void:
	if amount <= 0:
		return
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if amount <= 0:
		return true
	
	# SÉCURITÉ DESIGN : Si la perte est supérieure au solde, on bloque à 0 Ar
	if money < amount:
		money = 0
		money_changed.emit(money)
		return false 
		
	money -= amount
	money_changed.emit(money)
	return true
