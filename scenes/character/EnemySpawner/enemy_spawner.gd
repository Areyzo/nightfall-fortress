extends Node2D

@export var goblin_scene: PackedScene = preload("res://scenes/character/goblin/goblin.tscn")
@export var max_goblins := 5
@export var night_start_hour := 18  # 6 PM
@export var night_end_hour := 6     # 6 AM

@onready var spawn_points_node = $SpawnPoints
@onready var timer = $Timer2

var current_goblins: Array[Node2D] = []
var spawn_points: Array[Node]
var time_system: TimeSystem

func _ready():
	if spawn_points_node == null:
		print("Error: SpawnPoints node not found!")
		return
	
	spawn_points = spawn_points_node.get_children()
	
	if spawn_points.is_empty():
		print("Error: No spawn points found!")
		return
	
	# Find the time system in the scene
	time_system = get_tree().get_first_node_in_group("time_system")
	if time_system == null:
		# Try to find it by searching the scene tree
		time_system = find_time_system_in_scene(get_tree().current_scene)
	
	if time_system == null:
		print("Warning: TimeSystem not found! Goblins will spawn regardless of time.")
	else:
		print("EnemySpawner found TimeSystem - goblins will only spawn at night (", night_start_hour, ":00 - ", night_end_hour, ":00)")
	
	timer.timeout.connect(_on_timer_2_timeout)

func find_time_system_in_scene(node: Node) -> TimeSystem:
	# Recursively search for TimeSystem
	if node is TimeSystem:
		return node as TimeSystem
	
	for child in node.get_children():
		var result = find_time_system_in_scene(child)
		if result != null:
			return result
	
	return null

func is_night_time() -> bool:
	if time_system == null or time_system.date_time == null:
		return true  # Default to allowing spawn if no time system
	
	var current_hour = time_system.date_time.hours
	
	# Night time spans across midnight (18:00 to 6:00)
	if night_start_hour > night_end_hour:  # Crosses midnight
		return current_hour >= night_start_hour or current_hour < night_end_hour
	else:  # Normal day range
		return current_hour >= night_start_hour and current_hour < night_end_hour

func _on_timer_2_timeout() -> void:
	if spawn_points.is_empty():
		return
	
	# Check if it's night time before spawning
	if not is_night_time():
		print("EnemySpawner: Not night time (", time_system.date_time.hours if time_system and time_system.date_time else "unknown", ":00), skipping goblin spawn")
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
	print("EnemySpawner: Spawned goblin at night time (", time_system.date_time.hours if time_system and time_system.date_time else "unknown", ":00)")
