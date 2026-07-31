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
		
		if direction.x > 0 and direction.y < 0:
			animated_sprite.play("walk_NE")
		elif direction.x < 0 and direction.y < 0:
			animated_sprite.play("walk_NW")
		elif direction.x > 0 and direction.y > 0:
			animated_sprite.play("walk_SE")
		elif direction.x < 0 and direction.y > 0:
			animated_sprite.play("walk_SW")
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("IDLE")
	move_and_slide()
