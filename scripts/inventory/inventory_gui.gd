extends Control

signal opened
signal closed

var isOpen :bool =false
@onready var inventory : Inventory = preload("res://scripts/inventory/playerinventory.tres")
@onready var ItemStackGuiClass = preload("res://scenes/inventory/itemsStackGui.tscn")
@onready var slots :Array= $NinePatchRect/GridContainer.get_children()

var itemInHand : ItemStackGui


func _ready():
	connectSlots()
	inventory.updated.connect(update)
	update()


func connectSlots():
	
	for i in range(slots.size()):
		var slot= slots[i]
		slot.index=i
		
		
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)


func update():
	print("=== INVENTORY GUI UPDATE CALLED ===")
	print("Total inventory slots: ", inventory.slots.size() if inventory else "INVENTORY_NULL")
	
	if not inventory or not inventory.slots:
		print("ERROR: Inventory or slots is null!")
		return
	
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		# More defensive null checking
		if inventorySlot == null:
			print("GUI Slot ", i, ": INVENTORY_SLOT_NULL")
			continue
			
		if inventorySlot.item == null:
			print("GUI Slot ", i, ": EMPTY")
			continue
		
		# Extra safety check before accessing item properties
		if inventorySlot.item != null:
			print("GUI Slot ", i, ": ", inventorySlot.item.name, " amount: ", inventorySlot.amount)
		else:
			print("GUI Slot ", i, ": ITEM_BECAME_NULL")
			continue
		
		var itemStackGui : ItemStackGui = slots[i].itemStackGui 
		if !itemStackGui:
			itemStackGui = ItemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)
			print("Created new ItemStackGui for slot ", i)
			
		itemStackGui.inventorySlot = inventorySlot
		itemStackGui.update()
		print("Updated ItemStackGui for slot ", i, " with item: ", inventorySlot.item.name if inventorySlot.item else "NULL_ITEM")
	
	print("=== INVENTORY GUI UPDATE COMPLETE ===")
			


func open():
	visible=true
	isOpen =true
	opened.emit()
	

func close():
	visible=false
	isOpen =false
	closed.emit()
	

func onSlotClicked(slot):
	if slot.isEmpty():
		if  !itemInHand:return
	
		insertItemInSlot(slot)
		return
		
	if !itemInHand:
		takeItemFromSlot(slot)
		return
	
	swapItems(slot)
	
func takeItemFromSlot(slot):
	itemInHand= slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	
func insertItemInSlot(slot):
	var item= itemInHand
	remove_child(itemInHand)
	itemInHand=null
	slot.insert(item)

func swapItems(slot):
	var tempItem=slot.takeItem()
	
	insertItemInSlot(slot)
	
	itemInHand=tempItem
	add_child(itemInHand)
	updateItemInHand()

func  updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position= get_global_mouse_position() - itemInHand.size/2
	
func _input(event):
	updateItemInHand()
