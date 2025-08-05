extends  Control

@onready var label = $Panel/Label

func show_text(text):
	label.text = text
	show()

func hide_text():
	hide()
