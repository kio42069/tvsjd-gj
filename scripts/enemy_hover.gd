extends CharacterBody2D

func die():
	queue_free()
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.name)
	die() # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
