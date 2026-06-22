extends CharacterBody2D

enum State {IDLE, WALKING, JUMP, ATK}
var current_state = State.IDLE

var SPEED = 300.0
var spins = 200
var whoaspins = 200
var timer = 0
var max_speed = 700

# jumping stuff
const PLAYER_TIME_SCALER = 1.2
const MAX_JUMP_TIME: float = 0.2
const JUMP_VELOCITY: float = -400.0
var jumptimer:float = 0.0
var gravity = 2000
var is_jumping = false


@onready var player: AnimatedSprite2D = $AnimatedSprite2D
@onready var atk: AnimatedSprite2D = $atk


func _physics_process(delta: float) -> void:
	
	var env_time_scale:float = 1.0
	if spins <= 150 and spins > 100:
		env_time_scale = spins * 0.01
	elif spins <= 100:
		env_time_scale = spins * 0.005
	else:
		env_time_scale = 1
		
	Engine.time_scale = env_time_scale
	
	var player_time_scale: float = lerp(env_time_scale, 1.0, 0.5)
	var global_delta = delta / Engine.time_scale if Engine.time_scale > 0 else delta
	var player_delta = global_delta * player_time_scale
	
	player.speed_scale = player_time_scale / env_time_scale
	atk.speed_scale = player_time_scale / env_time_scale
	# spin timer
	timer += 1
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		#print("started jump")
		velocity.y = JUMP_VELOCITY 
		is_jumping = true
	if Input.is_action_pressed("jump") and is_jumping:
		#print("loong jump")
		if jumptimer < MAX_JUMP_TIME:
			#print("it works?")
			#print(jumptimer)
			#print(delta)
			velocity.y = JUMP_VELOCITY
			jumptimer += player_delta
		else:
			#print("nope", jumptimer)
			is_jumping = false
	if Input.is_action_just_released("jump"):
		#print("jump ended")
		is_jumping = false
	if is_on_floor() and !Input.is_action_just_pressed("jump"):
		#print("on the flooh")
		is_jumping = false
		jumptimer = 0.0
	else:
		#print("not on the flooh?")
		if velocity.y < max_speed:
			velocity.y += gravity * player_delta * 0.5
		#velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var time_ratio = player_time_scale / env_time_scale
	velocity = velocity * time_ratio	
	move_and_slide()
	velocity = velocity / time_ratio
	
	if not is_on_floor():
		if velocity.y < max_speed:
			velocity.y += gravity * player_delta * 0.5

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
		
		
	# like clockwork
	if Input.is_action_just_pressed("spin"):
		if spins <= 200:
			spins += 10
		whoaspins += 10
	if Input.is_action_just_pressed("unspin"):
		spins -= 10
		whoaspins -= 10
	if Input.is_action_just_pressed("x"):
		player.play("atk")
		current_state = State.ATK
		atk.play("default")
		print("attack started")
	if timer % 10 == 0:
		spins -= 1
		whoaspins -= 1

		
	#var wheel = $AnimatedSprite2D
	#wheel.position = Vector2(-100,-200)
	
	if whoaspins > 500:
		spins = whoaspins
		SPEED = spins
	else:
		SPEED = 300


func _on_atk_animation_finished() -> void:
	current_state = State.IDLE
	print("attack ended")
