extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hp_bar = $Hp_slime_diagonal# Correct name from scene
@onready var path_follow = get_parent()  # Get the PathFollow2D parent

const ATTACK_DAMAGE = 20  # 20 damage per attack to player
const ATTACK_COOLDOWN = 2.5 # seconds

var attack_timer = 0.0
var max_health = 50  # Takes 2 hits to kill (25 damage each from player)
var health = max_health	
var player: Node2D = null
var is_dead = false

func take_damage(amount):
	health -= amount
	health = clamp(health, 0, max_health)
	print("Horizontal Slime took ", amount, " damage! Current HP: ", health)
	update_health_bar()
	
	if health <= 0:
		die()  # Go straight to death - no hurt animation when dying
		return
		
	# Play hurt animation only if not dying (with proper null checks)
	if animated_sprite_2d != null and animated_sprite_2d.sprite_frames != null:
		if animated_sprite_2d.sprite_frames.has_animation("hurt"):
			animated_sprite_2d.play("hurt")
			await get_tree().create_timer(0.3).timeout
			# Return to idle animation
			animated_sprite_2d.play("idle")

func update_health_bar():
	if hp_bar != null:
		print("Updating horizontal slime health bar - Current HP: ", health, " Max HP: ", max_health)
		# Call the health bar's update function
		if hp_bar.has_method("update_health"):
			hp_bar.update_health(health, max_health)
		else:
			# Fallback to direct value setting
			var health_percentage = (float(health) / float(max_health)) * 100.0
			hp_bar.value = health_percentage
			hp_bar.visible = true
			print("Horizontal Slime health bar updated (fallback): ", health_percentage, "%")
	else:
		print("ERROR: Horizontal slime hp_bar is null!")

func die():
	is_dead = true
	print("Horizontal Slime died!")
	
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
		
		# Try death animations
		if animated_sprite_2d.sprite_frames.has_animation("death"):
			print("Playing 'death' animation")
			animated_sprite_2d.stop()
			animated_sprite_2d.play("death")
			var frame_count = animated_sprite_2d.sprite_frames.get_frame_count("death")
			var fps = animated_sprite_2d.sprite_frames.get_animation_speed("death")
			var animation_duration = frame_count / fps
			await get_tree().create_timer(animation_duration).timeout
			animation_played = true
		else:
			print("No death animation found! Using current direction animation as fallback")
			await get_tree().create_timer(1.0).timeout
			animation_played = true
			
		if not animation_played:
			print("No animation could be played")
			await get_tree().create_timer(1.0).timeout
	else:
		print("No AnimatedSprite2D or sprite_frames available")
		await get_tree().create_timer(1.0).timeout
	
	print("Death animation complete, removing horizontal slime")
	# Remove the entire PathFollow2D parent (which includes this slime)
	if path_follow != null:
		path_follow.queue_free()
	else:
		queue_free()

func _ready():
	add_to_group("slimes")
	add_to_group("enemies")  # So player can damage slimes
	print("Horizontal Slime added to groups: slimes, enemies")
	print("Horizontal Slime collision layer: ", collision_layer, " mask: ", collision_mask)
	
	# Debug: Check what animations are available
	if animated_sprite_2d != null and animated_sprite_2d.sprite_frames != null:
		print("Horizontal Slime available animations: ", animated_sprite_2d.sprite_frames.get_animation_names())
	else:
		print("Horizontal Slime: No AnimatedSprite2D or sprite_frames found!")
	
	# Initialize health bar
	update_health_bar()
	
	# Try to find the player for attack detection
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		print("Horizontal Slime found player for attack detection: ", player.name)
	
	# Start with idle animation (simple, no direction changes)
	if animated_sprite_2d != null:
		animated_sprite_2d.play("idle")

func _physics_process(delta):
	if is_dead:
		return  # Skip all logic if slime is dead

	# Simple idle animation - no direction changes
	if animated_sprite_2d != null:
		if animated_sprite_2d.animation != "idle" and animated_sprite_2d.animation != "hurt" and animated_sprite_2d.animation != "death":
			animated_sprite_2d.play("idle")
	
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
				print("Horizontal Slime touched player for ", ATTACK_DAMAGE, " damage!")
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
							print("Horizontal Slime close to player for ", ATTACK_DAMAGE, " damage! Distance: ", distance)
							break

	move_and_slide()
