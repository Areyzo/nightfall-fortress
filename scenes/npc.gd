extends CharacterBody2D

@onready var dialogue_trigger = $DialogueTrigger
var player_inside = false

func _ready():
	if dialogue_trigger:
		dialogue_trigger.body_entered.connect(_on_body_entered)
		dialogue_trigger.body_exited.connect(_on_body_exited)
	else:
		print("DialogueTrigger node not found!")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true
		show_dialogue()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		hide_dialogue()

func show_dialogue():
	print("Hello traveler!")

func hide_dialogue():
	print("Goodbye.")
