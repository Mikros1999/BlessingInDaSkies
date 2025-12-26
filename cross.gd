extends RigidBody2D

@export var move_speed := 400.0
@export var deadzone := 0.15

@onready var swoosh_sound = $Audio/Swoosh
@onready var success_sound = $Audio/Success
@onready var failure_sound = $Audio/Failure


var priest_node: Node = null


var start_pos: Vector2

var frozen := false
var has_left_start := false


func _ready():
	start_pos = global_position
	linear_velocity = Vector2.ZERO


func _physics_process(delta):
	if frozen:
		linear_velocity = Vector2.ZERO
		return

	_move_with_left_stick()
	_rotate_with_right_stick()
	_clamp_to_screen()

	if not has_left_start and global_position.distance_to(start_pos) > 5.0:
		has_left_start = true
		_set_casting()

	if Input.is_action_just_pressed("shoot"):
		_try_cloud_interaction()


func _set_casting():
	swoosh_sound.play()
	if priest_node:
		priest_node.set_casting()

func _set_idle():
	if priest_node:
		priest_node.set_idle()



func freeze():
	frozen = true


func _move_with_left_stick():
	var move := Vector2(
		Input.get_joy_axis(0, 0),
		Input.get_joy_axis(0, 1)
	)

	if move.length() > deadzone:
		linear_velocity = move.normalized() * move_speed
	else:
		linear_velocity = Vector2.ZERO


func _rotate_with_right_stick():
	var aim := Vector2(
		Input.get_joy_axis(0, 2),
		Input.get_joy_axis(0, 3)
	)

	if aim.length() > 0.25:
		rotation = aim.angle()


func _try_cloud_interaction():
	var interacted := false

	for cloud in get_tree().get_nodes_in_group("cloud"):
		if cloud.try_interact():
			success_sound.play()
			_reset_to_start()
			interacted = true
			break

	if not interacted:
		failure_sound.play()



func _reset_to_start():
	global_position = start_pos
	linear_velocity = Vector2.ZERO
	has_left_start = false
	_set_idle()


func _clamp_to_screen():
	var screen = get_viewport_rect()
	var pos = global_position

	pos.x = clamp(pos.x, 0.0, screen.size.x)
	pos.y = clamp(pos.y, 0.0, screen.size.y * (2.0 / 3.0))

	global_position = pos
