
extends Button

signal slot_clicked(slot)
var item = null
var quantity = 0

func _ready():
	# Connect the pressed signal
	pressed.connect(_on_pressed)
	
	# Optional: Add visual feedback for hovering
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_pressed():
	print("Slot clicked: ", name)
	emit_signal("slot_clicked", self)
	
func _on_mouse_entered():
	# Visual feedback when hovering
	modulate = Color(1.2, 1.2, 1.2)  # Make slightly brighter
	
func _on_mouse_exited():
	# Return to normal
	modulate = Color(1, 1, 1)

# Function to update the slot's appearance
func update_display():
	if item != null:
		$Sprite2D.texture = item.texture  # Update with your actual node path
		$Label.text = str(quantity)
		$Sprite2D.visible = true
	else:
		# Empty slot appearance
		$Sprite2D.visible = false
		$Label.text = ""
