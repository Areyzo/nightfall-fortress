extends Control
var isopen: bool =false

func open():
	visible= true
	isopen=true
	
	

func close():
	visible=false
	isopen=false
	
func _ready():
	# Connect all the inventory slots
	var grid = get_node_or_null("NinePatchRect/GridContainer") # Adjust this path!
	
	if grid:
		print("GridContainer found with " + str(grid.get_child_count()) + " children")
		for slot in grid.get_children():
			if slot.has_signal("slot_clicked"):
				slot.slot_clicked.connect(_on_slot_clicked)
				print("Connected slot: " + slot.name)
	else:
		push_error("GridContainer not found! Check the node path.")

func _on_slot_clicked(slot):
	print("Inventory processing: Slot clicked - ", slot.name)
	# Your inventory logic here (selecting items, etc.)
