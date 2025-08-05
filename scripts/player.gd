extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d = $flip/AnimatedSprite2D
@onready var damage_box = $flip/damagebox
@onready var flip = $flip
@export var  SPEED: int = 150
@export var maxhealth: int = 100  # Increased from 3 to 100 for better combat
@export var inventory: Inventory
var current_health: int
var doChop = false
var targets_hit_this_attack = []  # Track what we've hit during current attack

# Signals
signal player_died

@onready var health_bar = $TextureProgressBar


func _ready() :
	current_health = maxhealth
	_update_health_bar()
	add_to_group("player")
	


func _physics_process(_delta):
	if Input.is_action_just_pressed("attack"):
		print_debug("Do chop called")
		_do_chop()
		
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	if direction:
		velocity = direction.normalized() * SPEED  # Fixed: added .normalized()
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
	targets_hit_this_attack.clear()  # Clear hit list for new attack
	animated_sprite_2d.play("chop")
	print_debug("Starting attack animation")

func _hit_target():
	var targets = damage_box.get_overlapping_bodies()
	
	print_debug("Damage box overlapping bodies: ", targets.size())
	for body in targets:
		print_debug("  - ", body.name, " (groups: ", body.get_groups(), ")")
	
	# Method 1: Check Area2D overlapping bodies
	var hit_something = false
	for collisionBody in targets:
		if collisionBody == self:  # Don't hit yourself
			continue
			
		# Skip if we already hit this target during this attack
		if collisionBody in targets_hit_this_attack:
			print_debug("Already hit ", collisionBody.name, " during this attack")
			continue
			
		print_debug("Checking target: ", collisionBody.name)
		
		# Check if it's a tree
		if collisionBody.is_in_group("trees"):
			print_debug("Hitting tree: ", collisionBody.name)
			if collisionBody.has_method("get_hit"):
				collisionBody.get_hit(flip.scale.x)
				targets_hit_this_attack.append(collisionBody)  # Add to hit list
				hit_something = true
		
		# Check if it's an enemy (slime, goblin, etc.)
		elif collisionBody.is_in_group("enemies"):
			if collisionBody.has_method("take_damage"):
				collisionBody.take_damage(25)  # Reduced damage: 25 per hit
				targets_hit_this_attack.append(collisionBody)  # Add to hit list
				print_debug("Player attacked enemy ", collisionBody.name, " for 25 damage!")
				hit_something = true
			else:
				print_debug("Enemy ", collisionBody.name, " doesn't have take_damage method!")
		else:
			print_debug("Target ", collisionBody.name, " is not in trees or enemies group")
	
	# Method 2: Backup proximity check for enemies (in case Area2D fails)
	if not hit_something:
		print_debug("No hits from Area2D, checking proximity...")
		var attack_range = 60  # Attack range in pixels
		var enemies = get_tree().get_nodes_in_group("enemies")
		
		for enemy in enemies:
			if enemy == self or not is_instance_valid(enemy):
				continue
				
			# Skip if we already hit this enemy during this attack
			if enemy in targets_hit_this_attack:
				continue
				
			var distance = global_position.distance_to(enemy.global_position)
			print_debug("Enemy ", enemy.name, " distance: ", distance)
			
			if distance <= attack_range:
				# Check if enemy is in front of player (basic direction check)
				var direction_to_enemy = (enemy.global_position - global_position).normalized()
				var player_facing = Vector2(flip.scale.x, 0).normalized()
				var dot_product = direction_to_enemy.dot(player_facing)
				
				if dot_product > 0.3:  # Enemy is roughly in front of player
					if enemy.has_method("take_damage"):
						enemy.take_damage(25)  # Reduced damage: 25 per hit
						targets_hit_this_attack.append(enemy)  # Add to hit list
						print_debug("Proximity attack hit enemy ", enemy.name, " for 25 damage!")
						hit_something = true
	
	if not hit_something:
		print_debug("No targets hit by attack")

func _on_animated_sprite_2d_animation_finished() -> void:
	doChop = false
	targets_hit_this_attack.clear()  # Clear hit list when attack ends
	print_debug("animation ended")
	animated_sprite_2d.play("idle")

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d == null:
		return
	
	var frame = animated_sprite_2d.frame
	if animated_sprite_2d.animation == "chop":
		# Check for hits on multiple frames to catch moving enemies
		if frame >= 2 and frame <= 4:  # Frames 2, 3, and 4
			_hit_target()
			print_debug("Attack check on frame: ", frame)

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
	
	# Emit death signal
	player_died.emit()
	
	# Clear inventory on death
	clear_inventory()
	
	# Add death logic here (restart level, show game over screen, etc.)
	get_tree().reload_current_scene()

func clear_inventory() -> void:
	"""Clear all items from the player's inventory"""
	if inventory and inventory.slots:
		print_debug("Clearing inventory on death...")
		for slot in inventory.slots:
			if slot:
				slot.item = null
				slot.amount = 0
		inventory.updated.emit()
		print_debug("Inventory cleared!")
	else:
		print_debug("No inventory to clear")

func heal(amount: int) -> void:
	current_health += amount
	current_health = min(current_health, maxhealth)  # Don't exceed max health
	_update_health_bar()
	print_debug("Player healed " + str(amount) + " health. Health: " + str(current_health) + "/" + str(maxhealth))

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		for area in $InteractionCheck.get_overlapping_areas():
			var npc = area.get_parent()
			if npc.has_method("interact"):
				npc.interact()
