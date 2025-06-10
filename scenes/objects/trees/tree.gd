# tree.gd - Improved version with better debugging
extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var health = 3
var is_dead = false

# Log drop settings
var log_scene_path = "res://scenes/objects/itemdrop/log.tscn"
var logs_to_drop = 2
var drop_spread = 50.0

func _ready() -> void:
	add_to_group("trees")
	print("Tree ready, health: ", health)
	print("Tree position: ", global_position)

func _process(delta: float) -> void:
	if health <= 0 and not is_dead:
		print("Health is 0, calling _death()")
		_death()

func get_hit(playerDirectionX):
	print("Tree got hit! Health before: ", health)
	animated_sprite_2d.flip_h = playerDirectionX == 1
	animated_sprite_2d.play("chop")
	health -= 1
	print("Health after hit: ", health)

func _death():
	print("_death() function called")
	is_dead = true
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("death")
	
	print("Playing death animation, waiting for finish...")
	# Wait for death animation to complete
	await animated_sprite_2d.animation_finished
	
	print("Death animation finished, calling drop_logs()")
	drop_logs()
	
	# Wait before removing tree
	print("Waiting 3 seconds before removing tree...")
	await get_tree().create_timer(3.0).timeout
	print("Removing tree")
	queue_free()

func drop_logs():
	print("drop_logs() called - will drop ", logs_to_drop, " logs")
	
	# Get the main scene to add logs to
	var main_scene = get_tree().current_scene
	print("Main scene: ", main_scene.name if main_scene else "NULL")
	
	for i in logs_to_drop:
		print("Creating log drop ", i + 1)
		create_log_drop(i, main_scene)

func create_log_drop(index: int, target_parent: Node):
	print("create_log_drop() called for index: ", index)
	
	# Try to load the log scene first
	if ResourceLoader.exists(log_scene_path):
		print("✓ Log scene found! Loading...")
		var log_scene = load(log_scene_path)
		var log_instance = log_scene.instantiate()
		
		# Position with some randomness
		# Position with some randomness
		var offset = Vector2(
		randf_range(-drop_spread, drop_spread),
		randf_range(-20, 20)
		)

# Add to the main scene first
		target_parent.add_child(log_instance)  # ← Add to scene FIRST

# Then set position
		log_instance.global_position = global_position + offset  # ← Set position AFTER
		print("Log positioned at: ", log_instance.global_position)
		
		# Add to the main scene instead of parent
		target_parent.add_child(log_instance)
		print("✓ Log added to main scene successfully")
		
		# Add physics after adding to scene
		if log_instance is RigidBody2D:
			print("✓ Log is RigidBody2D, adding physics")
			# Use call_deferred to ensure physics is applied after scene tree update
			call_deferred("apply_log_physics", log_instance)
		else:
			print("⚠ Log is not RigidBody2D, type is: ", log_instance.get_class())
			
	else:
		print("✗ Log scene not found, creating simple log...")
		create_simple_log(index, target_parent)

func apply_log_physics(log_instance: RigidBody2D):
	log_instance.linear_velocity = Vector2(
		randf_range(-100, 100),
		randf_range(-150, -50)
	)
	log_instance.angular_velocity = randf_range(-5, 5)
	print("✓ Physics applied to log")

func create_simple_log(index: int, target_parent: Node):
	print("create_simple_log() called")
	
	# Create a simple log using RigidBody2D
	var log = RigidBody2D.new()
	log.name = "DroppedLog_" + str(index)
	
	# Create visual component
	var sprite = Sprite2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Try to load log texture, fallback to colored rectangle
	var log_texture_path = "res://scenes/objects/itemdrop/log.png"
	if ResourceLoader.exists(log_texture_path):
		sprite.texture = load(log_texture_path)
		print("✓ Log texture loaded")
	else:
		print("⚠ Log texture not found, creating colored rectangle")
		# Create a simple brown rectangle
		var image = Image.create(32, 16, false, Image.FORMAT_RGB8)
		image.fill(Color(0.6, 0.3, 0.1))  # Brown color
		var texture = ImageTexture.new()
		texture.set_image(image)
		sprite.texture = texture
		print("✓ Created brown rectangle texture")
	
	# Set up collision shape
	shape.size = Vector2(32, 16)
	collision.shape = shape
	
	# Assemble the log
	log.add_child(sprite)
	log.add_child(collision)
	
	# Set collision layers (make sure these match your project settings)
	log.collision_layer = 1  # Default layer
	log.collision_mask = 1   # Collides with default layer
	
	# Position the log
	var offset = Vector2(
		randf_range(-drop_spread, drop_spread),
		randf_range(-20, 20)
	)
	log.global_position = global_position + offset
	print("Log positioned at: ", log.global_position)
	
	# Add to scene first
	target_parent.add_child(log)
	print("✓ Log added to scene")
	
	# Apply physics after adding to scene
	call_deferred("apply_log_physics", log)
	
	# Add to logs group for easy management
	log.add_to_group("logs")
	
	print("✓ Simple log created successfully")

# Optional: Function to test log dropping without killing tree
func test_drop_logs():
	print("Testing log drop...")
	drop_logs()
