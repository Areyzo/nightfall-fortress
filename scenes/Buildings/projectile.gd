extends Area2D

var origin_pos : Vector2
var target_pos : Vector2
var velocity : Vector2
var speed = 800  # Increased speed to catch moving targets
var direction : Vector2
var damage = 20  # 20 damage per hit - takes 5 hits to kill a goblin (100 HP)
var lifetime = 3.0  # Projectile disappears after 3 seconds
var time_alive = 0.0

func _ready():
	position = origin_pos
	direction = target_pos - origin_pos
	
	print("🚀 PROJECTILE CREATED")
	print("Origin: ", origin_pos, " Target: ", target_pos)
	print("Projectile collision - Layer: ", collision_layer, " Mask: ", collision_mask)
	print("Direction: ", direction)
	
	set_sprite_rotation()
	velocity = direction.normalized() * speed

func _physics_process(delta):
	position += velocity * delta
	time_alive += delta
	
	# Remove projectile after lifetime expires
	if time_alive >= lifetime:
		queue_free()

# rotate the sprite according to its direction
# this function is not needed if the projectile is symmetrical in both x and y axis
func set_sprite_rotation():
	var angle
	
	if direction.y != 0:
		angle = atan(direction.x / direction.y) * 180 / PI
	else:
		if direction.x > 0:
			angle = 90
		elif direction.x < 0:
			angle = 270
	
	if direction.x >= 0 and direction.y >= 0:
		# 4th quadrant
		$Sprite.rotation_degrees = 180 - angle
	elif direction.x >= 0 and direction.y <= 0:
		# 1st quadrant
		$Sprite.rotation_degrees = abs(angle)
	elif direction.x <= 0 and direction.y >= 0:
		# 3rd quadrant
		$Sprite.rotation_degrees = 180 + abs(angle)
	elif direction.x <= 0 and direction.y <= 0:
		# 2nd quadrant
		$Sprite.rotation_degrees = 360 - angle

# the projectile disappears when it hits a target

func _on_area_entered(area: Area2D) -> void:
	print("🎯 PROJECTILE HIT AREA: ", area.name)
	print("Area parent: ", area.get_parent().name if area.get_parent() else "No parent")
	print("Area collision layer: ", area.collision_layer)
	print("Area collision mask: ", area.collision_mask)
	
	if (area.name.contains("Goblin") or area.name.contains("goblin")):
		print("✅ GOBLIN DETECTED!")
		var goblin = area.get_parent()
		print("Goblin parent: ", goblin)
		if goblin.has_method("take_damage"):
			goblin.take_damage(damage)
			print("💥 DAMAGE DEALT: ", damage, " to ", goblin.name)
		else:
			print("❌ Goblin doesn't have take_damage method!")
		queue_free()
	else:
		print("❌ Area hit but not goblin-related: ", area.name)

func _on_body_entered(body):
	print("Projectile hit body: ", body.name)  # Debug print
	if "goblin" in body.name.to_lower():
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Projectile dealt ", damage, " damage to goblin body!")  # Debug print
		queue_free()
