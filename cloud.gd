extends Node2D

@export var speed_min := 50.0
@export var speed_max := 150.0
@export var sprites: Array[Texture2D]

@export var speed_state_1_mult := 2
@export var speed_state_2_mult := 3
@export var speed_state_3_mult := 0.7   # slow when raining

var base_speed: float
var speed: float
var direction: int
var state := 0
var raining := false
var has_entered := false
var cross_inside := false

@onready var sprite := $CloudSprite
@onready var rain_sprite := $RainSprite
@onready var hit_area := $HitArea

@onready var max_state_sound = $Audio/MaxState


func _ready():
	base_speed = randf_range(speed_min, speed_max)
	_recalculate_speed()
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


# 👉 returns TRUE only if interaction was successful
func try_interact() -> bool:
	if not cross_inside:
		return false

	if state >= 3:
		return false   # max state: ignore interaction

	_advance_state()
	return true


func _advance_state():
	state += 1
	_apply_state()
	_recalculate_speed()

	if state == 3:
		raining = true
		rain_sprite.visible = true
		max_state_sound.play()


func _recalculate_speed():
	match state:
		0:
			speed = base_speed
		1:
			speed = base_speed * speed_state_1_mult
		2:
			speed = base_speed * speed_state_2_mult
		3:
			speed = base_speed * speed_state_3_mult


func _apply_state():
	if sprites.size() <= state:
		push_warning("Cloud sprites array missing state %d" % state)
		return

	sprite.texture = sprites[state]
