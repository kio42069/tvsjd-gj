extends CharacterBody2D

enum BossState {IDLE, IDLE_2, ATTACK, SUMMON, SKILL, DEATH}
@onready var boss_music: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var you_won: Label = $"../Labels/you won"
@onready var entrymusic: AudioStreamPlayer2D = $entrymusic
@onready var deathmusic: AudioStreamPlayer2D = $deathmusic

var current_health: int
@export var boss_walls: TileMapLayer

var is_active: bool = false

@export var max_health: int = 20

@export var speed: float = 200
@onready var player: CharacterBody2D = %Player
@export var small_ghost_scene: PackedScene = preload("res://scenes/small_ghost_scene.tscn")

var current_state = BossState.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $StateTimer
@onready var spawner: Marker2D = $Spawner
@onready var hurtbox: Area2D = $Hurtbox

signal boss_activated(max_hp: int)
signal health_changed(new_hp: int)
signal boss_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_timer.timeout.connect(_on_state_timer_timeout)
	#change_state(BossState.IDLE)
	add_to_group("Enemy")
	speed = Management.boss_speed
	max_health = Management.boss_speed
	sprite.play("idle 2")
	
func _physics_process(_delta: float) -> void:
	# Death
	speed = Management.boss_speed
	max_health = Management.boss_speed
	print("speed: ", speed, "max health: ", max_health)
	if not is_active:
		#print("idle")
		return
	#print("NOPE")
	# Go towards player
	if current_state == BossState.IDLE or current_state == BossState.IDLE_2:
		if player:
			var dir = (player.global_position - global_position).normalized()
			if global_position.y > -2160 and dir.y > 0:
				dir.y = 0
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
			spawn_minion()
			spawn_minion()
			state_timer.start(1.2)
			
		BossState.DEATH:
			sprite.play("death")
			velocity = Vector2.ZERO

func _on_state_timer_timeout() -> void:
	if current_state == BossState.DEATH or not is_active: return
	
	if current_state in [BossState.ATTACK, BossState.SKILL, BossState.SUMMON]:
		change_state(BossState.IDLE if randf() > 0.5 else BossState.IDLE_2)
	else:
		var choices = [BossState.ATTACK, BossState.SKILL, BossState.SUMMON]
		change_state(choices.pick_random())

func spawn_minion() -> void:
	if small_ghost_scene:
		var minion = small_ghost_scene.instantiate()
		minion.add_to_group("BossMinions")
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
	
	health_changed.emit(current_health)
	#print("Boss took damage! Current HP: ", current_health)
	var twitchy = create_tween()
	twitchy.tween_property(sprite, "modulate", Color.RED, 0.1)
	twitchy.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	# Flash the boss red briefly as damage feedback
	var twitch = create_tween()
	twitch.tween_property(sprite, "modulate", Color.RED, 0.1)
	twitch.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		change_state(BossState.DEATH)
		
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Checks if the overlapping area is your player's attack projectile
	if area.is_in_group("Attack"):
		take_damage(1)
		
		# Optional: Destroy the projectile after hitting the boss
		if area.has_method("queue_free"):
			area.queue_free()
			
func activate_boss() -> void:
	current_health = max_health
	entrymusic.play()
	is_active = true
	if boss_music and not boss_music.playing:
		var weewoo = create_tween()
		boss_music.play()
		weewoo.tween_property(boss_music, "volume_db", 10.0, 5.0)
		weewoo.tween_property(Bgm, "volume_db", -20, 5.0)

	change_state(BossState.IDLE)
	boss_activated.emit(max_health)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "death":
		get_tree().call_group("BossMinions", "die")
		boss_died.emit()
		deathmusic.play()
		start_outro_sequence()

func start_outro_sequence():
	var player_camera = player.find_child("Camera2D") as Camera2D
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(Bgm, "volume_db", 0, 3.0)
	if boss_walls:
		tween.tween_property(boss_walls, "modulate:a", 0.0, 2.0)
	if boss_music:
		tween.tween_property(boss_music, "volume_db", -40.0, 2.0)
	tween.tween_property(you_won, "modulate:a", 1.0, 3.0)
	if player_camera:
		tween.tween_property(player_camera, "global_position", player.global_position, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(player_camera, "zoom", Vector2(2.005, 2.005), 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	tween.tween_callback(func(): finish_encounter(player_camera))

func finish_encounter(cam: Camera2D):
	if boss_walls:
		boss_walls.collision_enabled = false
	if cam:
		cam.top_level = false
		cam.position = Vector2.ZERO
	queue_free()
