extends Node2D

@export var sprites: Array[Texture2D]   # 0, 1, 2

var state := 0

@onready var sprite := $LandSprite


func _ready():
	_apply_state()


func set_state(new_state: int):
	if new_state == state:
		return

	state = clamp(new_state, 0, 2)
	_apply_state()


func _apply_state():
	if sprites.size() > state:
		sprite.texture = sprites[state]
