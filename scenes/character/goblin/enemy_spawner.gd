extends Node2D

@onready var testscenes_tilemap = get_parent()
var goblin_scene := preload("res://scenes/character/goblin/goblin.tscn")
var spawn_points := []

func _ready():
	randomize()
	# Collect all Marker2D nodes as spawn points
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)
	
	print("EnemySpawner found ", spawn_points.size(), " spawn points")

func _on_timer_2_timeout():
	if spawn_points.size() == 0:
		print("No spawn points defined!")
		return
	
	# Pick a random spawn point
	var spawn = spawn_points[randi() % spawn_points.size()]
	print("Spawning goblin at: ", spawn.position)
	
	# Spawn enemy at the parent level (same level as Player)
	var goblin = goblin_scene.instantiate()
	goblin.position = spawn.global_position
	
	# Add goblin to the same parent as the spawner (TestscenesTilemap)
	get_parent().add_child(goblin)
	
	print("Goblin spawned successfully")

# Optional: Method to provide player reference to spawned enemies
func get_player_reference():
	return get_parent().get_node("Player")
