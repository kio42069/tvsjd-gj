extends AnimatableBody2D

@export var transition_speed: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@export var player: CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var cur_val = player.spins
	set_rotation_degrees(-3.6*cur_val)
	if cur_val < 0:
		get_tree().reload_current_scene()
