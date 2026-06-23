extends CanvasLayer
@export var player: CharacterBody2D
@export var label: Label

func _process(_delta: float) -> void:
	if player:
		label.text = str(player.spins) + " spins left"
		if player.spins < 50:
			label.add_theme_color_override("font_color", Color(45.983, 0.0, 0.0, 1.0)) 
		elif player.spins < 100:
			label.add_theme_color_override("font_color", Color(1.0, 0.568, 0.188, 1.0))
		else:
			label.add_theme_color_override("font_color", Color(0.43, 1.0, 0.0, 1.0))
		if player.spins > 500:
			label.add_theme_color_override("font_color", Color(0.631, 0.379, 1.0, 1.0))
			var custom_font = load("res://assets/fonts/PixelOperator8.ttf")
			label.add_theme_font_override("font", custom_font)
