extends Control


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


func _on_exit_pressed() -> void:
	print("=== EXIT BUTTON PRESSED ===")
	get_tree().quit()
