extends Node2D

var placed = false
var dead = false
var health = 1000

func _ready() -> void:
	pass

func _process(_delta: float) -> void:  # ✅ _delta to avoid unused warning
	if not placed:
		var mouse_position = get_viewport().get_mouse_position()
		$Area2D.position = snap_to_grid(mouse_position, 32)

		if $Area2D.get_overlapping_areas().size() > 0:
			print("Can't place here! Something is overlapping.")
			$Area2D/Sprite2D.modulate = Color(1, 0, 0, 0.5)  # Red & transparent
		else:
			$Area2D/Sprite2D.modulate = Color(1, 1, 1, 0.5)  # White & transparent

	if placed:
		var damage = 1
		health -= damage
		print("Health: ", health)

		if health <= 0:
			dead = true

	if dead:
		print("Node destroyed.")
		queue_free()  # ✅ Deletes the node safely

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if $Area2D.get_overlapping_areas().size() > 0:
				print("Can't place here! Something is overlapping.")
			else:
				print("Building placed")
				placed = true
				$Area2D/Sprite2D.modulate = Color(1, 1, 1, 1)  # Fully visible

func snap_to_grid(mouse_pos: Vector2, grid_size: int) -> Vector2:  # ✅ Renamed to avoid shadowing `position`
	return Vector2(
		round(mouse_pos.x / grid_size) * grid_size,
		round(mouse_pos.y / grid_size) * grid_size
	)
