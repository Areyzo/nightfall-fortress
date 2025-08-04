extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var wood_scene = preload("res://scenes/collectables/stone.tscn")
var health = 3

var item_dropped = false 

func _ready() -> void:
	add_to_group("trees")
	
func _process(_delta: float) -> void:
	if health <= 0:
		_death()
	
func _death():
	if health > 0 : return
	animated_sprite_2d.play("death")
	print("Dying at position: ", position)
	set_physics_process(false)
	
	# Spawn wood at death position
	if not item_dropped:
		item_dropped = true
		var target_node = get_parent().get_parent().get_node("Gametilemap/collectables")
		var wood_instance = wood_scene.instantiate()
		wood_instance.position = position
		target_node.add_child(wood_instance)

	
	await get_tree().create_timer(3.0).timeout
	queue_free()
	
	
func get_hit(playerDirectionX):
	animated_sprite_2d.flip_h = playerDirectionX == 1
	animated_sprite_2d.play("chop")
	health -= 1
	print(health)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("idle")
