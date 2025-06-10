# log.gd - Script for the log item
extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var pickup_area = $PickupArea
@onready var collision_shape = $CollisionShape2D

var item_name = "log"
var pickup_sound_path = "res://audio/pickup.ogg"  # Optional pickup sound

func _ready():
	print("Log created at position: ", global_position)
	
	# Connect pickup signal
	pickup_area.body_entered.connect(_on_pickup_area_body_entered)
	
	# Set up collision layers
	collision_layer = 4  # Item physics layer
	collision_mask = 0   # Static bodies don't need collision mask
	
	# Pickup area layers
	pickup_area.collision_layer = 8  # Pickup layer
	pickup_area.collision_mask = 2   # Player layer
	
	# Add to logs group
	add_to_group("logs")
	
	# Optional: Auto-despawn after time
	start_despawn_timer()



func _on_pickup_area_body_entered(body):
	print("Something entered pickup area: ", body.name)
	if body.has_method("collect_item") or body.is_in_group("player"):
		print("Valid player detected, picking up log")
		pickup_log(body)

func pickup_log(player):
	print("Picking up log for player: ", player.name)
	
	# Play pickup sound if available
	play_pickup_sound()
	
	# Add to player inventory
	if player.has_method("collect_item"):
		player.collect_item(item_name)
		print("Called collect_item on player")
	elif player.has_method("add_item"):
		player.add_item(item_name)
		print("Called add_item on player")
	else:
		print("Player has no inventory methods")
	
	# Remove the log
	queue_free()

func play_pickup_sound():
	if ResourceLoader.exists(pickup_sound_path):
		var audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_player.stream = load(pickup_sound_path)
		audio_player.play()
		print("Playing pickup sound")
	else:
		print("Pickup sound not found at: ", pickup_sound_path)

func start_despawn_timer():
	# Optional: Remove log after 30 seconds if not picked up
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 30.0
	timer.one_shot = true
	timer.timeout.connect(despawn_log)
	timer.start()
	print("Despawn timer started (30 seconds)")

func despawn_log():
	print("Log despawning due to timeout")
	# Fade out effect (optional)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
