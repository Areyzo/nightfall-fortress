extends Node2D

var objects: Array = []  # To track instanced objects
var ObjectScene: PackedScene = preload("res://scenes/Buildings/buildings.tscn")  # Update path if needed

@onready var main_button = $Buildings
@onready var hbox = $Control
@onready var inside_button = $Control/HBoxContainer/TextureButton
@onready var projectile: PackedScene = preload("res://scenes/Buildings/projectile.tscn")

var target_sibling

func _ready() -> void:
	hbox.visible = false
	target_sibling = get_parent().get_parent().get_node("Buildings")

func _on_texture_button_pressed() -> void:
	main_button.visible = true
	hbox.visible = false
	print("texture pressed")
	var obj = ObjectScene.instantiate()
	obj.shoot_projectile.connect(self._on_shoot_projectile)
	target_sibling.add_child(obj)
	# Call start_placement() to make the building follow mouse cursor
	obj.start_placement()
	objects.append(obj)
	print("Created Object: ", obj)

func shoot_projectile(origin , target ):
	print("=== CREATING PROJECTILE ===")
	print("shoot_projectile called with origin: ", origin, " target: ", target)
	var projectile_instance = projectile.instantiate()
	print("Projectile instantiated: ", projectile_instance)
	projectile_instance.origin_pos = origin
	projectile_instance.target_pos = target
	
	# Add projectile to the main scene (same level as buildings and goblins)
	var main_scene = get_tree().current_scene
	main_scene.add_child(projectile_instance)
	
	print("✅ PROJECTILE FIRED from: ", origin, " to: ", target)

func _on_buildings_pressed() -> void:
	main_button.visible = false
	hbox.visible = true

func _on_shoot_projectile(origin, target):
	print("=== SIGNAL RECEIVED ===")
	print("Building system received shoot_projectile signal!")
	print("Origin: ", origin, " Target: ", target)
	shoot_projectile(origin, target)
