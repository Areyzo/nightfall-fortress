extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var health = 3

func _ready() -> void:
	add_to_group("trees")
	
func _process(delta: float) -> void:
	if health <= 0:
		_death()
		print("death")
	
func _death():
	if health > 0 : return
	animated_sprite_2d.play("death")
	
func get_hit(playerDirectionX):
	animated_sprite_2d.flip_h = playerDirectionX == 1
	animated_sprite_2d.play("chop")
	health -= 1
	print(health)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("idle")
