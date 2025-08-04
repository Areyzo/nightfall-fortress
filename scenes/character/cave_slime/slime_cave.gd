extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var hp_bar = $HpBar

const SPEED = 20
const DETECTION_RANGE = 80  # Much shorter range, only for attack detection
const ATTACK_RANGE = 25
const ATTACK_DAMAGE = 20  # 20 damage per attack to player
const ATTACK_COOLDOWN = 2.5 # seconds
const REPEL_DISTANCE = 25
const REPEL_FORCE = 40
const WANDER_RANGE = 100  # How far slime can wander from spawn point
const WANDER_WAIT_TIME = 3.0  # Time to wait before choosing new wander target

var attack_timer = 0.0
var max_health = 50  # Reduced to 50 so it takes 2 hits (25 damage each)
var health = max_health	
var player: Node2D = null
var is_dead = false
var spawn_position: Vector2
var wander_target: Vector2
var wander_timer = 0.0
var is_wandering = false

func take_damage(amount):
	health -= amount
	health = clamp(health, 0, max_health)
	print("Slime took ", amount, " damage! Current HP: ", health)
	update_health_bar()
	
	if health <= 0:
		die()  # Go straight to death - no hurt animation when dying
		return
		
	# Play hurt animation only if not dying (with proper null checks)
	if animated_sprite_2d != null and animated_sprite_2d.sprite_frames != null:
		if animated_sprite_2d.sprite_frames.has_animation("hurt"):
			animated_sprite_2d.play("hurt")
			await get_tree().create_timer(0.3).timeout

func update_health_bar():
	if hp_bar != null:
		# Call the health bar's update function
		if hp_bar.has_method("update_health"):
			hp_bar.update_health(health, max_health)
		else:
			# Fallback to direct value setting
			var health_percentage = (float(health) / float(max_health)) * 100.0
			hp_bar.value = health_percentage
			print("Slime health bar updated: ", health_percentage, "%")

func die():
	is_dead = true
	print("Slime died!")
	
	# Stop all movement and AI immediately
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	# Remove from collision but keep visible for death animation
	set_collision_layer(0)
	set_collision_mask(0)
	
	# Debug: Print available animations
	if animated_sprite_2d != null and animated_sprite_2d.sprite_frames != null:
		print("Available animations: ", animated_sprite_2d.sprite_frames.get_animation_names())
	
	# Play death animation if available (with proper null checks)
	if animated_sprite_2d != null and animated_sprite_2d.sprite_frames != null:
		var animation_played = false
		
		# Try "death" first (lowercase)
		if animated_sprite_2d.sprite_frames.has_animation("death"):
			print("Playing 'death' animation")
			animated_sprite_2d.stop()
			animated_sprite_2d.play("death")
			var frame_count = animated_sprite_2d.sprite_frames.get_frame_count("death")
			var fps = animated_sprite_2d.sprite_frames.get_animation_speed("death")
			var animation_duration = frame_count / fps
			print("Death animation: ", frame_count, " frames at ", fps, " FPS = ", animation_duration, " seconds")
			await get_tree().create_timer(animation_duration).timeout
			animation_played = true
		# Try "Death" (capitalized)
		elif animated_sprite_2d.sprite_frames.has_animation("Death"):
			print("Playing 'Death' animation")
			animated_sprite_2d.stop()
			animated_sprite_2d.play("Death")
			var frame_count = animated_sprite_2d.sprite_frames.get_frame_count("Death")
			var fps = animated_sprite_2d.sprite_frames.get_animation_speed("Death")
			var animation_duration = frame_count / fps
			print("Death animation: ", frame_count, " frames at ", fps, " FPS = ", animation_duration, " seconds")
			await get_tree().create_timer(animation_duration).timeout
			animation_played = true
		# Try "dead" (alternative name)
		elif animated_sprite_2d.sprite_frames.has_animation("dead"):
			print("Playing 'dead' animation")
			animated_sprite_2d.stop()
			animated_sprite_2d.play("dead")
			var frame_count = animated_sprite_2d.sprite_frames.get_frame_count("dead")
			var fps = animated_sprite_2d.sprite_frames.get_animation_speed("dead")
			var animation_duration = frame_count / fps
			print("Dead animation: ", frame_count, " frames at ", fps, " FPS = ", animation_duration, " seconds")
			await get_tree().create_timer(animation_duration).timeout
			animation_played = true
		else:
			print("No death animation found! Playing idle as fallback")
			animated_sprite_2d.play("idle")
			await get_tree().create_timer(1.0).timeout
			animation_played = true
			
		if not animation_played:
			print("No animation could be played")
			await get_tree().create_timer(1.0).timeout
	else:
		print("No AnimatedSprite2D or sprite_frames available")
		await get_tree().create_timer(1.0).timeout
	
	print("Death animation complete, removing slime")
	# Remove after animation is complete
	queue_free()

func _ready():
	add_to_group("slimes")
	add_to_group("enemies")  # So player can damage slimes
	print("Slime added to groups: slimes, enemies")
	print("Slime collision layer: ", collision_layer, " mask: ", collision_mask)
	
	# Initialize health bar
	update_health_bar()
	
	# Store spawn position for wandering
	spawn_position = global_position
	wander_target = spawn_position
	
	# Check if NavigationAgent2D exists
	if navigation_agent == null:
		print("Warning: NavigationAgent2D not found in slime scene! Slime will be stationary.")
	else:
		# Setup navigation agent for wandering
		navigation_agent.path_desired_distance = 4.0
		navigation_agent.target_desired_distance = 4.0
		navigation_agent.max_speed = SPEED
	
	# Try to find the player for attack detection only
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			var current_scene = get_tree().current_scene
			player = find_player_in_node(current_scene)
	
	if player != null:
		print("Slime found player for attack detection: ", player.name)
	
	# Start wandering behavior
	choose_new_wander_target()

func find_player_in_node(node: Node) -> Node2D:
	# Recursively search for player
	if node.name.to_lower().contains("player"):
		return node as Node2D
	
	for child in node.get_children():
		var result = find_player_in_node(child)
		if result != null:
			return result
	
	return null

func _physics_process(delta):
	if is_dead:
		return  # Skip all logic if slime is dead

	# Handle simple wandering behavior
	wander_timer += delta
	
	# Normal wandering behavior
	if navigation_agent != null:
		if wander_timer >= WANDER_WAIT_TIME:
			choose_new_wander_target()
			wander_timer = 0.0
		
		# Move towards wander target
		if navigation_agent.is_navigation_finished():
			velocity = Vector2.ZERO
			is_wandering = false
		else:
			var next_path_position = navigation_agent.get_next_path_position()
			var direction = (next_path_position - global_position).normalized()
			velocity = direction * SPEED
			is_wandering = true
			
			# Flip sprite based on movement direction
			if direction.x < -0.1:
				scale.x = -abs(scale.x)  # Face left
			elif direction.x > 0.1:
				scale.x = abs(scale.x)   # Face right
		
		# Always use idle animation
		if animated_sprite_2d != null:
			animated_sprite_2d.play("idle")
	else:
		# No navigation agent, just stay still
		velocity = Vector2.ZERO
		if animated_sprite_2d != null:
			animated_sprite_2d.play("idle")
	
	move_and_slide()
	
	# Simple collision damage - if player touches slime, deal damage
	attack_timer -= delta
	if attack_timer <= 0:
		# Method 1: Check slide collisions
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			print("Slime collision detected with: ", collider.name if collider else "null")
			if collider != null and collider.is_in_group("player"):
				collider.take_damage(ATTACK_DAMAGE)
				attack_timer = ATTACK_COOLDOWN
				print("Slime touched player for ", ATTACK_DAMAGE, " damage!")
				break
		
		# Method 2: Check all bodies in the scene for proximity (fallback)
		if attack_timer <= 0:  # Only if we didn't already damage
			if get_tree() != null:
				var players = get_tree().get_nodes_in_group("player")
				for player_node in players:
					if player_node != null and is_instance_valid(player_node):
						var distance = global_position.distance_to(player_node.global_position)
						if distance <= 30:  # Close enough to be "touching"
							player_node.take_damage(ATTACK_DAMAGE)
							attack_timer = ATTACK_COOLDOWN
							print("Slime close to player for ", ATTACK_DAMAGE, " damage! Distance: ", distance)
							break

	# Repel nearby slimes (prevent stacking and overcrowding)
	var repel_force = Vector2.ZERO
	var nearby_slimes = 0
	
	# Check if we're still in the tree before trying to access other nodes
	if get_tree() == null:
		return
	
	for other in get_tree().get_nodes_in_group("slimes"):
		if other == self:
			continue
		if not is_instance_valid(other):
			continue

		var separation = global_position - other.global_position
		var distance = separation.length()

		if distance > 0 and distance < REPEL_DISTANCE:
			nearby_slimes += 1
			var push_strength = ((REPEL_DISTANCE - distance) / REPEL_DISTANCE) * REPEL_FORCE
			repel_force += separation.normalized() * push_strength
	
	# Apply repel force with limits to prevent chaos
	if repel_force.length() > 0:
		var max_repel = min(40, repel_force.length())  # Cap the force (lower than before)
		velocity += repel_force.normalized() * max_repel

func choose_new_wander_target():
	if navigation_agent == null:
		return
		
	# Choose a random point within wander range of spawn position
	var angle = randf() * TAU  # Random angle
	var distance = randf() * WANDER_RANGE  # Random distance within range
	
	wander_target = spawn_position + Vector2(cos(angle), sin(angle)) * distance
	navigation_agent.target_position = wander_target
