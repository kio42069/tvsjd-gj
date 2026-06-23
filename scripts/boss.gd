extends CharacterBody2D

enum BossState {IDLE, IDLE_2, ATTACK, SUMMON, SKILL, DEATH}

@export var max_health: int = 10
var current_health: int = max_health

@export var speed: float = 100.0
@onready var player: CharacterBody2D = %Player
@export var small_ghost_scene: PackedScene = preload("res://scenes/small_ghost_scene.tscn")

var current_state = BossState.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $StateTimer
@onready var spawner: Marker2D = $Spawner
@onready var hurtbox: Area2D = $Hurtbox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_timer.timeout.connect(_on_state_timer_timeout)
	change_state(BossState.IDLE)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	add_to_group("Enemy")
	
func _physics_process(delta: float) -> void:
	# Death
	if current_state == BossState.DEATH:
		return
	
	# Go towards player
	if current_state == BossState.IDLE or current_state == BossState.IDLE_2:
		if player:
			var dir = (player.global_position - global_position).normalized()
			velocity = velocity.move_toward(dir * speed, 5.0)
			_look_at_player()
	else:
		# Stop moving during heavy attacks/summons
		velocity = velocity.move_toward(Vector2.ZERO, 10.0)
	move_and_slide()
	
func change_state(new_state: BossState) -> void:
	current_state = new_state
	
	match current_state:
		BossState.IDLE:
			sprite.play("idle")
			state_timer.start(randf_range(2.0, 3.0))
			
		BossState.IDLE_2:
			sprite.play("idle 2")
			state_timer.start(randf_range(1.5, 2.5))
			
		BossState.ATTACK:
			sprite.play("attack")
			# If you aren't using AnimationPlayer function calls, use the timer for attack length
			state_timer.start(1.0) 
			
		BossState.SKILL:
			sprite.play("skill")
			# Logic for tendril expansion (e.g., turning on a larger hitbox) goes here
			state_timer.start(1.5)
			
		BossState.SUMMON:
			sprite.play("summon")
			spawn_minion()
			state_timer.start(1.2)
			
		BossState.DEATH:
			sprite.play("death")
			velocity = Vector2.ZERO

func _on_state_timer_timeout() -> void:
	if current_state == BossState.DEATH: return
	
	if current_state in [BossState.ATTACK, BossState.SKILL, BossState.SUMMON]:
		change_state(BossState.IDLE if randf() > 0.5 else BossState.IDLE_2)
	else:
		var choices = [BossState.ATTACK, BossState.SKILL, BossState.SUMMON]
		change_state(choices.pick_random())

func spawn_minion() -> void:
	if small_ghost_scene:
		var minion = small_ghost_scene.instantiate()
		minion.global_position = spawner.global_position
		if player: minion.player = player 
		get_parent().add_child(minion)	

func _look_at_player() -> void:
	if player:
		sprite.flip_h = player.global_position.x < global_position.x
		
func take_damage(amount: int) -> void:
	if current_state == BossState.DEATH:
		return
		
	current_health -= amount
	print("Boss took damage! Current HP: ", current_health)
	
	# Flash the boss red briefly as damage feedback
	var twitch = create_tween()
	twitch.tween_property(sprite, "modulate", Color.RED, 0.1)
	twitch.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		change_state(BossState.DEATH)
		
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Checks if the overlapping area is your player's attack projectile
	if area.name.to_lower().contains("attack") or area.is_in_group("PlayerAttack"):
		take_damage(1)
		
		# Optional: Destroy the projectile after hitting the boss
		if area.has_method("queue_free"):
			area.queue_free()
