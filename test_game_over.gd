extends Control

func _ready():
	print("Test scene ready")
	print("Scene size: ", get_viewport().get_visible_rect().size)
	
	# Show the game over immediately for testing
	var game_over_screen = get_node("GameOverScreen")
	print("Game over screen found: ", game_over_screen != null)
	if game_over_screen:
		game_over_screen.show_game_over()

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key
		get_tree().quit()
