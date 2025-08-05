extends CharacterBody2D

@onready var dialogue_trigger = $chat
@onready var dialogue_ui = preload("res://scenes/dialogue.tscn")
@onready var collision_area = $chat  # Use the chat area for clicking detection
var player_inside = false
var dialogue_instance = null
var current_dialogue_index = 0
var dialogues = [
	"Hi! Seems like you are new here.",
	"There are lots of monsters at night, be careful!",
	"Enjoy the game!"
]

func _ready():
	print("NPC ready, setting up dialogue system...")
	add_to_group("npc")  # Add NPC to a group for identification
	if dialogue_trigger:
		dialogue_trigger.body_entered.connect(_on_body_entered)
		dialogue_trigger.body_exited.connect(_on_body_exited)
		# Make the area clickable
		dialogue_trigger.input_event.connect(_on_area_input_event)
		print("NPC dialogue system connected successfully")
		# Make collision shape visible for debugging
		var collision_shape = dialogue_trigger.get_node("CollisionShape2D")
		if collision_shape:
			collision_shape.visible = true
	else:
		print("DialogueTrigger node not found!")

func _on_body_entered(body):
	print("Body entered NPC area: ", body.name)
	if body.is_in_group("player"):
		print("Player detected! Starting dialogue...")
		player_inside = true
		current_dialogue_index = 0  # Reset to first dialogue
		show_dialogue()
	else:
		print("Not a player, body groups: ", body.get_groups())

func _on_body_exited(body):
	print("Body exited NPC area: ", body.name)
	if body.is_in_group("player"):
		print("Player left dialogue area")
		player_inside = false
		hide_dialogue()
		current_dialogue_index = 0  # Reset for next time

func _on_area_input_event(viewport, event, shape_idx):
	# Handle clicking on the NPC area to advance dialogue
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player_inside and dialogue_instance and dialogue_instance.visible:
			advance_dialogue()

func show_dialogue():
	if not dialogue_instance:
		dialogue_instance = dialogue_ui.instantiate()
		# Add to the scene's CanvasLayer for proper UI layering
		var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
		if canvas_layer:
			canvas_layer.add_child(dialogue_instance)
		else:
			get_tree().current_scene.add_child(dialogue_instance)
		
		# Position dialogue above the hotbar (bottom center of screen)
		var viewport_size = get_viewport().get_visible_rect().size
		dialogue_instance.position = Vector2(
			viewport_size.x / 2 - 80,  # Center horizontally
			viewport_size.y - 80  # Above hotbar (80 pixels from bottom)
		)
		
		print("Dialogue positioned at: ", dialogue_instance.position)
		print("Viewport size: ", viewport_size)
	
	# Show current dialogue
	if current_dialogue_index < dialogues.size():
		var dialogue_text = dialogues[current_dialogue_index]
		# Add click hint after showing the first dialogue
		if current_dialogue_index == 0:
			dialogue_text += " (Click NPC to continue)"
		dialogue_instance.show_text(dialogue_text)
		print("Showing dialogue: ", dialogue_text)

func hide_dialogue():
	if dialogue_instance:
		dialogue_instance.hide_text()
		dialogue_instance.queue_free()
		dialogue_instance = null

func advance_dialogue():
	current_dialogue_index += 1
	if current_dialogue_index < dialogues.size():
		# Show next dialogue
		dialogue_instance.show_text(dialogues[current_dialogue_index])
	else:
		# End of dialogues, hide the dialogue box
		hide_dialogue()
		current_dialogue_index = 0  # Reset for next interaction
