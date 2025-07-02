extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var health = 3

func _ready() -> void:
	add_to_group("trees")
	
func _process(delta: float) -> void:
	if health <= 0:
		_death()

func _death():
	if health > 0 : return
	animated_sprite_2d.play("death")
	if get_parent().has_method("get_all_tree_states"):
		var states = get_parent().get_all_tree_states()
		print("⚠️ Tree '%s' died. Current all tree states: %s" % [name, states])
	#add hide func
	
	
func get_hit(playerDirectionX):
	animated_sprite_2d.flip_h = playerDirectionX == 1
	animated_sprite_2d.play("chop")
	health -= 1
	print(health)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("idle")
	
func get_state():
	return "dead"
