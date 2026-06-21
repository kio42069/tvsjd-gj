extends CharacterBody2D

enum State {IDLE, WALKING, JUMP, ATK}
var current_state = State.IDLE

var SPEED = 300.0
var spins = 100
var timer = 0

# jumping stuff
var jumpvelocity:float = 0.0
var jumptimer:float = 0.0
var gravity = 30

@onready var player: AnimatedSprite2D = $AnimatedSprite2D
@onready var atk: AnimatedSprite2D = $atk


func _physics_process(delta: float) -> void:

	# Add the gravity.
	timer += 1
	
	if Input.is_action_just_pressed("jump"):
		jumpvelocity = -400 
	if Input.is_action_pressed("jump") and jumptimer < 0.25:
		velocity.y = jumpvelocity
		jumptimer += delta
	if !Input.is_action_pressed("jump") and is_on_floor():
		jumptimer = 0.0
		jumpvelocity = 0.0
	if !is_on_floor():
		velocity.y += gravity
		#velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	if direction > 0:
		player.flip_h = false
		atk.set_offset(Vector2(0,0))
		atk.flip_h = false
	elif direction < 0:
		atk.flip_h = true
		atk.set_offset(Vector2(-30,0))
		player.flip_h = true
	
	if direction == 0 and current_state != State.ATK:
		player.play("idle")
	elif direction != 0 and current_state != State.ATK:
		player.play("run")
	if Input.is_action_just_pressed("spin"):
		spins += 5
	if Input.is_action_just_pressed("unspin"):
		spins -= 5
	if Input.is_action_just_pressed("x"):
		player.play("atk")
		current_state = State.ATK
		atk.play("default")
		print("attack started")
	if timer % 10 == 0:
		spins -= 1
	if spins <= 50:
		Engine.time_scale = spins * 0.02
	elif spins <= 30:
		Engine.time_scale = spins * 0.01
	else:
		Engine.time_scale = 1
		
	#var wheel = $AnimatedSprite2D
	#wheel.position = Vector2(-100,-200)
	
	if spins > 500:
		SPEED += spins


func _on_atk_animation_finished() -> void:
	current_state = State.IDLE
	print("attack ended")
