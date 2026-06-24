extends Area2D

@export var boss_node: CharacterBody2D 
@export var boss_walls: TileMapLayer 

## Drag and drop your ArenaCenter Marker2D node here
@export var arena_center: Marker2D
## How far out the camera zooms to fit the whole arena (Lower values = zoomed further out)
@export var arena_zoom: Vector2 = Vector2(0.9, 0.9)

var original_wall_collision: int
var player_camera: Camera2D

var original_physics_layers: Dictionary = {}

func _ready() -> void:
	# Hide boss and walls
	if boss_node:
		boss_node.modulate.a = 0.0
	if boss_walls:
		boss_walls.modulate.a = 0.0
		boss_walls.collision_enabled = false
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		set_deferred("monitoring", false)
		
		# Automatically locate the Camera2D attached to your player
		player_camera = body.find_child("Camera2D") as Camera2D
		
		# OPTIONAL: If your player script has an input lock, trigger it here:
		# if body.has_method("lock_input"): body.lock_input()
		
		start_boss_intro()

func start_boss_intro() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. Fade in the boss and walls
	if boss_node:
		tween.tween_property(boss_node, "modulate:a", 1.0, 3)
	if boss_walls:
		tween.tween_property(boss_walls, "modulate:a", 1.0, 3)
		
	# 2. Detach camera from player and smoothly track up to the floating boss
	if player_camera and boss_node:
		player_camera.top_level = true # Camera ignores player movement from this point forward
		tween.tween_property(player_camera, "global_position", boss_node.global_position, 1.5)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			
	# Wait for the fade-in and tracking step to finish
	tween.set_parallel(false)
	tween.tween_callback(pan_out_to_arena)

func pan_out_to_arena() -> void:
	# Turn physical barriers back on
	if boss_walls:
		boss_walls.collision_enabled = true
		
	# Awaken the boss AI
	if boss_node and boss_node.has_method("activate_boss"):
		boss_node.activate_boss()
		
	# 3. Pan and zoom out to display the entire arena bounds
	if player_camera and arena_center:
		var pan_tween = create_tween()
		pan_tween.set_parallel(true)
		
		# Move to center frame
		pan_tween.tween_property(player_camera, "global_position", arena_center.global_position, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		# Scale down the zoom value to see the wider structure
		pan_tween.tween_property(player_camera, "zoom", arena_zoom, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			
		# Keep trigger alive until camera finishes movement, then delete it
		pan_tween.set_parallel(false)
		pan_tween.tween_callback(queue_free)
	else:
		queue_free()
