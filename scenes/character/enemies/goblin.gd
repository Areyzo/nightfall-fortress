extends CharacterBody2D

@onready var animated_sprite_2d = $flip/AnimatedSprite2D
@onready var flip = $flip

const SPEED = 150
const DETECTION_RANGE = 400
var player: Node2D

func _ready():
	# Method 1: Get player from spawner (most reliable)
	if get_parent().has_method("get_player_reference"):
		player = get_parent().get_player_reference()
	
	# Method 2: Find by path (update "Main/Player" to your actual path)
	if player == null:
		player = get_node("/root/Main/Player") 
	
	# Method 3: Find by group (make sure player is in "player" group)
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
	
	if player == null:
		printerr("Goblin failed to find player!")
		queue_free()

func _physics_process(delta):
	if player == null:
		return
	
	# Only chase if player is within range
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > DETECTION_RANGE:
		animated_sprite_2d.play("idle")
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED
	
	# Flip sprite based on movement
	flip.scale.x = -1 if direction.x < 0 else 1
	
	# Animation control
	if velocity.length() > 10:  # Small threshold to prevent jitter
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	move_and_slide()
