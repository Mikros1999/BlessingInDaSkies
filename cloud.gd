extends Node2D

@export var speed_min := 60.0
@export var speed_max := 140.0
@export var sprites: Array[Texture2D]

var speed: float
var direction: int
var state := 0
var raining := false
var has_entered := false

var cross_inside := false

@onready var sprite := $CloudSprite
@onready var rain_sprite := $RainSprite
@onready var hit_area := $HitArea


func _ready():
	speed = randf_range(speed_min, speed_max)
	rain_sprite.visible = false
	_apply_state()

	hit_area.body_entered.connect(_on_body_entered)
	hit_area.body_exited.connect(_on_body_exited)


func _process(delta):
	position.x += direction * speed * delta

	var screen_width := get_viewport_rect().size.x

	if not has_entered:
		if position.x >= 0 and position.x <= screen_width:
			has_entered = true
		return

	if position.x <= 0:
		direction = 1
	elif position.x >= screen_width:
		direction = -1


func _on_body_entered(body):
	if body.is_in_group("cross"):
		cross_inside = true


func _on_body_exited(body):
	if body.is_in_group("cross"):
		cross_inside = false


func try_interact() -> bool:
	if cross_inside:
		_advance_state()
		return true
	return false


func _advance_state():
	if state < 3:
		state += 1
		_apply_state()

	if state == 3 and not raining:
		raining = true
		rain_sprite.visible = true


func _apply_state():
	if sprites.size() > state:
		sprite.texture = sprites[state]
