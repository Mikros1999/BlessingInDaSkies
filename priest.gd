extends Node2D

@export var cross_scene: PackedScene

@onready var hand = $HandMarker

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		var cross = cross_scene.instantiate()
		cross.position = hand.global_position
		get_tree().current_scene.add_child(cross)
