extends Node2D

@export var cross_scene: PackedScene
@onready var hand = $HandMarker

var cross = null

func _ready():
	_spawn_cross()


func _spawn_cross():
	if cross == null:
		cross = cross_scene.instantiate()
		cross.global_position = hand.global_position
		get_tree().current_scene.call_deferred("add_child", cross)
