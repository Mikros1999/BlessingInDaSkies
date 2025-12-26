extends Node2D

@export var speed_min := 150.0
@export var speed_max := 250.0

var speed: float
var direction: int   # -1 = left, +1 = right

@onready var hit_area := $HitArea
@onready var sprite := $AnimatedSprite2D


func _ready():
	speed = randf_range(speed_min, speed_max)
	hit_area.body_entered.connect(_on_body_entered)
	sprite.flip_h = direction == 1


func _process(delta):
	position.x += direction * speed * delta

	var screen_width := get_viewport_rect().size.x

	# despawn once fully outside
	if direction == 1 and position.x > screen_width + 50:
		queue_free()
	elif direction == -1 and position.x < -50:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("cross"):
		if body.has_method("_reset_to_start"):
			body._reset_to_start()
