extends Area2D

@export var destination_level_tag:String

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Collision between player and the portal is detected")
		NaviagationManager.go_to_level(destination_level_tag)
	else:
		print("No body is detected.")
