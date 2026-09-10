extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	RECOLTE
}

@export var speed: int = 400
@export_category("Stats")

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN
var last_horizontal_dir: float = 1.0 # 1.0 = Droite, -1.0 = Gauche
var recolte_started: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	animation_tree.active = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("recolte") and state != State.RECOLTE:
		# La récolte ne se déclenche que si la direction principale est horizontale (Gauche / Droite)
		if abs(last_direction.x) > abs(last_direction.y):
			state = State.RECOLTE
			recolte_started = false
			update_animation()

func _physics_process(_delta: float) -> void:
	if state == State.RECOLTE:
		var current_node = animation_playback.get_current_node()
		
		if current_node == "Recolte":
			recolte_started = true
		
		# Quand la boucle de récolte se termine et revient vers Idle
		if recolte_started and current_node == "Idle":
			if Input.is_action_pressed("recolte"):
				# Si le bouton reste maintenu, relance l'animation
				recolte_started = false
				animation_playback.travel("Recolte")
			else:
				# Si le bouton est relâché, retour à l'état IDLE
				state = State.IDLE
				recolte_started = false

		velocity = Vector2.ZERO
		return

	movement_loop()

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	velocity = move_direction.normalized() * speed
	move_and_slide()
	
	if velocity != Vector2.ZERO:
		last_direction = move_direction.normalized()
		
		# Enregistre la dernière direction horizontale (Gauche / Droite)
		if move_direction.x != 0:
			last_horizontal_dir = sign(move_direction.x)

		if state == State.IDLE:
			state = State.RUN
			update_animation()
	else:
		if state == State.RUN:
			state = State.IDLE
			update_animation()

	update_blend_positions()

func update_blend_positions() -> void:
	var dir_to_send = move_direction.normalized() if move_direction != Vector2.ZERO else last_direction
	
	# Idle et Run reçoivent le vecteur complet en 8 directions
	animation_tree.set("parameters/Idle/blend_position", dir_to_send)
	animation_tree.set("parameters/Run/blend_position", dir_to_send)
	
	# Recolte reçoit uniquement la direction X (Gauche/Droite)
	var recolte_x = dir_to_send.x if dir_to_send.x != 0 else last_horizontal_dir
	animation_tree.set("parameters/Recolte/blend_position", Vector2(recolte_x, 0))

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("Idle")
		State.RUN:
			animation_playback.travel("Run")
		State.RECOLTE:
			animation_playback.travel("Recolte")
