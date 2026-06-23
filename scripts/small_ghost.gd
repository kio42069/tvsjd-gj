extends CharacterBody2D

@export var float_speed: float = 40.0
@onready var player: CharacterBody2D
var move_direction: Vector2 = Vector2.ZERO
var is_active: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox

func _ready() -> void:
	# 1. Start with the summon animation
	is_active = false
	sprite.play("summon")
	sprite.animation_finished.connect(_on_animation_finished)
	
	# Connect Hitbox to see if it touches the player
	#hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# Setup random drifting direction
	_pick_new_direction()

func _physics_process(delta: float) -> void:
	if not is_active: 
		velocity = Vector2.ZERO
		return
		
	# Soft, floaty movement around its spawn area
	velocity = velocity.move_toward(move_direction * float_speed, 2.0)
	move_and_slide()

	# Slowly change drift direction randomly over time
	if randf() < 0.01: 
		_pick_new_direction()

func _pick_new_direction() -> void:
	# Drifts randomly in any 2D direction
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if move_direction.x != 0:
		sprite.flip_h = move_direction.x < 0

func _on_animation_finished() -> void:
	if sprite.animation == "summon":
		is_active = true
		sprite.play("idle") # Loop idle animation after spawning
	elif sprite.animation == "death":
		queue_free() # Safely delete ghost from memory

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Replace "Player" with your exact Player script class name or group
	if body.is_in_group("Player") and is_active:
		body.spins -= 30 # Damage the player
		
		# Optional: Small ghosts pop and die after hitting the player once
		is_active = false
		sprite.play("death")
