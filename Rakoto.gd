extends CharacterBody2D

@export var speed : float = 120.0
@onready var animated_sprite = $AnimatedSprite2D
#@onready var animation_player = $AnimationPlayer # si tu utilises AnimationPlayer

var direction = Vector2.ZERO

func _physics_process(delta):
	# Input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Conversion isométrique (très important !)
		# Meilleure conversion isométrique
	var iso_dir = Vector2(
		input_dir.x - input_dir.y,
		(input_dir.x + input_dir.y) * 0.5
	).normalized()
	
	direction = iso_dir
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		animated_sprite.play("walk_ne")   # ou "walk_se", "walk_nw", etc. plus tard
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
	
	move_and_slide()
