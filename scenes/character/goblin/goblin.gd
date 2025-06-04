extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D2D
@onready var navigation_agent = $NavigationAgent2D

const SPEED = 50
const DETECTION_RANGE = 400
const PATH_UPDATE_INTERVAL = 0.3  # Update path every 0.3 seconds

var player: Node2D
var is_chasing = false
var path_timer = 0.0

func _ready():
	# Setup navigation agent
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	navigation_agent.max_speed = SPEED
	
	# Find player by group (most reliable method)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	# Fallback: try to find by sibling relationship
	if player == null:
		player = get_parent().get_node("Player")
	
	if player == null:
		printerr("Goblin failed to find player!")
		queue_free()
		return
	else:
		print("Goblin found player: ", player.name)
	
	# Wait a frame for navigation to be ready
	await get_tree().process_frame
	_update_target_position()

func _physics_process(delta):
	if player == null:
		return
	
	path_timer += delta
	
	# Check if player is within detection range
	var distance_to_player = global_position.distance_to(player.global_position)
	var should_chase = distance_to_player <= DETECTION_RANGE
	
	# Start or stop chasing based on detection
	if should_chase and not is_chasing:
		is_chasing = true
		print("Goblin started chasing player")
	elif not should_chase and is_chasing:
		is_chasing = false
		velocity = Vector2.ZERO
	
		print("Goblin stopped chasing - player too far")
		return
	
	# If not chasing, stay idle
	
	
	# Update path periodically
	if path_timer >= PATH_UPDATE_INTERVAL:
		path_timer = 0.0
		_update_target_position()
	
	# Follow the navigation path
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		
		return
	
	var next_path_position = navigation_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	velocity = direction * SPEED
	
	# Flip sprite based on movement direction
	if direction.x < 0:
		scale.x = -abs(scale.x)  # Face left
	elif direction.x > 0:
		scale.x = abs(scale.x)   # Face right
	
	# Animation control

	
	move_and_slide()

func _update_target_position():
	if player != null:
		navigation_agent.target_position = player.global_position
