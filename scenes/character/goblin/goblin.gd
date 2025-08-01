extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var hp_bar = $HpBar

const SPEED = 50
const DETECTION_RANGE = 400
const PATH_UPDATE_INTERVAL = 0.3
const ATTACK_RANGE = 30
const ATTACK_DAMAGE = 5
const ATTACK_COOLDOWN = 3.0 # seconds
const REPEL_DISTANCE = 30
const REPEL_FORCE = 50

var attack_timer = 0.0
var max_health = 100
var health = max_health	
var player: Node2D = null
var is_chasing = false
var path_timer = 0.0
var is_dead = false
 
func take_damage(amount):
	health -= amount
	health = clamp(health, 0, max_health)
	print("Goblin took ", amount, " damage! Current HP: ", health)
	update_health_bar()
	   
	if health <= 0:
		die()

func update_health_bar():
		hp_bar.value = health

func die():
	is_dead = true
	print("Goblin died!")
	
	# Play death animation if available
	if animated_sprite_2d.sprite_frames.has_animation("death"):
		animated_sprite_2d.play("death")
	else:
		animated_sprite_2d.play("idle")  # Fallback
	
	# Stop all movement and AI
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	# Remove from collision but keep visible briefly
	set_collision_layer(0)
	set_collision_mask(0)
	
	# Remove after a short delay
	await get_tree().create_timer(1.0).timeout
	queue_free()

	
		
func _ready():
	add_to_group("goblins")
	add_to_group("enemies")  # So player can damage goblins
	update_health_bar()
	# Check if NavigationAgent2D exists
	if navigation_agent == null:
		print("Error: NavigationAgent2D not found in goblin scene!")
		return
	
	# Setup navigation agent
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	navigation_agent.max_speed = SPEED
	
	# Try to find the player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		# Alternative search methods
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			# Search in current scene
			var current_scene = get_tree().current_scene
			player = find_player_in_node(current_scene)
	
	# Check if player was found
	if player == null or !is_instance_valid(player):
		print("Goblin failed to find player!")
		# Don't queue_free immediately, keep trying
	else:
		print("Goblin found player: ", player.name)
	
	# Wait a frame to let navigation initialize
	await get_tree().process_frame
	update_target_position()

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
		return  # Skip all logic if goblin is dead

	# Try to find player if we haven't found one yet
	if player == null or !is_instance_valid(player):
		if path_timer <= 0:
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				player = players[0]
				print("Goblin found player: ", player.name)
		path_timer = PATH_UPDATE_INTERVAL
		
		if player == null:
			velocity = Vector2.ZERO
			animated_sprite_2d.play("idle")
			return
	
	# ... rest of your existing code ...

	
	path_timer += delta
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var should_chase = distance_to_player <= DETECTION_RANGE
	
	# State transitions
	if should_chase and not is_chasing:
		is_chasing = true
		print("Goblin started chasing player")
	elif not should_chase and is_chasing:
		is_chasing = false
		velocity = Vector2.ZERO
		animated_sprite_2d.play("idle")
		print("Goblin stopped chasing - player too far")
		return
	
	# If not chasing, just idle
	if not is_chasing:
		velocity = Vector2.ZERO
		animated_sprite_2d.play("idle")
		return
	
	# Update path periodically
	if path_timer >= PATH_UPDATE_INTERVAL:
		path_timer = 0.0
		update_target_position()
	
	# Move towards target
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		animated_sprite_2d.play("idle")
	else:
		var next_path_position = navigation_agent.get_next_path_position()
		var direction = (next_path_position - global_position).normalized()
		velocity = direction * SPEED
		
		# Flip sprite based on movement direction
		if direction.x < -0.1:
			scale.x = -abs(scale.x)  # Face left
		elif direction.x > 0.1:
			scale.x = abs(scale.x)   # Face right
		
		animated_sprite_2d.play("run")
	
	move_and_slide()
		# After movement logic
	attack_timer -= delta
	if is_chasing and attack_timer <= 0 and player != null and is_instance_valid(player):
		distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= ATTACK_RANGE:
			player.take_damage(ATTACK_DAMAGE)
			attack_timer = ATTACK_COOLDOWN

	# Repel nearby goblins (prevent stacking and overcrowding)
	var repel_force = Vector2.ZERO
	var nearby_goblins = 0
	
	for other in get_tree().get_nodes_in_group("goblins"):
		if other == self:
			continue
		if not is_instance_valid(other):
			continue

		var separation = global_position - other.global_position
		var distance = separation.length()

		if distance > 0 and distance < 30:  # Repel distance
			nearby_goblins += 1
			var push_strength = ((30 - distance) / 30.0) * 50
			repel_force += separation.normalized() * push_strength
	
	# Apply repel force with limits to prevent chaos
	if repel_force.length() > 0:
		var max_repel = min(80, repel_force.length())  # Cap the force
		velocity += repel_force.normalized() * max_repel
		
		# Reduce normal movement speed when crowded
		if nearby_goblins >= 3:
			velocity *= 0.7  # Slow down in crowds


func update_target_position():
	if player != null and is_instance_valid(player):
		navigation_agent.target_position = player.global_position
