extends CharacterBody2D

# Node references
@onready var animated_sprite_2d = $flip/AnimatedSprite2D
@onready var damage_box = $flip/damagebox
@onready var flip = $flip
@onready var hp_bar = $UI/HPbar

# Movement constants
const SPEED = 150.0
const FRICTION = 800.0

# State variables
var is_attacking = false
var facing_direction = 1  # 1 = right, -1 = left

# Health system
@export var max_health = 100
var current_health : int
signal health_changed(new_health)
signal player_died

# Inventory system
@export var inventory : Resource  # This will be set in the scene

# Attack system
@export var attack_damage = 50
var attack_cooldown = 0.0
const ATTACK_COOLDOWN_TIME = 0.5

func _ready():
	add_to_group("player")
	current_health = max_health
	update_health_bar()
	
	# Connect health signal for UI updates or other systems
	health_changed.connect(_on_health_changed)

func _physics_process(delta):
	handle_input()
	handle_movement(delta)
	handle_attack_cooldown(delta)
	set_animation()
	move_and_slide()

func handle_input():
	# Attack input
	if Input.is_action_just_pressed("attack") and not is_attacking and attack_cooldown <= 0:
		do_chop()

func handle_movement(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
		# Update facing direction
		if direction.x != 0:
			facing_direction = sign(direction.x)
	else:
		# Apply friction
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

func handle_attack_cooldown(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta

func set_animation():
	# Set sprite direction
	flip.scale.x = facing_direction
	
	# Don't change animation if attacking
	if is_attacking:
		return
	
	# Set movement animations
	if velocity.length() > 10:  # Small threshold to prevent jitter
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func do_chop():
	if is_attacking:
		return
	
	is_attacking = true
	attack_cooldown = ATTACK_COOLDOWN_TIME
	animated_sprite_2d.play("chop")
	print_debug("Player attacking!")

func hit_targets():
	var targets = damage_box.get_overlapping_bodies()
	
	if targets.is_empty():
		print_debug("No targets in range")
		return
	
	for target in targets:
		if target == self:  # Don't hit yourself
			continue
			
		if target.has_method("get_hit") and target.is_in_group("trees"):
			target.get_hit(facing_direction)
			print_debug("Hit tree: ", target.name)
		elif target.has_method("take_damage") and target.is_in_group("enemies"):
			target.take_damage(attack_damage)
			print_debug("Hit enemy: ", target.name, " for ", attack_damage, " damage")

func take_damage(amount: int):
	if current_health <= 0:  # Already dead
		return
		
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	
	health_changed.emit(current_health)
	print("Player took ", amount, " damage! Current HP: ", current_health)
	
	# Add hit effect here (screen shake, sound, etc.)
	
	if current_health <= 0:
		die()

func heal(amount: int):
	if current_health >= max_health:
		return
		
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	health_changed.emit(current_health)
	print("Player healed for ", amount, "! Current HP: ", current_health)

func update_health_bar():
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = current_health

func die():
	print("Player died!")
	player_died.emit()
	# Add death animation/effect here
	# For now, just disable the player
	set_physics_process(false)
	# You might want to transition to game over scene instead
	# get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func respawn(spawn_position: Vector2 = Vector2.ZERO):
	"""Respawn the player at given position with full health"""
	global_position = spawn_position
	current_health = max_health
	health_changed.emit(current_health)
	set_physics_process(true)
	is_attacking = false
	attack_cooldown = 0
	animated_sprite_2d.play("idle")

# Inventory methods (if you want to use the inventory system)
func add_item_to_inventory(item):
	if inventory and inventory.has_method("add_item"):
		return inventory.add_item(item)
	return false

func remove_item_from_inventory(item):
	if inventory and inventory.has_method("remove_item"):
		return inventory.remove_item(item)
	return false

# Signal callbacks
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "chop":
		is_attacking = false
		print_debug("Attack animation finished")
		animated_sprite_2d.play("idle")

func _on_animated_sprite_2d_frame_changed():
	# Hit targets on specific frame of attack animation
	if animated_sprite_2d.animation == "chop" and animated_sprite_2d.frame == 3:
		hit_targets()

func _on_health_changed(new_health):
	update_health_bar()
	# Add any other health-related effects here
