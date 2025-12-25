extends RigidBody2D

@export var move_force := 200.0
@export var rotate_force := 3.0

func _ready():
	linear_velocity = Vector2(500, -500)   # 45° upward-right
	rotation = deg_to_rad(-45)

func _physics_process(delta):
	var input_vec = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	# “struggle” rotation — small torque feel
	if input_vec.x != 0:
		rotation += input_vec.x * rotate_force * delta
	
	# push in facing direction (not precise, intentionally clumsy)
	if input_vec.length() > 0.1:
		var dir = Vector2.RIGHT.rotated(rotation)
		apply_central_force(dir * move_force * delta)

func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit()
	queue_free()
