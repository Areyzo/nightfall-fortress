extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d = $flip/AnimatedSprite2D
@onready var damage_box = $flip/damagebox
@onready var flip = $flip
@export var  SPEED: int = 150
@export var maxhealth: int = 3
@export var inventory: Inventory
var current_health: int
var doChop = false

@onready var health_bar = $TextureProgressBar


func _ready() :
	current_health = maxhealth
	_update_health_bar()
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

func get_inventory() -> Inventory:
	return inventory

func take_damage(damage: int) -> void:
	current_health -= damage
	current_health = max(current_health, 0)  # Prevent negative health
	_update_health_bar()
	
	print_debug("Player took " + str(damage) + " damage. Health: " + str(current_health) + "/" + str(maxhealth))
	
	if current_health <= 0:
		_die()

func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = (float(current_health) / float(maxhealth)) * 100.0

func _die() -> void:
	print_debug("Player died!")
	# Add death logic here (restart level, show game over screen, etc.)
	get_tree().reload_current_scene()

func heal(amount: int) -> void:
	current_health += amount
	current_health = min(current_health, maxhealth)  # Don't exceed max health
	_update_health_bar()
	print_debug("Player healed " + str(amount) + " health. Health: " + str(current_health) + "/" + str(maxhealth))
