extends CharacterBody2D

@export var move_speed := 400.0
@export var deadzone := 0.15
@export var spin_speed := 6.0   # radians per second

@onready var swoosh_sound = $Audio/Swoosh
@onready var success_sound = $Audio/Success
@onready var failure_sound = $Audio/Failure

var priest_node: Node = null

var frozen := true
var has_left_start := false
var stolen := false

var attached_to: Node2D = null


func _ready():
	velocity = Vector2.ZERO


func _physics_process(delta):
	# stolen state: follow imp OR release safely
	if stolen:
		if attached_to and is_instance_valid(attached_to):
			global_position = attached_to.global_position
		else:
			_release_after_steal()
		return
	
	if frozen:
		velocity = Vector2.ZERO
		return

	_move_with_left_stick()
	#_rotate_with_right_stick()

	_apply_spin(delta)
	move_and_slide()

	_clamp_to_screen()

	if not has_left_start and priest_node:
		if global_position.distance_to(priest_node.hand.global_position) > 5.0:
			has_left_start = true
			_set_casting()

	if Input.is_action_just_pressed("shoot"):
		_try_cloud_interaction()


func _release_after_steal():
	stolen = false
	attached_to = null
	_reset_to_start()	


func _reset_to_start():
	if priest_node:
		global_position = priest_node.hand.global_position
	else:
		global_position = global_position  # fallback, should never happen
	
	velocity = Vector2.ZERO
	rotation = 0.0
	has_left_start = false
	_set_idle()
	
	print("RESET TO:", global_position)


func _set_casting():
	swoosh_sound.play()
	if priest_node:
		priest_node.set_casting()


func _set_idle():
	if priest_node:
		priest_node.set_idle()


func freeze():
	frozen = true
	
	
func set_enabled(value: bool):
	frozen = not value


func steal(by_node: Node2D):
	stolen = true
	rotation = 0.0
	attached_to = by_node
	velocity = Vector2.ZERO


func _move_with_left_stick():
	var move := Vector2(
		Input.get_joy_axis(0, 0),
		Input.get_joy_axis(0, 1)
	)

	if move.length() < deadzone:
		velocity = Vector2.ZERO
		return

	velocity = move.normalized() * move_speed


func _apply_spin(delta):
	if not has_left_start:
		return

	rotation += spin_speed * delta


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


func _clamp_to_screen():
	if priest_node and global_position == priest_node.hand.global_position:
		return   # NEVER clamp hand position

	#if stolen or not has_left_start:
		#return
	
	var screen = get_viewport_rect()
	var pos = global_position

	pos.x = clamp(pos.x, 0.0, screen.size.x)
	pos.y = clamp(pos.y, 0.0, screen.size.y * (2.0 / 3.0))

	global_position = pos
	
	print("RESET TO:", pos)
