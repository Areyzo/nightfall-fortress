extends Control

signal respawn_requested



func _ready():
	# Hide the screen initially and ensure it starts hidden
	print("Game over screen _ready() called")
	hide()
	# Set process mode so it works when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	print("Game over screen initialized with PROCESS_MODE_WHEN_PAUSED")

func show_game_over():
	"""Show the game over screen and pause the game"""
	print("=== SHOW_GAME_OVER CALLED ===")
	print("Current visibility: ", visible)
	print("About to show game over screen...")
	show()
	print("show() called, new visibility: ", visible)
	get_tree().paused = true
	print("Game paused, game over screen should be visible now")

func hide_game_over():
	"""Hide the game over screen and unpause the game"""
	print("=== HIDING GAME OVER SCREEN ===")
	hide()
	get_tree().paused = false
	print("Game over screen hidden and game unpaused")

func _on_respawn_button_pressed():
	"""Handle respawn button click"""
	print("=== RESPAWN BUTTON PRESSED ===")
	
	# Hide the game over screen first
	hide_game_over()
	
	# Emit signal to notify the main scene to handle respawn
	respawn_requested.emit()
	print("Respawn signal emitted")

func _input(event):
	"""Allow pressing Enter key to respawn as well"""
	if visible and event.is_action_pressed("ui_accept"):  # Enter key
		_on_respawn_button_pressed()
