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

	if inventorySlot.amount > 1:
		amountLabel.visible = true
		amountLabel.text = str(inventorySlot.amount)
	else:
		amountLabel.visible = false
