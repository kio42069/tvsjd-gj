extends Area2D
@onready var player: CharacterBody2D = %Player

var out: bool = false

func _physics_process(delta: float) -> void:
	if out:
		print("nope nope nope nope nope")
		player.spins = 0
		out = false
func _on_body_entered(body: Node2D) -> void:
	print("WHOA WHO?   ", body.name)
	if body.is_in_group("Player"):
		print("whoa")
		out = true
