extends MultiplayerSynchronizer

var input_direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	input_direction.x = Input.get_axis("right", "left")
	input_direction.y = Input.get_axis("down", "up")

func _physics_process(delta: float) -> void:
	input_direction.x = Input.get_axis("left", "right")
	input_direction.y = Input.get_axis("up", "down")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
