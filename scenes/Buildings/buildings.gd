extends Node2D

var placed = false
var dead = false
var health = 1000
var is_being_placed = false  # New variable to control when building follows mouse

func _ready() -> void:
	# Building starts invisible/inactive until selected from menu
	visible = false

func _process(_delta: float) -> void:  # ✅ _delta to avoid unused warning
	# Only follow mouse when building is selected for placement and not yet placed
	if is_being_placed and not placed:
		# Get mouse position in world coordinates
		var mouse_position = get_global_mouse_position()
		
		# Snap to smaller grid for closer mouse following
		var snapped_position = snap_to_grid(mouse_position, 16)  # Reduced from 32 to 16
		global_position = snapped_position

		# Check if Area2D exists before using it
		if $Area2D != null:
			if $Area2D.get_overlapping_areas().size() > 0:
				print("Can't place here! Something is overlapping.")
				if $Area2D/Sprite2D != null:
					$Area2D/Sprite2D.modulate = Color(1, 0, 0, 0.5)  # Red & transparent
			else:
				if $Area2D/Sprite2D != null:
					$Area2D/Sprite2D.modulate = Color(1, 1, 1, 0.5)  # White & transparent
	
	# Once placed, building stays in place and stops following mouse

func _input(event: InputEvent) -> void:
	# Only handle input when building is being placed
	if is_being_placed and not placed:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				# Check if Area2D exists before using it
				if $Area2D != null:
					if $Area2D.get_overlapping_areas().size() > 0:
						print("Can't place here! Something is overlapping.")
					else:
						print("Building placed")
						placed = true
						is_being_placed = false  # Stop following mouse
						if $Area2D/Sprite2D != null:
							$Area2D/Sprite2D.modulate = Color(1, 1, 1, 1)  # Fully visible
				else:
					# If no Area2D, just place the building
					print("Building placed (no collision detection)")
					placed = true
					is_being_placed = false  # Stop following mouse

# Function to be called when building is selected from menu
func start_placement():
	is_being_placed = true
	visible = true
	print("Building selected for placement - now following mouse")

func snap_to_grid(mouse_pos: Vector2, grid_size: int) -> Vector2:
	# Simple grid snapping - snap to nearest grid intersection
	return Vector2(
		round(mouse_pos.x / grid_size) * grid_size,
		round(mouse_pos.y / grid_size) * grid_size
	)
