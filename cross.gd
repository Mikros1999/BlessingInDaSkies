extends RigidBody2D

@export var move_speed := 400.0
@export var deadzone := 0.15

var start_pos: Vector2

var frozen := false


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

	if Input.is_action_just_pressed("shoot"):
		_try_cloud_interaction()
		
		
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
	for cloud in get_tree().get_nodes_in_group("cloud"):
		if cloud.try_interact():
			_reset_to_start()
			break


func _reset_to_start():
	global_position = start_pos
	linear_velocity = Vector2.ZERO


func _clamp_to_screen():
	var screen = get_viewport_rect()
	var pos = global_position

	pos.x = clamp(pos.x, 0.0, screen.size.x)
	pos.y = clamp(pos.y, 0.0, screen.size.y * (2.0 / 3.0))

	global_position = pos
