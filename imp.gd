extends Node2D

@export var speed_min := 150.0
@export var speed_max := 250.0
@export var steal_speed_multiplier := 2.5

var speed: float
var direction: int   # -1 = left, +1 = right

var stealing := false

@onready var hit_area := $HitArea
@onready var sprite := $AnimatedSprite2D
@onready var laugh_sound = $Audio/Laugh


func _ready():
	speed = randf_range(speed_min, speed_max)
	hit_area.body_entered.connect(_on_body_entered)
	sprite.flip_h = direction == 1


func _process(delta):
	if stealing:
		# fly up faster while stealing
		position.y -= speed * steal_speed_multiplier * delta
	else:
		position.x += direction * speed * delta

	var screen = get_viewport_rect()

	# normal despawn (horizontal)
	if not stealing:
		if direction == 1 and position.x > screen.size.x + 60:
			queue_free()
		elif direction == -1 and position.x < -60:
			queue_free()

	# steal despawn (vertical)
	else:
		if position.y < -60:
			queue_free()


func _on_body_entered(body):
	if stealing:
		return

	if body.is_in_group("cross"):
		stealing = true
		laugh_sound.play()
		body.steal(self)
