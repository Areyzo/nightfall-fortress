extends Node2D

var placed = false
var dead = false
var health = 1000
var is_being_placed = false  # New variable to control when building follows mouse
var target_within_range = []
signal shoot_projectile

func _ready() -> void:
	# Building starts invisible/inactive until selected from menu
	visible = false
	print("Building created")
	
	# DON'T start timer until building is placed
	
	# Check collision setup and ensure monitoring is enabled
	if $Hit_Range != null:
		print("Hit_Range collision setup: Layer ", $Hit_Range.collision_layer, ", Mask ", $Hit_Range.collision_mask)
		$Hit_Range.monitoring = true
		$Hit_Range.monitorable = true
		print("Hit_Range monitoring enabled: ", $Hit_Range.monitoring)
		print("Hit_Range monitorable enabled: ", $Hit_Range.monitorable)
	else:
		print("ERROR: Hit_Range not found!")

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
	
	# Once placed, handle building logic
	if placed:
		# Clean up invalid targets periodically
		cleanup_invalid_targets()
		
		#var damage = 1
		#health -= damage
		if health <= 0:
			dead = true

	if dead:
		print("Node destroyed.")
		queue_free()  # Deletes the node safely

func cleanup_invalid_targets():
	# Remove any freed/destroyed targets from the list
	var building_range = 108.78  # Match the CircleShape2D radius
	var building_center = global_position + Vector2(217, 169)  # Match Hit_Range position
	
	for i in range(target_within_range.size() - 1, -1, -1):
		var target = target_within_range[i]
		
		# Remove if target is invalid (freed/destroyed)
		if !is_instance_valid(target):
			target_within_range.remove_at(i)
			continue
			
		# Remove if target is out of range
		var distance = building_center.distance_to(target.global_position)
		if distance > building_range:
			target_within_range.remove_at(i)
			print("Removed out-of-range target: ", target.name, " (distance: ", distance, ")")

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
						
						# Start the timer when building is placed
						if $Timer != null:
							$Timer.start()
							print("✅ Timer started for placed building")
						
						# Immediately scan for goblins already in range
						scan_for_goblins_in_range()
						
						if $Area2D/Sprite2D != null:
							$Area2D/Sprite2D.modulate = Color(1, 1, 1, 1)  # Fully visible
				else:
					# If no Area2D, just place the building
					print("Building placed (no collision detection)")
					placed = true
					is_being_placed = false  # Stop following mouse
					
					# Start the timer when building is placed
					if $Timer != null:
						$Timer.start()
						print("✅ Timer started for placed building")
					
					# Immediately scan for goblins already in range
					scan_for_goblins_in_range()

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


func _on_hit_range_body_shape_entered(area) -> void:
	print("Entered area node:", area.name)

	 #$Optional: print the full node path or its scene file
	print("Full path:", area.get_path())
	print("Scene file (if instanced):", area.scene_file_path)

	if area.name.contains("Goblin") and is_instance_valid(area):
		if area not in target_within_range:  # Prevent duplicates
			target_within_range.append(area)
		

func _on_hit_range_area_shape_exited(area) -> void:
	if "goblin" in area.name.to_lower() and target_within_range.size() > 0:
		target_within_range.erase(area)
		print("Goblin exited building range (shape): ", area.name)


func _on_timer_timeout() -> void:
	print("=== TIMER FIRED ===")
	print("Building placed: ", placed)
	
	# Only attack if building is placed
	if not placed:
		print("❌ Building not placed yet, skipping attack")
		return
	
	# ACTIVE SCANNING: Check for goblins in range every timer tick
	print("🔍 Actively scanning for goblins in range...")
	if $Hit_Range != null:
		var overlapping_areas = $Hit_Range.get_overlapping_areas()
		print("Found ", overlapping_areas.size(), " areas overlapping with building range")
		
		# Clear old targets and rebuild list with current overlapping goblins
		target_within_range.clear()
		
		for area in overlapping_areas:
			print("Checking overlapping area: ", area.name)
			if (area.name.contains("Goblin") or area.name.contains("goblin")) and is_instance_valid(area):
				target_within_range.append(area)
				print("✅ Active scan found goblin: ", area.name)
	
	print("Targets in range after scan: ", target_within_range.size())
	
	if target_within_range.size() > 0:
		print("Found targets, attempting to attack...")
		
		# Find the first valid target
		var target = null
		
		for i in range(target_within_range.size()):
			var potential_target = target_within_range[i]
			if is_instance_valid(potential_target):
				target = potential_target
				break
		
		# Clean up invalid targets
		for i in range(target_within_range.size() - 1, -1, -1):
			if !is_instance_valid(target_within_range[i]):
				target_within_range.remove_at(i)
		
		# If no valid target found, return
		if target == null:
			print("No valid targets found after cleanup")
			return
		
		print("Attacking target: ", target.name)
		
		# Use the actual Hit_Range center position from the scene (Vector2(217, 169))
		var building_center = global_position + Vector2(217, 169)
		var projectile_origin_pos = building_center
		
		# Check if target is still within range before shooting
		var distance_to_target = building_center.distance_to(target.global_position)
		var building_range = 108.78
		
		print("Target distance: ", distance_to_target, " vs range: ", building_range)
		
		if distance_to_target > building_range:
			target_within_range.erase(target)
			print("Target out of range, removed")
			return
		
		var target_position = target.global_position
		
		print("🔥 FIRING PROJECTILE from ", building_center, " to ", target_position)
		emit_signal("shoot_projectile", projectile_origin_pos, target_position)
		print("Signal emitted!")
	else:
		print("No targets in range")


func _on_hit_range_area_entered(area: Area2D) -> void:
	print("🚨 AREA_ENTERED SIGNAL FIRED!")
	print("Area name: ", area.name)
	var parent_name = "No parent"
	if area.get_parent():
		parent_name = area.get_parent().name
	print("Area parent: ", parent_name)
	print("Full path: ", area.get_path())
	print("Area valid: ", is_instance_valid(area))
	print("Area collision layer: ", area.collision_layer)
	print("Building mask: ", $Hit_Range.collision_mask)
	
	# Check multiple conditions for goblin detection
	var is_goblin = false
	if area.name.to_lower().contains("goblin"):
		is_goblin = true
		print("✅ Detected goblin by name containing 'goblin'")
	elif area.name == "Goblinhitbox":
		is_goblin = true  
		print("✅ Detected goblin by exact name 'Goblinhitbox'")
	elif area.get_parent() and area.get_parent().name.to_lower().contains("goblin"):
		is_goblin = true
		print("✅ Detected goblin by parent name containing 'goblin'")
	
	print("Collision layer check - Area layer: ", area.collision_layer, " Building mask: ", $Hit_Range.collision_mask)
	
	if is_goblin and is_instance_valid(area):
		if area not in target_within_range:  # Prevent duplicates
			target_within_range.append(area)
			print("🎯 GOBLIN ADDED TO TARGET LIST! Total targets: ", target_within_range.size())
		else:
			print("Goblin already in target list")
	else:
		print("❌ Not a goblin or invalid area")


func _on_hit_range_area_exited(area: Area2D) -> void:
	print("🚪 AREA_EXITED SIGNAL FIRED!")
	print("Area name: ", area.name)
	if (area.name.contains("Goblin") or area.name.contains("goblin")) and target_within_range.size() > 0:
		target_within_range.erase(area)
		print("🎯 Goblin removed from target list! Remaining targets: ", target_within_range.size())
	else:
		print("Non-goblin area exited or no targets to remove")

# Function to actively scan for goblins in range (called when building is placed)
func scan_for_goblins_in_range():
	if $Hit_Range == null:
		return
		
	print("🔍 SCANNING for goblins in range...")
	var overlapping_areas = $Hit_Range.get_overlapping_areas()
	print("Found ", overlapping_areas.size(), " overlapping areas")
	
	for area in overlapping_areas:
		print("Checking area: ", area.name)
		if (area.name.contains("Goblin") or area.name.contains("goblin")) and is_instance_valid(area):
			if area not in target_within_range:
				target_within_range.append(area)
				print("🎯 Found goblin in range during scan: ", area.name)
	
	print("Total targets after scan: ", target_within_range.size())


func _on_hit_range_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	print("Entered area node:", area.name)

	 #$Optional: print the full node path or its scene file
	print("Full path:", area.get_path())
	print("Scene file (if instanced):", area.scene_file_path)

	if area.name.contains("Goblin") and is_instance_valid(area):
		if area not in target_within_range:  # Prevent duplicates
			target_within_range.append(area)
