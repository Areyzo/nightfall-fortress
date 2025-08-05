# Game Over System

## Features
- When the player's health reaches 0, a game over screen appears
- The game over screen shows "GAME OVER" text and a "RESPAWN" button
- Game is paused when the game over screen is displayed
- Clicking the respawn button respawns the player at the starting position with full health
- Player's saved game data is cleared on death (fresh start on respawn)

## How to Test
1. **Natural Death**: Let enemies (goblins) attack the player until health reaches 0
2. **Debug Key**: Press **K** key to instantly kill the player for testing purposes

## Controls
- **RESPAWN Button**: Click to respawn the player
- **Enter Key**: Alternative way to respawn when game over screen is visible
- **K Key**: Debug key to instantly trigger player death (for testing)

## Technical Details
- Game over screen is located at `scenes/ui/game_over_screen.tscn`
- Game over logic is handled in `scripts/testscenes_tilemap.gd`
- Player death is detected through the `player_died` signal
- Respawn uses the player's built-in `respawn()` method
- Save file is automatically deleted on death for fresh inventory on respawn

## Game Flow
1. Player takes damage and dies → `player_died` signal emitted
2. Main scene receives signal → Shows game over screen, pauses game
3. Player clicks respawn → Game over screen hides, game unpauses
4. Player respawns at starting position with full health
5. Game continues normally
