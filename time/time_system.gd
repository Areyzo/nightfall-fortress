class_name TimeSystem extends Node

@export var date_time: DateTime
@export var ticks_pr_sec: int =4

func _process(delta: float) -> void:
	if date_time != null:
		date_time.increase_by_sec(delta * ticks_pr_sec)
	
