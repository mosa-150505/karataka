extends CharacterBody2D

@export var speed: float = 120.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Animation affichée dès le lancement du jeu
	animated_sprite.scale = Vector2(1.0, 1.0)
	animated_sprite.play("idle")
	velocity = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	# Maka an'ilay touche de déplacement
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# ===================================================
	# Raha tsisy touche potserina →  RAKOTO mouvement idle
	# ===================================================
	if input_dir.is_zero_approx():
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		move_and_slide()
		return

	# =========================================
	# CONVERSION EN DÉPLACEMENT ISOMÉTRIQUE
	# ========================================
	var iso_dir := Vector2(
		input_dir.x - input_dir.y,
		(input_dir.x + input_dir.y) * 0.5
	)

	direction = iso_dir.normalized()

	# ========================================
	# DÉPLACEMENT
	# ========================================
	velocity = direction * speed

	# ========================================
	# ANIMATION
	# ========================================
	update_animation()

	move_and_slide()


func update_animation() -> void:
	animated_sprite.scale = Vector2(1.0, 1.0)
	
	# walk_ne ihany aloa fa tsy ilaina ny sasany
	animated_sprite.play("walk_ne")
	
