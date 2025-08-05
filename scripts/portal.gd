extends Area2D

@export var destination_level_tag: String

func _ready():
	# Check if signal is already connected before connecting
	if not body_entered.is_connected(_on_body_entered):
		connect("body_entered", _on_body_entered)
	print("Portal ready with destination: ", destination_level_tag)

func _on_body_entered(body: Node2D) -> void:
	print("Something entered portal: ", body.name)
	
	# Check if it's the player using multiple methods
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		print("Player detected! Saving game before teleportation...")
		
		# Save the current game state before teleporting
		save_current_game_state()
		
		print("Teleporting to: ", destination_level_tag)
		
		# Check if NavigationManger exists (note the typo in the original)
		if has_node("/root/NavigationManger"):
			get_node("/root/NavigationManger").go_to_level(destination_level_tag)
		elif has_node("/root/NavigationManager"):  # In case it gets fixed
			get_node("/root/NavigationManager").go_to_level(destination_level_tag)
		else:
			print("NavigationManger not found! Cannot teleport.")
			# Fallback - try to change scene directly
			if destination_level_tag == "lobby":
				get_tree().change_scene_to_file("res://scenes/test/test_world.tscn")
			elif destination_level_tag == "world":
				get_tree().change_scene_to_file("res://scenes/test/testscenes_tilemap.tscn")
			else:
				print("Unknown destination: ", destination_level_tag)
	else:
		print("Non-player body detected: ", body.name)

func save_current_game_state():
	# Find the player in the current scene
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Player not found for saving!")
		return
	
	# Don't save if player is dead or has no health
	if "current_health" in player and player.current_health <= 0:
		print("Portal: Player is dead - not saving game state")
		return
	
	var save_data = {}
	
	# Save player position
	save_data["player_position"] = {
		"x": player.global_position.x,
		"y": player.global_position.y
	}
	
	# Save inventory data
	if player.inventory and player.inventory.slots:
		var inventory_data = []
		for i in range(player.inventory.slots.size()):
			var slot = player.inventory.slots[i]
			if slot and slot.item:
				inventory_data.append({
					"index": i,
					"item_name": slot.item.name,
					"amount": slot.amount
				})
		save_data["inventory"] = inventory_data
		print("Portal: Saved ", inventory_data.size(), " inventory items")
	
	# Save timestamp
	save_data["timestamp"] = Time.get_unix_time_from_system()
	
	# Write to save file
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("Portal: Game saved successfully before teleportation!")
	else:
		print("Portal: Failed to save game!")
