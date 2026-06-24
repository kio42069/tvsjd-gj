extends CharacterBody2D

enum State {IDLE, WALKING, JUMP, ATK}
var current_state = State.IDLE

var SPEED = 300.0
var spins = 200
var whoaspins = 200
var timer = 0
var max_speed = 70000
const ACCELERATION = 5000

# jumping stuff
const PLAYER_TIME_SCALER = 1.2
const MAX_JUMP_TIME: float = 0.2
var JUMP_VELOCITY: float = -400.0
var jumptimer:float = 0.0
var gravity = 2000
var is_jumping = false
const COYOTE_TIME: float = 0.15
var coyote_timer:float = 0.0
const JUMP_BUFFER_TIME: float = 0.15
var jump_buffer_timer: float = 0.0

var last_checkpoint: Vector2

@onready var player: AnimatedSprite2D = $AnimatedSprite2D
@export var attack: PackedScene = preload("res://scenes/attack.tscn")

func _ready() -> void:
	last_checkpoint = global_position

func _physics_process(delta: float) -> void:
	var env_time_scale:float = 1.0
	if spins > 150:
		env_time_scale = 1
	elif spins <= 150 and spins > 100:
		env_time_scale = spins * 0.01
	elif spins <= 100 and spins > 0:
		env_time_scale = spins * 0.005
	else:
		env_time_scale = 0.01
	Engine.time_scale = env_time_scale
	
	var player_time_scale: float = lerp(env_time_scale, 1.0, 0.5)
	var global_delta = delta / Engine.time_scale if Engine.time_scale > 0 else delta
	var player_delta = global_delta * player_time_scale
	
	player.speed_scale = player_time_scale / env_time_scale
	timer += 1
	
	####### *sighs* jump stuff ts pmo sm
	### Coyote time and Jump Buffer management
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= player_delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= player_delta
	
	# Initialising a jump
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY 
		is_jumping = true
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		
	# Variable jump height
	if Input.is_action_pressed("jump") and is_jumping:
		if jumptimer < MAX_JUMP_TIME:
			velocity.y = JUMP_VELOCITY
			jumptimer += player_delta
		else:
			is_jumping = false
	if Input.is_action_just_released("jump"):
		is_jumping = false
	
	# Gravity (half?) anf apex hang time
	if is_on_floor() and !Input.is_action_just_pressed("jump"):
		is_jumping = false
		jumptimer = 0.0
	else:
		if velocity.y < max_speed:
			if abs(velocity.y) < 100:
				velocity.y += gravity * player_delta * 0.25
			else:
				velocity.y += gravity * player_delta * 0.5
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * player_delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * player_delta)
	
	var time_ratio = player_time_scale / env_time_scale
	velocity = velocity * time_ratio	
	move_and_slide()
	velocity = velocity / time_ratio
	
	if not is_on_floor():
		if velocity.y < max_speed:
			if abs(velocity.y) < 100:
				velocity.y += gravity * player_delta * 0.25
			else:
				velocity.y += gravity * player_delta * 0.5

	if direction > 0:
		player.flip_h = false
	elif direction < 0:
		player.flip_h = true
	
	if direction == 0 and current_state != State.ATK:
		player.play("idle")
	elif direction != 0 and current_state != State.ATK:
		player.play("run")
	
	# time dilation
	if Input.is_action_just_pressed("spin"):
		if spins <= 200:
			spins += 10
		whoaspins += 10
	if Input.is_action_just_pressed("unspin"):
		spins -= 10
		whoaspins -= 10
		
	# attacking
	if Input.is_action_just_pressed("x"):
		player.play("atk")
		current_state = State.ATK
		var projectile = attack.instantiate()
		if player.flip_h:
			projectile.direction = Vector2.LEFT
			projectile.global_position = global_position + Vector2(0, -7)
		else:
			projectile.direction = Vector2.RIGHT
			projectile.global_position = global_position + Vector2(0, -7)
		
		get_parent().add_child(projectile)
	if timer % 15 == 0:
		spins -= 1
		whoaspins -= 1

	# overcharming
	if whoaspins > 500:
		spins = whoaspins
		SPEED = spins
		JUMP_VELOCITY = -400 - (spins)
		gravity = (spins) + 2000
	else:
		SPEED = 300
		JUMP_VELOCITY = -400
		gravity = 2000


func _on_animated_sprite_2d_animation_finished() -> void:
	current_state = State.IDLE


func _on_player_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if body.is_in_group("Boss"):
			print("Player hit by boss! Retracting spins.")
			var twitch = create_tween()
			twitch.tween_property(player, "modulate", Color.RED, 0.1)
			twitch.tween_property(player, "modulate", Color.WHITE, 0.1)
			spins = max(0, spins - 100)
			whoaspins = max(0, whoaspins - 100)
		else:
			print("Player hit by enemy!")
			var twitch = create_tween()
			twitch.tween_property(player, "modulate", Color.RED, 0.1)
			twitch.tween_property(player, "modulate", Color.WHITE, 0.1)
			spins = max(0,spins - 50)
			whoaspins = max(whoaspins-50, 0)
