extends Node2D

var objects: Array = []  # To track instanced objects
var ObjectScene: PackedScene = preload("res://scenes/Buildings/buildings.tscn")  # Update path if needed
var building : PackedScene = preload("res://scenes/Buildings/building1.tscn")
var building1 : PackedScene = preload("res://scenes/Buildings/building2.tscn")

@onready var main_button = $Buildings
@onready var hbox = $Control
@onready var inside_button = $Control/HBoxContainer/TextureButton
@onready var projectile: PackedScene = preload("res://scenes/Buildings/projectile.tscn")

var target_sibling
var player_node = null

func _ready() -> void:
	hbox.visible = false
	target_sibling = get_parent().get_parent().get_node("Buildings")
	# Find the player node
	player_node = get_tree().get_first_node_in_group("player")
	if not player_node:
		print("Warning: Player node not found!")

func show_popup_message(message: String):
	# Find the CanvasLayer to add the popup to (screen space)
	var canvas_layer = get_tree().current_scene.get_node_or_null("CanvasLayer")
	if not canvas_layer:
		print("No CanvasLayer found, creating temporary one")
		canvas_layer = CanvasLayer.new()
		get_tree().current_scene.add_child(canvas_layer)
	
	# Create a container for better control
	var popup_container = Control.new()
	popup_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create the popup label
	var popup = Label.new()
	popup.text = message
	popup.add_theme_color_override("font_color", Color.RED)
	popup.add_theme_font_size_override("font_size", 20)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Position at center top of screen
	popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	popup.position.x = -200  # Center it (half of 400px width)
	popup.position.y = 50    # Distance from top
	popup.size = Vector2(400, 50)  # Set explicit size
	
	# Add popup to container, container to canvas layer
	popup_container.add_child(popup)
	canvas_layer.add_child(popup_container)
	
	print("Popup created and added to scene - should be visible now")
	
	# Create a tween to fade out the message
	var tween = create_tween()
	tween.tween_interval(2.5)  # Wait for 2.5 seconds
	tween.tween_property(popup, "modulate:a", 0.0, 0.8)  # Fade out over 0.8 seconds
	tween.tween_callback(popup_container.queue_free)  # Remove container when done
	
	print("Popup message: ", message)

func check_stone_requirement(stones_needed: int = 7) -> bool:
	if not player_node:
		return false
	
	var inventory = player_node.get_inventory()
	if not inventory:
		print("No inventory found!")
		return false
	
	# Check for stones in inventory
	var stone_count = 0
	if "slots" in inventory and inventory.slots:
		for slot in inventory.slots:
			if slot != null and "item" in slot and slot.item != null:
				if "name" in slot.item and slot.item.name == "stone":
					if "amount" in slot:
						stone_count += slot.amount
	
	print("Stones available: ", stone_count, ", needed: ", stones_needed)
	return stone_count >= stones_needed

func check_arrow_requirement(arrows_needed: int = 5) -> bool:
	if not player_node:
		return false
	
	var inventory = player_node.get_inventory()
	if not inventory:
		print("No inventory found!")
		return false
	
	# Check for arrows in inventory
	var arrow_count = 0
	if "slots" in inventory and inventory.slots:
		for slot in inventory.slots:
			if slot != null and "item" in slot and slot.item != null:
				if "name" in slot.item and slot.item.name == "arrow":
					if "amount" in slot:
						arrow_count += slot.amount
	
	print("Arrows available: ", arrow_count, ", needed: ", arrows_needed)
	return arrow_count >= arrows_needed

func check_wood_requirement(wood_needed: int = 1) -> bool:
	if not player_node:
		return false
	
	var inventory = player_node.get_inventory()
	if not inventory:
		print("No inventory found!")
		return false
	
	# Check for wood/log in inventory
	var wood_count = 0
	if "slots" in inventory and inventory.slots:
		for slot in inventory.slots:
			if slot != null and "item" in slot and slot.item != null:
				if "name" in slot.item and (slot.item.name == "wood" or slot.item.name == "log"):
					if "amount" in slot:
						wood_count += slot.amount
	
	print("Wood/Log available: ", wood_count, ", needed: ", wood_needed)
	return wood_count >= wood_needed

func consume_stone(stones_to_consume: int = 7) -> bool:
	if not player_node:
		return false
	
	var inventory = player_node.get_inventory()
	if not inventory:
		return false
	
	# Find and consume stones
	var consumed = 0
	
	if "slots" in inventory and inventory.slots:
		for slot in inventory.slots:
			if slot != null and "item" in slot and slot.item != null:
				if "name" in slot.item and slot.item.name == "stone":
					if "amount" in slot and slot.amount > 0:
						var take_amount = min(slot.amount, stones_to_consume - consumed)
						slot.amount -= take_amount
						consumed += take_amount
						
						print("Consumed ", take_amount, " stones from slot. Slot remaining: ", slot.amount)
						
						# Remove slot if empty
						if slot.amount <= 0:
							var slot_index = inventory.slots.find(slot)
							if slot_index != -1:
								inventory.slots[slot_index] = null
						
						# Stop if we've consumed enough
						if consumed >= stones_to_consume:
							break
	
	if consumed >= stones_to_consume:
		inventory.updated.emit()  # Update inventory UI
		print("Successfully consumed ", consumed, " stones!")
		return true
	else:
		print("Failed to consume enough stones. Only consumed: ", consumed)
		return false

func consume_arrow(arrows_to_consume: int = 5) -> bool:
	if not player_node:
		return false
	
	var inventory = player_node.get_inventory()
	if not inventory:
		return false
	
	# Find and consume arrows
	var consumed = 0
	
	if "slots" in inventory and inventory.slots:
		for slot in inventory.slots:
			if slot != null and "item" in slot and slot.item != null:
				if "name" in slot.item and slot.item.name == "arrow":
					if "amount" in slot and slot.amount > 0:
						var take_amount = min(slot.amount, arrows_to_consume - consumed)
						slot.amount -= take_amount
						consumed += take_amount
						
						print("Consumed ", take_amount, " arrows from slot. Slot remaining: ", slot.amount)
						
						# Remove slot if empty
						if slot.amount <= 0:
							var slot_index = inventory.slots.find(slot)
							if slot_index != -1:
								inventory.slots[slot_index] = null
						
						# Stop if we've consumed enough
						if consumed >= arrows_to_consume:
							break
	
	if consumed >= arrows_to_consume:
		inventory.updated.emit()  # Update inventory UI
		print("Successfully consumed ", consumed, " arrows!")
		return true
	else:
		print("Failed to consume enough arrows. Only consumed: ", consumed)
		return false

func consume_wood(wood_to_consume: int = 1) -> bool:
	if not player_node:
		return false
	
	var inventory = player_node.get_inventory()
	if not inventory:
		return false
	
	# Find and consume wood/log
	var consumed = 0
	
	if "slots" in inventory and inventory.slots:
		for slot in inventory.slots:
			if slot != null and "item" in slot and slot.item != null:
				if "name" in slot.item and (slot.item.name == "wood" or slot.item.name == "log"):
					if "amount" in slot and slot.amount > 0:
						var take_amount = min(slot.amount, wood_to_consume - consumed)
						slot.amount -= take_amount
						consumed += take_amount
						
						print("Consumed ", take_amount, " wood/log from slot. Slot remaining: ", slot.amount)
						
						# Remove slot if empty
						if slot.amount <= 0:
							var slot_index = inventory.slots.find(slot)
							if slot_index != -1:
								inventory.slots[slot_index] = null
						
						# Stop if we've consumed enough
						if consumed >= wood_to_consume:
							break
	
	if consumed >= wood_to_consume:
		inventory.updated.emit()  # Update inventory UI
		print("Successfully consumed ", consumed, " wood/log!")
		return true
	else:
		print("Failed to consume enough wood/log. Only consumed: ", consumed)
		return false

func _on_texture_button_pressed() -> void:
	# Check if player has 7 stones and 5 arrows
	if not check_stone_requirement(7):
		show_popup_message("Need 7 stones and 5 arrows to place building!")
		return
	
	if not check_arrow_requirement(5):
		show_popup_message("Need 7 stones and 5 arrows to place building!")
		return
	
	# Consume the resources
	if not consume_stone(7):
		show_popup_message("Failed to consume stones!")
		return
	
	if not consume_arrow(5):
		show_popup_message("Failed to consume arrows!")
		return
	
	# Place the building
	main_button.visible = true
	hbox.visible = false
	show_popup_message("Building placed! 7 stones and 5 arrows consumed.")
	
	var obj = ObjectScene.instantiate()
	obj.shoot_projectile.connect(self._on_shoot_projectile)
	target_sibling.add_child(obj)
	# Call start_placement() to make the building follow mouse cursor
	obj.start_placement()
	objects.append(obj)

func shoot_projectile(origin , target ):
	print("shoot_projectile called with origin: ", origin, " target: ", target)
	var projectile_instance = projectile.instantiate()
	print("Projectile instantiated: ", projectile_instance)
	projectile_instance.origin_pos = origin
	projectile_instance.target_pos = target
	
	# Add projectile to the main scene (same level as buildings and goblins)
	var main_scene = get_tree().current_scene
	main_scene.add_child(projectile_instance)
	
	print(" PROJECTILE FIRED from: ", origin, " to: ", target)

func _on_buildings_pressed() -> void:
	main_button.visible = false
	hbox.visible = true

func _on_shoot_projectile(origin, target):
	print("=== SIGNAL RECEIVED ===")
	print("Building system received shoot_projectile signal!")
	print("Origin: ", origin, " Target: ", target)
	shoot_projectile(origin, target)


func _on_texture_button_2_pressed() -> void:
	# Check if player has 4 stones and 2 arrows for building1
	if not check_stone_requirement(4):
		show_popup_message("Need 4 stones and 2 arrows to place building!")
		return
	
	if not check_arrow_requirement(2):
		show_popup_message("Need 4 stones and 2 arrows to place building!")
		return
	
	# Consume the resources
	if not consume_stone(4):
		show_popup_message("Failed to consume stones!")
		return
	
	if not consume_arrow(2):
		show_popup_message("Failed to consume arrows!")
		return
	
	# Place the building
	main_button.visible = true
	hbox.visible = false
	show_popup_message("Building placed! 4 stones and 2 arrows consumed.")
	
	print("Building1 placed")
	var obj = building.instantiate()
	obj.shoot_projectile.connect(self._on_shoot_projectile)
	target_sibling.add_child(obj)
	# Call start_placement() to make the building follow mouse cursor
	obj.start_placement()
	objects.append(obj)


func _on_texture_button_3_pressed() -> void:
	# Check if player has 1 wood, 1 stone, and 2 arrows for building2
	if not check_wood_requirement(1):
		show_popup_message("Need 1 wood, 1 stone, and 2 arrows to place building!")
		return
	
	if not check_stone_requirement(1):
		show_popup_message("Need 1 wood, 1 stone, and 2 arrows to place building!")
		return
	
	if not check_arrow_requirement(2):
		show_popup_message("Need 1 wood, 1 stone, and 2 arrows to place building!")
		return
	
	# Consume the resources
	if not consume_wood(1):
		show_popup_message("Failed to consume wood!")
		return
	
	if not consume_stone(1):
		show_popup_message("Failed to consume stone!")
		return
	
	if not consume_arrow(2):
		show_popup_message("Failed to consume arrows!")
		return
	
	# Place the building
	main_button.visible = true
	hbox.visible = false
	show_popup_message("Building placed! 1 wood, 1 stone, and 2 arrows consumed.")
	
	print("Building2 placed")
	var obj = building1.instantiate()
	obj.shoot_projectile.connect(self._on_shoot_projectile)
	target_sibling.add_child(obj)
	# Call start_placement() to make the building follow mouse cursor
	obj.start_placement()
	objects.append(obj)
func _on_close_button_pressed() -> void:
	main_button.visible = true
	hbox.visible = false
	print("Close button pressed")
