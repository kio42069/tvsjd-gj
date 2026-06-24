extends CanvasLayer
@onready var hp_bar: TextureProgressBar = $BossHPBar

func _ready() -> void:
	# Hide the health bar automatically until the boss is actually engaged
	hide() 

func _on_boss_health_changed(new_hp: int) -> void:
	# You can animate this with a tween later for a smoother drop!
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", new_hp, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_boss_boss_activated(max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	print("hi")
	show() # Reveal the health bar when the fight starts


func _on_boss_boss_died() -> void:
	queue_free()
