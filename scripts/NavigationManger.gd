extends Node

var world_scene=preload("res://scenes/test/testscenes_tilemap.tscn")
var lobby_scene=preload("res://scenes/test/test_world.tscn")

func go_to_level(destination_level_tag):
	print("go_to_level function is called now the main changes will happen")
	call_deferred("_defered_change_scene",destination_level_tag)
	
func _defered_change_scene(destination_level_tag):
	var scene_to_load
	match destination_level_tag:
		"lobby":
			scene_to_load=lobby_scene
		"world":
			scene_to_load=world_scene
	print("Scene to load:", scene_to_load)
	print("PackedScene valid?", scene_to_load != null)

	if scene_to_load!=null:
		get_tree().change_scene_to_packed(scene_to_load)
	
