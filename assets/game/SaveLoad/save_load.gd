extends Control

func Save() -> void:
	var config = ConfigFile.new()
	config.set_value("title","data index ","data")
	config.save("user://SaveFile.cfg")
	print("saved")

func Load() -> void:
	var config = ConfigFile.new()
	var result = config.load("user://SaveFile.cfg")
	if result == OK:
		#set data in variables
		pass

func _on_save_pressed() -> void:
	Save()
