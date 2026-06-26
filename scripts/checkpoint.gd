extends Sprite2D

var is_activated:bool = false

func _ready() -> void:
	frame = 1
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func fade_in():
	var active_overlay = Sprite2D.new()
	active_overlay.texture = texture
	active_overlay.hframes = hframes
	active_overlay.vframes = vframes
	active_overlay.region_enabled = region_enabled
	active_overlay.region_rect = region_rect
	active_overlay.frame = 0
	active_overlay.modulate.a = 0.0
	
	add_child(active_overlay)
	
	var tween = create_tween()
	audio_stream_player_2d.play()
	tween.tween_property(active_overlay, "modulate:a", 1.0, 1.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_activated and body.is_in_group("Player"):
		is_activated = true
		body.last_checkpoint = global_position
		fade_in()
