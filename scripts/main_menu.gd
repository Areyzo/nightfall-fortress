extends Control

@onready var options_popup = $OptionsPopup
@onready var volume_slider = $OptionsPopup/OptionsPanel/VBoxContainer/VolumeContainer/VolumeSlider
@onready var volume_label = $OptionsPopup/OptionsPanel/VBoxContainer/VolumeContainer/VolumeLabel
@onready var mute_button = $OptionsPopup/OptionsPanel/VBoxContainer/MuteButton

var master_volume: float = 1.0
var is_muted: bool = false

func _ready():
	# Load saved audio settings
	load_audio_settings()

func _on_play_pressed() -> void:
	print("=== PLAY BUTTON PRESSED ===")
	print("Attempting to change scene to: res://scenes/test/testscenes_tilemap.tscn")
	
	# Check if the scene file exists
	if ResourceLoader.exists("res://scenes/test/testscenes_tilemap.tscn"):
		print("Scene file exists, changing scene...")
		
		# Try to preload the scene first to check for errors
		var scene_resource = load("res://scenes/test/testscenes_tilemap.tscn")
		if scene_resource == null:
			print("ERROR: Failed to load scene resource!")
			print("Trying alternative scene: res://scenes/test/test_world.tscn")
			if ResourceLoader.exists("res://scenes/test/test_world.tscn"):
				get_tree().change_scene_to_file("res://scenes/test/test_world.tscn")
			return
		else:
			print("Scene resource loaded successfully")
		
		# Try the actual scene change
		var result = get_tree().change_scene_to_file("res://scenes/test/testscenes_tilemap.tscn")
		print("Scene change result: ", result)
	else:
		print("ERROR: Scene file does not exist!")


func _on_host_pressed() -> void:
	print("=== HOST BUTTON PRESSED ===")
	# Add your host game logic here
	pass # Replace with host functionality


func _on_join_pressed() -> void:
	print("=== JOIN BUTTON PRESSED ===")
	# Add your join game logic here
	pass # Replace with join functionality
func _on_options_pressed() -> void:
	options_popup.visible = true
	print("Options menu opened")

func _on_close_button_pressed() -> void:
	close_options()

func _on_close_x_pressed() -> void:
	close_options()

func close_options():
	options_popup.visible = false
	save_audio_settings()
	print("Options menu closed")

func _on_volume_slider_value_changed(value: float) -> void:
	master_volume = value / 100.0
	volume_label.text = str(int(value)) + "%"
	
	if not is_muted:
		set_master_volume(master_volume)
	
	print("Volume changed to: ", int(value), "%")

func _on_mute_button_toggled(button_pressed: bool) -> void:
	is_muted = button_pressed
	
	if is_muted:
		set_master_volume(0.0)
		volume_slider.editable = false
		volume_label.text = "MUTED"
		print("Audio muted")
	else:
		set_master_volume(master_volume)
		volume_slider.editable = true
		volume_label.text = str(int(volume_slider.value)) + "%"
		print("Audio unmuted")

func set_master_volume(volume: float):
	# Set the master audio bus volume
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(volume))

func save_audio_settings():
	# Save settings to a simple config file
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "is_muted", is_muted)
	config.save("user://audio_settings.cfg")
	print("Audio settings saved")

func load_audio_settings():
	# Load settings from config file
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		is_muted = config.get_value("audio", "is_muted", false)
		
		# Update UI elements
		volume_slider.value = master_volume * 100
		mute_button.button_pressed = is_muted
		
		# Apply settings
		if is_muted:
			set_master_volume(0.0)
			volume_slider.editable = false
			volume_label.text = "MUTED"
		else:
			set_master_volume(master_volume)
			volume_label.text = str(int(master_volume * 100)) + "%"
		
		print("Audio settings loaded")
	else:
		print("No saved audio settings found, using defaults")

func _on_exit_pressed() -> void:
	print("=== EXIT BUTTON PRESSED ===")
	get_tree().quit()
