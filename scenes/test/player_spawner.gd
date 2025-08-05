extends Node

@export var spawn_scene: PackedScene
@export var spawn_path: NodePath = "."
@export var spawn_on_connect: bool = true

func _ready():
	if spawn_on_connect:
		# Connect only on the server (host) side
		if multiplayer.is_server():
			multiplayer.peer_connected.connect(_on_peer_connected)

			# Host needs a player too!
			_spawn_player(multiplayer.get_unique_id())

func _on_peer_connected(id: int) -> void:
	# Called only on the host when a new client connects
	_spawn_player(id)

func _spawn_player(peer_id: int) -> void:
	if not spawn_scene:
		push_error("❌ spawn_scene is not set!")
		return

	var parent = get_node_or_null(spawn_path)
	if not parent:
		parent = self.get_parent()

	var player_instance = spawn_scene.instantiate()
	parent.add_child(player_instance)

	# Give multiplayer ownership to the correct peer
	player_instance.set_multiplayer_authority(peer_id)

	print("✅ Spawned player for peer:", peer_id)
