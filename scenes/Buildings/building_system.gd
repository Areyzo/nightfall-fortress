extends Node2D

var objects: Array = []  # To track instanced objects
var ObjectScene: PackedScene = preload("res://scenes/Buildings/buildings.tscn")  # Update path if needed

@onready var main_button = $Buildings
@onready var hbox = $Control
@onready var inside_button = $Control/HBoxContainer/TextureButton
var target_sibling

func _ready() -> void:
	hbox.visible = false
	target_sibling = get_parent().get_parent().get_node("Buildings")

#func _on_create_pressed() -> void:
	#var obj = ObjectScene.instantiate()
	#add_child(obj)
	#objects.append(obj)
	#print("Created Object: ", obj)

#func _on_delete_pressed() -> void:
	#if objects.size() > 0:
		#var last_obj = objects.pop_back()
		#remove_child(last_obj)
		#last_obj.queue_free()
		#print("Deleted Object: ", last_obj)
	#else:
		#print("No objects to delete.")


func _on_texture_button_pressed() -> void:
	main_button.visible = true
	hbox.visible = false
	print("texture pressed")
	var obj = ObjectScene.instantiate()
	target_sibling.add_child(obj)
	# Call start_placement() to make the building follow mouse cursor
	obj.start_placement()
	objects.append(obj)
	print("Created Object: ", obj)


func _on_buildings_pressed() -> void:
	main_button.visible = false
	hbox.visible = true
