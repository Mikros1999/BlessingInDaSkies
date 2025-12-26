extends Node2D

@export var cloud_scene: PackedScene
@export var spawn_interval := 2.5
@export var max_clouds := 6

var active := false

var timer := 0.0

func _process(delta):
	if not active:
		return

	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_cloud()
		
func start():
	active = true

func stop():
	active = false

#func set_active(value: bool):
	#active = value

func spawn_cloud():
	var clouds := get_tree().get_nodes_in_group("cloud")
	if clouds.size() >= max_clouds:
		return   # hard limit reached

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
