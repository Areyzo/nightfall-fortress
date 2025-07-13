extends Button
@onready var backgroundSprite : Sprite2D=$background
@onready var container :CenterContainer=$CenterContainer
@onready var inventory=preload("res://scripts/inventory/playerinventory.tres")

var index: int 
var itemStackGui: ItemStackGui

func insert (isg:ItemStackGui):
	itemStackGui=isg
	backgroundSprite.frame=1
	container.add_child(itemStackGui)
	
	if !itemStackGui.inventorySlot || inventory.slots[index]==itemStackGui.inventorySlot:
		return
	
	inventory.insertSlot(index, itemStackGui.inventorySlot)	

func takeItem():
	var item = itemStackGui
	
	container.remove_child(itemStackGui)
	itemStackGui=null
	backgroundSprite.frame=0
	
	return item

func isEmpty():
	return !itemStackGui
