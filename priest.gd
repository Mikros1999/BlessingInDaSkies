extends Node2D

@export var cross_scene: PackedScene
@onready var hand = $HandMarker
@onready var sprite := $PriestSprite
@export var sprite_idle: Texture2D   # sprite0
@export var sprite_casting: Texture2D  # sprite1

var cross = null

func _ready():
	_spawn_cross()
	set_idle()


func set_idle():
	sprite.texture = sprite_idle


func set_casting():
	sprite.texture = sprite_casting


func _spawn_cross():
	if cross == null:
		cross = cross_scene.instantiate()
		cross.global_position = hand.global_position

		# 🔗 assign priest reference
		cross.priest_node = self

		get_tree().current_scene.call_deferred("add_child", cross)
