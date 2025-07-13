extends Node2D

@export var goblin_scene: PackedScene = preload("res://scenes/character/goblin/goblin.tscn")
@export var max_goblins := 5

@onready var spawn_points_node = $SpawnPoints
@onready var timer = $Timer2

var current_goblins: Array[Node2D] = []
var spawn_points: Array[Node]

func _ready():
	if spawn_points_node == null:
		print("Error: SpawnPoints node not found!")
		return
	
	spawn_points = spawn_points_node.get_children()
	
	if spawn_points.is_empty():
		print("Error: No spawn points found!")
		return
	
	timer.timeout.connect(_on_timer_2_timeout)

func _on_timer_2_timeout() -> void:
	if spawn_points.is_empty():
		return
		
	# Clean up destroyed goblins
	current_goblins = current_goblins.filter(is_instance_valid)
	
	if current_goblins.size() >= max_goblins:
		return
	
	# Pick a random spawn point
	var spawn_point = spawn_points.pick_random()
	var goblin = goblin_scene.instantiate()
	goblin.global_position = spawn_point.global_position
	get_tree().current_scene.add_child(goblin)
	current_goblins.append(goblin)
