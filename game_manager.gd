extends Node2D

@export var land: NodePath
@export var threshold_state_1 := 3
@export var threshold_state_2 := 6

@onready var land_node = get_node(land)

@onready var main_menu = $UI/MainMenu
@onready var game_hud = $UI/GameHUD
@onready var end_menu = $UI/EndMenu

@onready var timer_label = $UI/GameHUD/TimerLabel
@onready var result_label = $UI/EndMenu/ResultLabel

@onready var cloud_spawner = $CloudSpawner

@onready var intro_music = $Audio/IntroMusic
@onready var game_music = $Audio/GameMusic
@onready var end_music = $Audio/EndMusic


const GAME_TIME := 100.0
var time_left := GAME_TIME
var game_over := false


func _ready():
	_show_main_menu()

func _show_main_menu():
	main_menu.visible = true
	game_hud.visible = false
	end_menu.visible = false
	game_over = true


func _start_game():
	main_menu.visible = false
	game_hud.visible = true
	end_menu.visible = false
	game_over = false

	# reset game state cleanly
	time_left = GAME_TIME
	result_label.visible = false


func _input(event):
	if not game_over:
		return

	if event.is_action_pressed("reset"):
		_restart_game()


func _restart_game():
	get_tree().reload_current_scene()


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
	end_menu.visible = true
	game_hud.visible = false
	main_menu.visible = false
	end_menu.get_node("ResultLabel").text = "THE LAND IS BLESSED"


func _lose_game():
	game_over = true
	end_menu.visible = true
	game_hud.visible = false
	main_menu.visible = false
	end_menu.get_node("ResultLabel").text = "THE LAND REMAINS DRY"


func _quit_game() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	_start_game()


func _on_restart_button_pressed() -> void:
	_restart_game()


func _on_main_menu_button_pressed() -> void:
	_show_main_menu()


func _on_quit_button_pressed() -> void:
	_quit_game()
