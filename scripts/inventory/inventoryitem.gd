extends Resource
class_name InventoryItem

@export var name: String = ""
@export var texture: Texture2D  # FIXED: now correctly exports a texture
@export var max_stack: int = 10

func get_icon() -> Texture2D:
	return texture
