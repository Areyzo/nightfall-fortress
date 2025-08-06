extends Control

signal respawn_requested

@onready var menu_panel = $MenuPanel
@onready var game_over_label = $MenuPanel/VBoxContainer/GameOverLabel

func _ready():
	# Hide the screen initially and ensure it starts hidden
	print("Game over screen _ready() called")
	hide()
	# Set process mode so it works when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	print("Game over screen initialized with PROCESS_MODE_WHEN_PAUSED")
	
	# Set initial state for animations
	if menu_panel:
		menu_panel.modulate.a = 0.0
		menu_panel.scale = Vector2(0.5, 0.5)

func show_game_over():
	"""Show the game over screen with smooth animation"""
	print("=== SHOW_GAME_OVER CALLED ===")
	print("Current visibility: ", visible)
	print("About to show game over screen...")
	
	show()
	get_tree().paused = true
	
	# Animate the panel entrance
	if menu_panel:
		# Reset initial state
		menu_panel.modulate.a = 0.0
		menu_panel.scale = Vector2(0.5, 0.5)
		
		# Create smooth entrance animation
		var tween = create_tween()
		tween.set_parallel(true)  # Allow multiple animations at once
		
		# Fade in
		tween.tween_property(menu_panel, "modulate:a", 1.0, 0.5)
		tween.tween_method(_bounce_scale, 0.5, 1.0, 0.6)
		
		# Add slight shake to the GAME OVER text
		if game_over_label:
			_animate_game_over_text()
	
	print("Game over screen animation started")

func _bounce_scale(value: float):
	"""Custom easing function for bouncy scale animation"""
	if menu_panel:
		# Add a slight overshoot for bounce effect
		var bounce_value = value
		if value > 0.9:
			bounce_value = value + sin(value * PI * 6) * 0.05
		menu_panel.scale = Vector2(bounce_value, bounce_value)

func _animate_game_over_text():
	"""Add subtle pulsing animation to GAME OVER text"""
	if not game_over_label:
		return
		
	var text_tween = create_tween()
	text_tween.set_loops()  # Loop forever
	text_tween.tween_property(game_over_label, "modulate:a", 0.7, 1.0)
	text_tween.tween_property(game_over_label, "modulate:a", 1.0, 1.0)

func hide_game_over():
	"""Hide the game over screen with smooth animation"""
	print("=== HIDING GAME OVER SCREEN ===")
	
	if menu_panel:
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Fade out and scale down
		tween.tween_property(menu_panel, "modulate:a", 0.0, 0.3)
		tween.tween_property(menu_panel, "scale", Vector2(0.8, 0.8), 0.3)
		
		# Hide after animation completes
		await tween.finished
	
	hide()
	get_tree().paused = false
	print("Game over screen hidden and game unpaused")

func _on_respawn_button_pressed():
	"""Handle respawn button click with animation"""
	print("=== RESPAWN BUTTON PRESSED ===")
	
	# Add button press effect
	var button = $MenuPanel/VBoxContainer/ButtonContainer/RespawnButton
	if button:
		var button_tween = create_tween()
		button_tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
		button_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Hide the game over screen with animation
	hide_game_over()
	await get_tree().process_frame  # Wait a frame for the animation to start
	
	# Emit signal to notify the main scene to handle respawn
	respawn_requested.emit()
	print("Respawn signal emitted")

func _input(event):
	"""Allow pressing Enter key to respawn as well"""
	if visible and event.is_action_pressed("ui_accept"):  # Enter key
		_on_respawn_button_pressed()
