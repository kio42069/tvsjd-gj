extends Label

var time_elapsed: float = 0.0

var is_over: bool = false

func _process(delta: float) -> void:
	if not is_over:
		var unscaled_delta: float = 0.001
		if Engine.time_scale > 0.0:
			unscaled_delta = delta / Engine.time_scale
		time_elapsed += unscaled_delta
		text = format_time(time_elapsed)
	

func format_time(time:float):
	var minutes := int(time) / 60
	var seconds := int(time) % 60
	var miliseconds := int((time - int(time))*100)
	return "Time: %02d:%02d:%02d" % [minutes, seconds, miliseconds]


func _on_boss_boss_died() -> void:
	is_over = true
