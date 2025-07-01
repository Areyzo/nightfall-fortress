extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D

const SPEED = 50
const DETECTION_RANGE = 400
const PATH_UPDATE_INTERVAL = 0.3

var player: Node2D = null
var is_chasing = false
var path_timer = 0.0

func _ready():
	add_to_group("goblins")

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
	# Try to find player if we haven't found one yet
	if player == null or !is_instance_valid(player):
		if path_timer <= 0:  # Only search occasionally to avoid performance issues
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				player = players[0]
				print("Goblin found player: ", player.name)
		path_timer = PATH_UPDATE_INTERVAL  # Reset timer
		
		# If still no player, just idle
		if player == null:
			velocity = Vector2.ZERO
			animated_sprite_2d.play("idle")
			return
	
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
	# Repel nearby goblins
	for other in get_tree().get_nodes_in_group("goblins"):
		if other == self:
			continue
		if not is_instance_valid(other):
			continue

		var separation = global_position - other.global_position
		var distance = separation.length()

		if distance > 0 and distance < 24:  # Adjust based on goblin size
			velocity += separation.normalized() * ((24 - distance) / 24.0) * 40


func update_target_position():
	if player != null and is_instance_valid(player):
		navigation_agent.target_position = player.global_position
