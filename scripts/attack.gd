extends Area2D

@export var speed: float = 600.0
@export var max_distance: float = 400.0

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

@onready var sprite: AnimatedSprite2D = $atk

func _ready() -> void:
	sprite.play("default")
	sprite.flip_h = direction.x < 0
	print(get_parent())
	
func _physics_process(delta: float) -> void:
	var move_amount = direction * speed * delta
	position += move_amount
	
	distance_traveled += move_amount.length()
	if distance_traveled >= max_distance:
		queue_free()
		
func _on_body_entered(body: Node2D) -> void:
	print("whew")
	if body is CharacterBody2D and body.name == "Player":
		print("whoops")
		return
		
	print("Projectile hit: ", body.name)
	queue_free()
