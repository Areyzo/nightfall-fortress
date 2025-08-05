extends Panel
class_name ItemStackGui

@onready var itemSprite : Sprite2D = $item
@onready var amountLabel : Label = $Label

var inventorySlot: InventorySlot

func update():
	if inventorySlot == null or inventorySlot.item == null:
		itemSprite.visible = false
		amountLabel.visible = false
		return

	itemSprite.visible = true
	itemSprite.texture = inventorySlot.item.texture
	
	# Set item to display at 32x32 pixels in inventory
	if itemSprite.texture:
		var texture_size = itemSprite.texture.get_size()
		var desired_size = Vector2(32, 32)
		var scale_factor = Vector2(
			desired_size.x / texture_size.x,
			desired_size.y / texture_size.y
		)
		# Use the smaller scale factor to maintain aspect ratio
		var uniform_scale = min(scale_factor.x, scale_factor.y)
		itemSprite.scale = Vector2(uniform_scale, uniform_scale)

	if inventorySlot.amount > 1:
		amountLabel.visible = true
		amountLabel.text = str(inventorySlot.amount)
	else:
		amountLabel.visible = false
