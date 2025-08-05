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
	objects.append(obj)
	print("Created Object: ", obj)

func shoot_projectile(origin , target ):
	var projectile_instance = projectile.instance()
	projectile_instance.origin_pos = origin
	projectile_instance.target_pos = target
	$entities.add_child(projectile_instance)

func _on_buildings_pressed() -> void:
	main_button.visible = false
	hbox.visible = true

func _on_shoot_projectile(origin, target):
	shoot_projectile(origin, target)
