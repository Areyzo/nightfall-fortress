extends Node

var world_scene = load("res://scenes/test/testscenes_tilemap.tscn")
var lobby_scene = load("res://scenes/test/test_world.tscn")  # safer than preload for debugging

func go_to_level(destination_level_tag: String):
	print("go_to_level function is called — changing scene to:", destination_level_tag)
	call_deferred("_deferred_change_scene", destination_level_tag)

func _deferred_change_scene(destination_level_tag: String):
	print("Loading scene for tag:", destination_level_tag)

	var scene_to_load: PackedScene = null

	match destination_level_tag:
		"lobby":
			print("Trying to load lobby_scene")
			scene_to_load = lobby_scene
		"world":
			print("Trying to load world_scene")
			scene_to_load = world_scene
		_:
			print("Unknown tag:", destination_level_tag)
			return

	if scene_to_load and scene_to_load is PackedScene:
		print("Scene loaded, changing scene now")
		get_tree().change_scene_to_packed(scene_to_load)
	else:
		print("Scene failed to load or is not a PackedScene")
