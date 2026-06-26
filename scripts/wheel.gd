extends AnimatableBody2D

@export var transition_speed: float = 0.5
@export var player: CharacterBody2D

func _process(_delta: float) -> void:
	var cur_val = player.spins
	set_rotation_degrees(-3.6*cur_val)
	if cur_val <= 0:
		player.global_position.x = player.last_checkpoint.x + 10
		player.global_position.y = player.last_checkpoint.y + 10
		player.spins = 200
