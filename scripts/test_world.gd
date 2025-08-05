extends Node2D

@onready var player = $Player

func _ready():
	# Load saved game data when entering test world
	if FileAccess.file_exists("user://savegame.json"):
		load_game()

func load_game():
	var save_data = get_save_data()
	
	if save_data.has("player_position") and player:
		var pos = save_data["player_position"]
		player.global_position = Vector2(pos["x"], pos["y"])
		print("Test World: Player position loaded: ", player.global_position)
	
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
			
			# Find the item resource by name
			var item = load_item_by_name(item_name)
			if item and index < player.inventory.slots.size():
				var slot = player.inventory.slots[index]
				if slot:
					slot.item = item
					slot.amount = amount
		
		player.inventory.updated.emit()
		print("Test World: Loaded ", inventory_data.size(), " inventory items")
	
	print("Test World: Game loaded successfully!")

# Helper function to load items by name - same as main scene
func load_item_by_name(item_name: String) -> InventoryItem:
	# Load actual item resources from the items folder
	var item_path = "res://scripts/inventory/items/" + item_name.to_lower() + ".tres"
	
	if ResourceLoader.exists(item_path):
		var loaded_item = load(item_path) as InventoryItem
		if loaded_item:
			print("Test World: Loaded item resource: ", item_name, " with texture")
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
	
	# Fallback: create basic item without texture
	print("Test World: Warning: Could not find item resource for: ", item_name)
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
				print("Test World: Save data loaded successfully")
				return json.data
			else:
				print("Test World: Error parsing save file")
	else:
		print("Test World: No save file found")
	
	return {}
