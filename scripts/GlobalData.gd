extends Node

var should_load_save: bool = false
var save_data: Dictionary = {}

# Cave death handling
var died_in_cave = false
var respawn_in_main_world = false
var main_world_spawn_position = Vector2(370, 214)  # Default spawn position in main world

func get_save_data() -> Dictionary:
	if FileAccess.file_exists("user://savegame.json"):
		var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				save_data = json.data
				print("Save data loaded successfully")
				return save_data
			else:
				print("Error parsing save file")
	else:
		print("No save file found")
	
	return {}

func reset_cave_death_flags():
	"""Reset flags after handling cave death"""
	died_in_cave = false
	respawn_in_main_world = false
	print("Cave death flags reset")
