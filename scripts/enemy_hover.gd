extends CharacterBody2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.name)
	audio_stream_player_2d.play()
	queue_free()
