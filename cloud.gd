extends Node2D

@export var speed: float = 80.0
@export var sprites: Array[Texture2D]
# sprites[0] -> cloud_state_0 ... sprites[3] -> cloud_state_3

var state := 0
var raining := false

@onready var sprite = $CloudSprite
@onready var rain_sprite = $RainSprite

func _ready():
	state = 0
	raining = false
	rain_sprite.visible = false
	sprite.texture = sprites[state]

func _process(delta):
	position.x += speed * delta
	
	# bounce when reaching screen edges
	var screen = get_viewport_rect()
	if position.x > screen.size.x:
		speed *= -1
	elif position.x < 0:
		speed *= -1

func hit():
	if state < 3:
		state += 1
		sprite.texture = sprites[state]
	
	if state == 3 and not raining:
		raining = true
		rain_sprite.visible = true
