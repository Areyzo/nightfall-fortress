extends Area2D

@export var destination_level_tag: String

func _ready():
	# Connect the body_entered signal
	connect("body_entered", _on_body_entered)
	print("Portal ready with destination: ", destination_level_tag)

func _on_body_entered(body: Node2D) -> void:
	print("Something entered portal: ", body.name)
	
	# Check if it's the player using multiple methods
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		print("Player detected! Teleporting to: ", destination_level_tag)
		
		# Check if NavigationManger exists (note the typo in the original)
		if has_node("/root/NavigationManger"):
			get_node("/root/NavigationManger").go_to_level(destination_level_tag)
		elif has_node("/root/NavigationManager"):  # In case it gets fixed
			get_node("/root/NavigationManager").go_to_level(destination_level_tag)
		else:
			print("NavigationManger not found! Cannot teleport.")
			# Fallback - try to change scene directly
			if destination_level_tag == "lobby":
				get_tree().change_scene_to_file("res://scenes/test/test_world.tscn")
			elif destination_level_tag == "world":
				get_tree().change_scene_to_file("res://scenes/test/testscenes_tilemap.tscn")
			else:
				print("Unknown destination: ", destination_level_tag)
	else:
		print("Non-player body detected: ", body.name)
