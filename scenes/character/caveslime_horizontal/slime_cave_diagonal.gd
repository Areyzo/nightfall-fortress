extends CharacterBody2D

@onready func update_health_bar():
	if hp_bar != null:
		print("Updating diagonal slime health bar - Current HP: ", health, " Max HP: ", max_health)
		# Direct value setting for TextureProgressBar
		var health_percentage = (float(health) / float(max_health)) * 100.0
		hp_bar.value = health_percentage
		hp_bar.visible = true
		print("Diagonal Slime health bar updated: ", health_percentage, "%")
	else:
		print("ERROR: Diagonal slime hp_bar is null!")ed_sprite_2d = $AnimatedSprite2D
@onready var hp_bar = $"../AnimatedSprite2D/TextureProgressBar"  # Correct path from scene
@onready var path_follow = get_parent()  # Get the PathFollow2D parent

const SPEED = 20
const ATTACK_DAMAGE = 20  # 20 damage per attack to player
const ATTACK_COOLDOWN = 2.5 # seconds

var attack_timer = 0.0
var max_health = 50  # Takes 2 hits to kill (25 damage each from player)
var health = max_health	
var player: Node2D = null
var is_dead = false
var last_position: Vector2
var facing_direction = 1  # 1 = right, -1 = left

func take_damage(amount):
	health -= amount
	health = clamp(health, 0, max_health)
	print("Diagonal Slime took ", amount, " damage! Current HP: ", health)
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
			print("Path Slime health bar updated: ", health_percentage, "%")

func die():
	is_dead = true
	print("Path Slime died!")
	
	# Stop all movement and AI immediately
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	# Stop path following
	if path_follow != null and path_follow.has_method("set_physics_process"):
		path_follow.set_physics_process(false)
	
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
	
	print("Death animation complete, removing path slime")
	# Remove the entire PathFollow2D parent (which includes this slime)
	if path_follow != null:
		path_follow.queue_free()
	else:
		queue_free()

func _ready():
	add_to_group("slimes")
	add_to_group("enemies")  # So player can damage slimes
	print("Path Slime added to groups: slimes, enemies")
	print("Path Slime collision layer: ", collision_layer, " mask: ", collision_mask)
	
	# Debug: Check what animations are available
	if animated_sprite_2d != null and animated_sprite_2d.sprite_frames != null:
		print("Path Slime available animations: ", animated_sprite_2d.sprite_frames.get_animation_names())
	else:
		print("Path Slime: No AnimatedSprite2D or sprite_frames found!")
	
	# Initialize health bar
	update_health_bar()
	
	# Store starting position for direction calculation
	last_position = global_position
	
	# Try to find the player for attack detection
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		print("Path Slime found player for attack detection: ", player.name)
	
	# Start with idle animation
	if animated_sprite_2d != null:
		animated_sprite_2d.play("idle")

func _physics_process(delta):
	if is_dead:
		return  # Skip all logic if slime is dead

	# Calculate movement direction based on position change
	var current_position = global_position
	var movement_direction = current_position - last_position
	var movement_speed = movement_direction.length()
	
	print("Movement speed: ", movement_speed, " Direction: ", movement_direction)
	
	# Update facing direction and animation based on movement
	if movement_speed > 0.01:  # Much lower threshold for path movement detection
		print("Slime is moving!")
		
		# Update facing direction based on horizontal movement
		if abs(movement_direction.x) > 0.001:  # Very small threshold
			if movement_direction.x > 0:
				facing_direction = 1  # Moving right
				print("Moving right")
			else:
				facing_direction = -1  # Moving left
				print("Moving left")
			
			# Flip sprite based on movement direction
			if facing_direction < 0:
				scale.x = -abs(scale.x)  # Face left
			else:
				scale.x = abs(scale.x)   # Face right
		
		# Use running animation when moving
		if animated_sprite_2d != null:
			if animated_sprite_2d.sprite_frames != null and animated_sprite_2d.sprite_frames.has_animation("run"):
				print("Playing run animation")
				animated_sprite_2d.play("run")
			elif animated_sprite_2d.sprite_frames != null and animated_sprite_2d.sprite_frames.has_animation("walk"):
				print("Playing walk animation")
				animated_sprite_2d.play("walk")
			else:
				print("No run/walk animation, using idle")
				animated_sprite_2d.play("idle")  # Fallback
	else:
		print("Slime is idle")
		# Use idle animation when not moving much
		if animated_sprite_2d != null:
			animated_sprite_2d.play("idle")
	
	# Update last position for next frame
	last_position = current_position
	
	# Handle collision damage with player
	attack_timer -= delta
	if attack_timer <= 0:
		# Method 1: Check slide collisions
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null and collider.is_in_group("player"):
				collider.take_damage(ATTACK_DAMAGE)
				attack_timer = ATTACK_COOLDOWN
				print("Path Slime touched player for ", ATTACK_DAMAGE, " damage!")
				break
		
		# Method 2: Check proximity fallback
		if attack_timer <= 0:  # Only if we didn't already damage
			if get_tree() != null:
				var players = get_tree().get_nodes_in_group("player")
				for player_node in players:
					if player_node != null and is_instance_valid(player_node):
						var distance = global_position.distance_to(player_node.global_position)
						if distance <= 30:  # Close enough to be "touching"
							player_node.take_damage(ATTACK_DAMAGE)
							attack_timer = ATTACK_COOLDOWN
							print("Path Slime close to player for ", ATTACK_DAMAGE, " damage! Distance: ", distance)
							break

	move_and_slide()
