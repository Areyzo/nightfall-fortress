extends Node2D

var placed = false
var dead = false
var health = 1000
var target_within_range = []
signal shoot_projectile

func _ready() -> void:
	pass

func _process(_delta: float) -> void:  #  _delta to avoid unused warning
	if not placed:
		var mouse_position =  get_global_mouse_position()
		$Area2D.position = snap_to_grid(mouse_position, 32)
		$Hit_Range.position = $Area2D.position

		if $Area2D.get_overlapping_areas().size() > 0:
			print("Can't place here! Something is overlapping.")
			$Area2D/Sprite2D.modulate = Color(1, 0, 0, 0.5)  # Red & transparent
		else:
			$Area2D/Sprite2D.modulate = Color(1, 1, 1, 0.5)  # White & transparent

	if placed:
		#var damage = 1
		#health -= damage
		if health <= 0:
			dead = true

	if dead:
		print("Node destroyed.")
		queue_free()  #  Deletes the node safely

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if $Area2D.get_overlapping_areas().size() > 0:
				print("Can't place here! Something is overlapping.")
			else:
				print("Building placed")
				placed = true
				$Area2D/Sprite2D.modulate = Color(1, 1, 1, 1)  # Fully visible

func snap_to_grid(mouse_pos: Vector2, grid_size: int) -> Vector2:  #  Renamed to avoid shadowing `position`
	return Vector2(
		round(((mouse_pos.x) / grid_size) * grid_size - 120),
		round(mouse_pos.y / grid_size) * grid_size
	)


func _on_hit_range_body_shape_entered(area) -> void:
	print("Entered area node:", area.name)

	 #$Optional: print the full node path or its scene file
	print("Full path:", area.get_path())
	print("Scene file (if instanced):", area.scene_file_path)

	if area.name.contains("Goblin"):
		target_within_range.append(area)
		

func _on_hit_range_area_shape_exited(area) -> void:
	if "goblin" in area.name and target_within_range.size()>0:
		target_within_range.erase(area)


func _on_timer_timeout() -> void:
	if target_within_range.size()>0:
		var projectile_origin_pos = position + Vector2(32,32)
		emit_signal("shoot_projectile",projectile_origin_pos,target_within_range[0].position)


func _on_hit_range_area_entered(area: Area2D) -> void:
	print("Entered area node:", area.name)

	 #$Optional: print the full node path or its scene file
	print("Full path:", area.get_path())
	print("Scene file (if instanced):", area.scene_file_path)

	if area.name.contains("Goblin"):
		target_within_range.append(area)


func _on_hit_range_area_exited(area: Area2D) -> void:
	if "goblin" in area.name and target_within_range.size()>0:
		target_within_range.erase(area)


func _on_hit_range_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("Entered area node:", area.name)

	 #$Optional: print the full node path or its scene file
	print("Full path:", area.get_path())
	print("Scene file (if instanced):", area.scene_file_path)

	if area.name.contains("Goblin"):
		target_within_range.append(area)
