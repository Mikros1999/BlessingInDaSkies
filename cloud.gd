extends Node2D

@export var speed_min := 60.0
@export var speed_max := 140.0
@export var sprites: Array[Texture2D]

var speed: float
var direction: int            # -1 = left, +1 = right
var state := 0
var raining := false

var has_entered := false

@onready var sprite := $CrossSprite
@onready var rain_sprite := $RainSprite


func _ready():
	speed = randf_range(speed_min, speed_max)
	rain_sprite.visible = false
	_apply_state()


func _process(delta):
	position.x += direction * speed * delta

	var screen_width := get_viewport_rect().size.x

	# PHASE 1 — entering screen (NO bouncing)
	if not has_entered:
		if position.x >= 0 and position.x <= screen_width:
			has_entered = true
		return

	# PHASE 2 — bounce forever
	if position.x <= 0:
		direction = 1
	elif position.x >= screen_width:
		direction = -1


func hit():
	if state < 3:
		state += 1
		_apply_state()

	if state == 3 and not raining:
		raining = true
		rain_sprite.visible = true


func _apply_state():
	if sprites.size() > state:
		sprite.texture = sprites[0]
