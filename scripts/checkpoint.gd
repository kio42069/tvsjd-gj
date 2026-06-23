extends CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name in "playerPlayer" or body is CharacterBody2D:
		body.last_checkpoint = global_position
		#print("cp x : ", global_position.x)
		#print("cp y : ", global_position.y)
		#print("player entered")
