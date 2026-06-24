extends Area2D

@export var boss_node: CharacterBody2D 

func _on_body_entered(body: Node2D) -> void:
	#print("whoisin")
	if body.is_in_group("Player"): 
		#print("NOPERS")
		if boss_node and boss_node.has_method("activate_boss"):
			boss_node.activate_boss()
			
		# Delete the trigger area so it doesn't fire again
		queue_free()
