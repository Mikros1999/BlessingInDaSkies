extends Node2D

@export var imp_scene: PackedScene
@export var spawn_interval := 10.0
@export var max_imps := 2

var timer := 0.0


func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_imp()


func spawn_imp():
	# limit active imps
	var imps := get_tree().get_nodes_in_group("imp")
	if imps.size() >= max_imps:
		return

	var imp = imp_scene.instantiate()
	var screen = get_viewport_rect()

	var spawn_left := randf() < 0.5

	if spawn_left:
		imp.position.x = -60
		imp.direction = 1
	else:
		imp.position.x = screen.size.x + 60
		imp.direction = -1

	# upper half only
	var y_min: float = 40.0
	var y_max: float = screen.size.y * 0.5
	imp.position.y = randf_range(y_min, y_max)

	add_child(imp)
