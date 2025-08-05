extends Control

@onready var label = $name

func show_text(text):
	print("Dialogue show_text called with: ", text)
	if label:
		label.text = "NPC: " + text
		print("Label text set to: ", label.text)
	show()
	# Make sure it's visible and in front
	z_index = 100
	# Add a simple fade-in effect
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	print("Dialogue box should now be visible")

func hide_text():
	print("Dialogue hide_text called")
	# Add a fade-out effect before hiding
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(hide)
