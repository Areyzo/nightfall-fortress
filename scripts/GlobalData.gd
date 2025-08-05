extends Node

var should_load_save: bool = false
var save_data: Dictionary = {}

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
