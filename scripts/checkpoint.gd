extends CollisionShape2D

@onready var player: CharacterBody2D = $'../../../Player'
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if body.name in "playerPlayer" or body is CharacterBody2D:
		player.last_checkpoint = global_position
		print("cp x : ", global_position.x)
		print("cp y : ", global_position.y)
		print("player entered")
