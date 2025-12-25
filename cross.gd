extends RigidBody2D

@export var move_speed := 400.0
@export var deadzone := 0.15

var start_pos: Vector2

func _ready():
	start_pos = global_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0

func _physics_process(delta):
	_move_with_left_stick()
	_rotate_with_right_stick()
	_clamp_to_screen()

func _move_with_left_stick():
	var lx = Input.get_joy_axis(0, 0)   # Left stick X
	var ly = Input.get_joy_axis(0, 1)   # Left stick Y
	var move = Vector2(lx, ly)

	if move.length() > deadzone:
		linear_velocity = move.normalized() * move_speed
	else:
		linear_velocity = Vector2.ZERO

func _rotate_with_right_stick():
	var rx = Input.get_joy_axis(0, 2)   # Right stick X
	var ry = Input.get_joy_axis(0, 3)   # Right stick Y
	var aim = Vector2(rx, ry)

	# Only rotate if the stick is intentionally pushed
	if aim.length() > 0.25:
		rotation = aim.angle()

func _clamp_to_screen():
	var screen = get_viewport_rect()
	var pos = global_position

	# clamp to screen edges
	pos.x = clamp(pos.x, 0.0, screen.size.x)

	# top to 2/3 screen height (blocks lower third)
	var max_y = screen.size.y * (2.1 / 3.0)
	pos.y = clamp(pos.y, 0.0, max_y)

	global_position = pos

func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit()
	_reset_to_start()

func _reset_to_start():
	global_position = start_pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
