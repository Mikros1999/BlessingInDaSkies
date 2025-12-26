extends Node2D

@export var land: NodePath
@export var threshold_state_1 := 3
@export var threshold_state_2 := 6

@onready var land_node = get_node(land)
@onready var timer_label = $UI/TimerLabel
@onready var result_label = $UI/ResultLabel
@onready var cloud_spawner = $CloudSpawner


const GAME_TIME := 10.0
var time_left := GAME_TIME
var game_over := false


func _ready():
	result_label.visible = false


func _process(delta):
	if game_over:
		return

	# timer
	time_left -= delta
	timer_label.text = "Time: %.0f" % time_left

	if time_left <= 0:
		_lose_game()
		return

	# game logic
	var raining_count := _count_raining_clouds()
	_update_land_state(raining_count)


func _count_raining_clouds() -> int:
	var count := 0
	for cloud in get_tree().get_nodes_in_group("cloud"):
		if cloud.raining:
			count += 1
	return count


func _update_land_state(raining_count: int):
	if raining_count >= threshold_state_2:
		land_node.set_state(2)
		_win_game()
	elif raining_count >= threshold_state_1:
		land_node.set_state(1)
	else:
		land_node.set_state(0)


func _freeze_cross():
	var crosses = get_tree().get_nodes_in_group("cross")
	if crosses.size() > 0:
		crosses[0].freeze()


func _win_game():
	game_over = true
	_freeze_cross()
	result_label.text = "!!! YOU BLESSED ENOUGH RAINS IN AFRICA !!!"
	result_label.visible = true
	set_process(false)


func _lose_game():
	game_over = true
	_freeze_cross()
	result_label.text = "YOU LOSE - BLESS FASTER NEXT TIME"
	result_label.visible = true
	set_process(false)
