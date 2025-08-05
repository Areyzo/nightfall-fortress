extends Node

func _ready():
	if get_tree().get_nodes_in_group("music").size() > 0:
		queue_free()
	else:
		add_to_group("music")
