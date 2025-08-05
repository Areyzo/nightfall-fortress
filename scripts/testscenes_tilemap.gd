extends Node2D

@onready var player=$Player
@onready var canvaslayer=$CanvasLayer
@onready var esc_menu = $CanvasLayer/EscMenu

var is_esc_menu_open = false
var should_load_save = false

func _ready():
	if esc_menu:
		esc_menu.hide()
		
	# Connect to player death signal if available
	if player and player.has_signal("player_died"):
		player.connect("player_died", _on_player_died)
	
	# Check if we should load a saved game
	# We'll check this directly instead of using GlobalData for now
	if should_load_save or FileAccess.file_exists("user://savegame.json"):
		load_game()

func load_game():
	var save_data = get_save_data()
	
	if save_data.has("player_position") and player:
		var pos = save_data["player_position"]
		player.global_position = Vector2(pos["x"], pos["y"])
		print("Player position loaded: ", player.global_position)
	
	# Load inventory data
	if save_data.has("inventory") and player and player.inventory:
		# Clear current inventory first
		for slot in player.inventory.slots:
			if slot:
				slot.item = null
				slot.amount = 0
		
		# Load saved inventory items
		var inventory_data = save_data["inventory"]
		for item_data in inventory_data:
			var index = item_data["index"]
			var item_name = item_data["item_name"]
			var amount = item_data["amount"]
			
			# Find the item resource by name (you might need to load from a resource database)
			var item = load_item_by_name(item_name)
			if item and index < player.inventory.slots.size():
				var slot = player.inventory.slots[index]
				if slot:
					slot.item = item
					slot.amount = amount
		
		player.inventory.updated.emit()
		print("Loaded ", inventory_data.size(), " inventory items")
	
	print("Game loaded successfully!")

# Helper function to load items by name - loads proper item resources with textures
func load_item_by_name(item_name: String) -> InventoryItem:
	# Load actual item resources from the items folder
	var item_path = "res://scripts/inventory/items/" + item_name.to_lower() + ".tres"
	
	if ResourceLoader.exists(item_path):
		var loaded_item = load(item_path) as InventoryItem
		if loaded_item:
			print("Loaded item resource: ", item_name, " with texture")
			return loaded_item
	
	# Try alternative names or paths
	match item_name.to_lower():
		"stone":
			if ResourceLoader.exists("res://scripts/inventory/items/stone.tres"):
				return load("res://scripts/inventory/items/stone.tres")
		"wood", "log":
			if ResourceLoader.exists("res://scripts/inventory/items/log.tres"):
				return load("res://scripts/inventory/items/log.tres")
		"arrow":
			if ResourceLoader.exists("res://scripts/inventory/items/arrow.tres"):
				return load("res://scripts/inventory/items/arrow.tres")
	
	# Fallback: create basic item without texture (this shouldn't happen if items exist)
	print("Warning: Could not find item resource for: ", item_name)
	var fallback_item = InventoryItem.new()
	fallback_item.name = item_name
	return fallback_item

func get_save_data() -> Dictionary:
	if FileAccess.file_exists("user://savegame.json"):
		var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				print("Save data loaded successfully")
				return json.data
			else:
				print("Error parsing save file")
	else:
		print("No save file found")
	
	return {}

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_esc_menu()
	
	# B key to open building system
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_B:
			toggle_building_menu()

func toggle_esc_menu():
	if is_esc_menu_open:
		close_esc_menu()
	else:
		open_esc_menu()

func open_esc_menu():
	is_esc_menu_open = true
	esc_menu.show()
	get_tree().paused = true

func close_esc_menu():
	is_esc_menu_open = false
	esc_menu.hide()
	get_tree().paused = false

func toggle_building_menu():
	# Find the building system in the CanvasLayer
	var building_system = canvaslayer.get_node_or_null("Building system")
	if building_system:
		# Check if the building menu is currently open
		var control_node = building_system.get_node_or_null("Control")
		if control_node and control_node.visible:
			# Menu is open, close it
			building_system._on_close_button_pressed()
			print("Building menu closed with B key")
		else:
			# Menu is closed, open it
			building_system._on_buildings_pressed()
			print("Building menu opened with B key")
	else:
		print("Building system not found!")

func _on_continue_pressed():
	close_esc_menu()

func _on_save_and_exit_pressed():
	save_game()
	get_tree().quit()

func save_game():
	var save_data = {}
	
	# Save player data
	if player:
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
			print("Saved ", inventory_data.size(), " inventory items")
	
	# Save game state (you can expand this)
	save_data["timestamp"] = Time.get_unix_time_from_system()
	
	# Create save file
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("Game saved successfully!")
	else:
		print("Failed to save game!")

func _on_inventory_gui_closed() :
	get_tree().paused =false

func _on_inventory_gui_opened() :
	get_tree().paused =true
	
func host():
	print("host")
	%multiplayerHUD.hide()
	MultiplayerManager.become_host()
	
func join():
	print("join")
	%multiplayerHUD.hide()
	MultiplayerManager.join_as_player()

func _on_player_died():
	"""Handle player death - clear any saved inventory data"""
	print("Player died! Clearing saved inventory data...")
	
	# Delete the save file so the player starts fresh
	if FileAccess.file_exists("user://savegame.json"):
		DirAccess.remove_absolute("user://savegame.json")
		print("Save file deleted - player will start with empty inventory on respawn")
	
