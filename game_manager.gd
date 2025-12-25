extends Node2D

const GAME_TIME := 10.0   # 2 minutes
var time_left := GAME_TIME

@onready var timer_label = $UI/TimerLabel
@onready var result_label = $UI/ResultLabel

func _ready():
	result_label.visible = false

func _process(delta):
	time_left -= delta
	timer_label.text = "Time: %.0f" % time_left
	
	if time_left <= 0:
		end_game()

func end_game():
	var raining = 0
	for c in get_tree().get_nodes_in_group("cloud"):
		continue
		#if c.raining:
			#raining += 1
	
	if raining > 3:
		result_label.text = "YOU WIN — clouds with rain: %d" % raining
	else:
		result_label.text = "YOU LOSE — clouds with rain: %d" % raining
	
	result_label.visible = true
	set_process(false)
