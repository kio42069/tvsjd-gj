extends Node

var boss_speed: int = 200
var boss_health: float = 200

const SPEED_EASY = 100
const SPEED_MEDIUM = 200
const SPEED_HARD = 300

func set_difficulty(index: int):
	print("difficulty set")
	match index:
		0: boss_speed = SPEED_EASY
		1: boss_speed = SPEED_MEDIUM
		2: boss_speed = SPEED_HARD
