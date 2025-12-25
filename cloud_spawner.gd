extends Node2D

@export var cloud_scene: PackedScene
@export var spawn_interval := 2.5

var timer := 0.0


func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_cloud()


func spawn_cloud():
	var cloud = cloud_scene.instantiate()
	var screen = get_viewport_rect()

	var spawn_left := randf() < 0.5

	if spawn_left:
		cloud.position.x = -50
		cloud.direction = 1
	else:
		cloud.position.x = screen.size.x + 50
		cloud.direction = -1

	var y_min: float = 40.0
	var y_max: float = screen.size.y * (2.0 / 3.0)

	cloud.position.y = randf_range(y_min, y_max)

	add_child(cloud)



#extends Node2D
#
#@export var cloud_scene: PackedScene
#@export var spawn_interval := 2.5
#
#var timer := 0.0
#
#func _process(delta):
	#timer += delta
	#if timer >= spawn_interval:
		#timer = 0.0
		#spawn_cloud()
#
#func spawn_cloud():
	#var cloud = cloud_scene.instantiate()
	#var screen = get_viewport_rect()
	#
	#cloud.position = Vector2(
		#-50,                                  # start offscreen left
		#randf_range(50, screen.size.y - 100)
	#)
	#add_child(cloud)
