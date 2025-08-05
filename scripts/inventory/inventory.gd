extends Resource
class_name Inventory

signal updated

@export var slots: Array[InventorySlot]

func insert(item: InventoryItem):
	print("=== INVENTORY INSERT DEBUG ===")
	print("Trying to insert item: ", item.name if item else "NULL")
	if not item:
		print("ERROR: Trying to insert NULL item!")
		return
		
	print("Item texture: ", item.texture if item else "NO TEXTURE")
	print("Total slots: ", slots.size())
	
	# Try to stack in an existing slot first
	for i in range(slots.size()):
		var slot = slots[i]
		print("Checking slot ", i, ": slot=", slot != null, " slot.item=", slot.item != null if slot else "SLOT_NULL")
		
		if slot != null and slot.item != null:
			print("Slot ", i, " has item: ", slot.item.name if slot.item else "ITEM_NULL", " amount: ", slot.amount)
			# Extra safety check
			if slot.item != null and item != null and slot.item.name == item.name:
				if slot.amount < slot.item.max_stack:
					slot.amount += 1
					print("Stacked item in slot ", i, " new amount: ", slot.amount)
					updated.emit()
					print("=== INSERT SUCCESS (STACKED) ===")
					return  # Done stacking
		else:
			print("Slot ", i, " is empty or null")

	# If stacking failed or maxed out, find an empty slotd
	for i in range(slots.size()):
		var slot = slots[i]
		if slot != null and slot.item == null:
			slot.item = item
			slot.amount = 1
			print("Inserted item into empty slot ", i)
			updated.emit()
			print("=== INSERT SUCCESS (NEW SLOT) ===")
			return  # Inserted into empty slot

	# No slot available — optionally handle "inventory full" here
	print("=== INSERT FAILED - INVENTORY FULL ===")
	print("Inventory full! Could not insert item: ", item.name if item else "NULL_ITEM")


func removeItemAtIndex(index: int):
	slots[index] = InventorySlot.new()
	updated.emit()


func insertSlot(index: int, inventorySlot: InventorySlot):
	var oldIndex: int = slots.find(inventorySlot)
	removeItemAtIndex(oldIndex)
	slots[index] = inventorySlot
	updated.emit()
