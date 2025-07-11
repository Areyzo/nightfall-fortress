extends CharacterBody2D

@onready var animated_sprite_2d = $flip/AnimatedSprite2D
@onready var damage_box = $flip/damagebox
@onready var flip = $flip

const SPEED = 150
var doChop = false

func _ready():
	# Add player to group so goblins can find it
	add_to_group("player")

func _physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		print_debug("Do chop called")
		_do_chop()
		
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	_set_animation()
	move_and_slide()

func _set_animation():
	if velocity.x < 0:
		flip.scale.x = -1
	elif velocity.x > 0: 
		flip.scale.x = 1
	if doChop: return
	
	if velocity:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func _do_chop():
	if doChop:
		return
		
	doChop = true
	animated_sprite_2d.play("chop")

func _hit_tree():
	var hasCollision = len(damage_box.get_overlapping_bodies()) > 0
	if not hasCollision:
		return
	var collisionBody = damage_box.get_overlapping_bodies()[0]
	
	if collisionBody in get_tree().get_nodes_in_group("trees"):
		collisionBody.get_hit(flip.scale.x)

func _on_animated_sprite_2d_animation_finished() -> void:
	doChop = false
	print_debug("animation ended")
	animated_sprite_2d.play("idle")

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d == null:
		return
	
	var frame = animated_sprite_2d.frame
	if animated_sprite_2d.animation == "chop" && frame == 3:
		_hit_tree()
