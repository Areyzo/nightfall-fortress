extends Resource
class_name Inventory

signal updated

@export var slots: Array[InventorySlot]

func insert(item: InventoryItem):
	# Try to stack in an existing slot first
	for slot in slots:
		if slot != null and slot.item != null and slot.item.name == item.name:
			if slot.amount < slot.item.max_stack:
				slot.amount += 1
				updated.emit()
				return  # Done stacking

	# If stacking failed or maxed out, find an empty slot
	for slot in slots:
		if slot != null and slot.item == null:
			slot.item = item
			slot.amount = 1
			updated.emit()
			return  # Inserted into empty slot

	# No slot available — optionally handle "inventory full" here
	print("Inventory full! Could not insert item: ", item.name)


func removeItemAtIndex(index: int):
	slots[index] = InventorySlot.new()
	updated.emit()
	


func insertSlot(index: int, inventorySlot: InventorySlot):
	var oldIndex: int = slots.find(inventorySlot)
	removeItemAtIndex(oldIndex)
	slots[index] = inventorySlot
	updated.emit()
