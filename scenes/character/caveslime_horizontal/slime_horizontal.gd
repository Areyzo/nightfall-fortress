extends Path2D

@onready var path_follow = $PathFollow2D
var speed = 0.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if path_follow != null:
		path_follow.progress_ratio += delta * speed
