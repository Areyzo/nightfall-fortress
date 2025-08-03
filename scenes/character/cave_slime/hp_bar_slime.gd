extends TextureProgressBar

func update_health(current_health: int, max_health: int):
	var health_percentage = (float(current_health) / float(max_health)) * 100.0
	value = health_percentage
	print("Health bar updated: ", current_health, "/", max_health, " = ", health_percentage, "%")
	
	# Make sure the bar is visible
	visible = true
	
	# Optional: Change color based on health percentage
	if health_percentage > 60:
		modulate = Color.GREEN
	elif health_percentage > 30:
		modulate = Color.YELLOW
	else:
		modulate = Color.RED

func _ready():
	# Set initial values
	min_value = 0
	max_value = 100
	value = 100
	print("Health bar initialized: min=", min_value, " max=", max_value, " value=", value)