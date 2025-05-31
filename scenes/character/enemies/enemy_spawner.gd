extends Node2D

@onready var testscenes_tilemap =get_parent()
var goblin_scene:=preload("res://scenes/character/enemies/goblin.tscn")
var spawn_points:=[]

func _ready():
	randomize()
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)




func _on_timer_2_timeout():
	if spawn_points.size() == 0:
		print("No spawn points defined!")
		return

	# Pick a random spawn point
	var spawn = spawn_points[randi() % spawn_points.size()]
	print("Spawning goblin at: ", spawn.position)

	# Spawn enemy
	var goblin = goblin_scene.instantiate()
	goblin.position = spawn.position
	add_child(goblin)
