extends Node2D

@export var land: NodePath
@export var threshold_state_1 := 5
@export var threshold_state_2 := 10

@onready var land_node = get_node(land)

@onready var cloud_spawner = $CloudSpawner
@onready var imp_spawner = $ImpSpawner

@onready var main_menu = $UI/MainMenu
@onready var game_hud = $UI/GameHUD
@onready var end_menu = $UI/EndMenu

@onready var timer_label = $UI/GameHUD/TimerLabel
@onready var result_label = $UI/EndMenu/ResultLabel

@onready var intro_music = $Audio/IntroMusic
@onready var game_music = $Audio/GameMusic
@onready var win_end_music = $Audio/WinEndMusic
@onready var fail_end_music = $Audio/FailEndMusic

@onready var start_button = $UI/MainMenu/StartButton
@onready var restart_button = $UI/EndMenu/RestartButton

enum GameState {
	MENU,
	PLAYING,
	ENDED
}

var game_state: GameState = GameState.MENU

const GAME_TIME := 90.0
var time_left := GAME_TIME
var game_over := false


func _ready():
	enter_menu()

func enter_menu():
	game_state = GameState.MENU

	# UI
	main_menu.visible = true
	game_hud.visible = false
	end_menu.visible = false

	# Audio
	win_end_music.stop()
	fail_end_music.stop()
	game_music.stop()
	if not intro_music.playing:
		intro_music.play()

	start_button.grab_focus()
	
	# Stop gameplay systems
	_freeze_cross()
	_stop_spawners()
	_clear_dynamic_entities()


func start_game():
	game_state = GameState.PLAYING

	# UI
	main_menu.visible = false
	game_hud.visible = true
	end_menu.visible = false

	# Reset game data
	time_left = GAME_TIME

	# Audio
	intro_music.stop()
	win_end_music.stop()
	fail_end_music.stop()
	game_music.play()

	# Enable gameplay
	_unfreeze_cross()
	_start_spawners()


func end_game(end_condition: bool):
	game_state = GameState.ENDED

	# UI
	main_menu.visible = false
	game_hud.visible = false
	end_menu.visible = true
	# Audio
	game_music.stop()
	
	if end_condition: 
		_win_game() 
	else: 
		_lose_game()

	restart_button.grab_focus()
	
	# Stop gameplay systems and cleanup
	_freeze_cross()
	_stop_spawners()
	_clear_dynamic_entities()


func _start_spawners():
	cloud_spawner.start()
	imp_spawner.start()

func _stop_spawners():
	cloud_spawner.stop()
	imp_spawner.stop()

func _freeze_cross():
	var crosses = get_tree().get_nodes_in_group("cross")
	if crosses.size() > 0:
		crosses[0].set_enabled(false)

func _unfreeze_cross():
	var crosses = get_tree().get_nodes_in_group("cross")
	if crosses.size() > 0:
		crosses[0].set_enabled(true)


func _process(delta):
	if game_state != GameState.PLAYING:
		return

	time_left -= delta
	timer_label.text = "Time:   %.0f" % time_left

	if time_left <= 0:
		end_game(false)
		return

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
		end_game(true)
	elif raining_count >= threshold_state_1:
		land_node.set_state(1)
	else:
		land_node.set_state(0)


func _clear_dynamic_entities():
	for cloud in get_tree().get_nodes_in_group("cloud"):
		if is_instance_valid(cloud):
			cloud.queue_free()

	for imp in get_tree().get_nodes_in_group("imp"):
		if is_instance_valid(imp):
			imp.queue_free()


func _win_game():
	end_menu.get_node("ResultLabel").text = "THY   LAND   IS   BLESSED"
	win_end_music.play()


func _lose_game():
	end_menu.get_node("ResultLabel").text = "LAND   REMAINS   DRY  :("
	fail_end_music.play()


func _input(event):
	# ignore all gameplay shortcuts while in main menu
	if game_state == GameState.MENU:
		return

	if event.is_action_pressed("restart_game"):
		end_game(false)
		start_game()
		return

	if event.is_action_pressed("go_to_menu"):
		enter_menu()
		return


func _restart_game():
	#get_tree().reload_current_scene()
	start_game()


func _quit_game() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	start_game()


func _on_restart_button_pressed() -> void:
	_restart_game()


func _on_main_menu_button_pressed() -> void:
	enter_menu()


func _on_quit_button_pressed() -> void:
	_quit_game()
