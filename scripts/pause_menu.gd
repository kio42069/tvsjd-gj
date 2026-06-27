extends CanvasLayer
@onready var control_panel = $Control
@onready var difficulty_button = $Control/VBoxContainer/DifficultyButton
@onready var master_bus_index = AudioServer.get_bus_index("Master")

func _ready():
	control_panel.hide()
	
	# Populate the difficulty dropdown
	difficulty_button.add_item("Easy")
	difficulty_button.add_item("Medium")
	difficulty_button.add_item("Hard")
	difficulty_button.selected = 1 # Default to Medium

func _input(event):
	# Make sure you define "pause" in Project Settings -> Input Map (e.g., Escape key)
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	#print("testing")
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	control_panel.visible = is_paused

# Connected from the Resume Button
func _on_resume_button_pressed():
	toggle_pause()

# Connected from the OptionButton (Difficulty Dropdown)
func _on_difficulty_button_item_selected(index: int):
	#print("difffff")
	Management.set_difficulty(index)
	
	# OPTIONAL: If the boss is already live in the scene, 
	# you can find it and update it immediately:
	var boss = get_tree().get_first_node_in_group("Boss")
	if boss:

		boss.speed = Management.boss_speed
		boss.max_health = Management.boss_speed

# Connected from the HSlider (Volume)
func _on_volume_slider_value_changed(value: float):
	# Converts 0.0-1.0 slider value to Decibels naturally
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))
	
	# Mute the bus completely if the slider is dragged to the very bottom
	if value <= 0.0001:
		AudioServer.set_bus_mute(master_bus_index, true)
	else:
		AudioServer.set_bus_mute(master_bus_index, false)
