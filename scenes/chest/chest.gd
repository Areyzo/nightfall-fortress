@tool
class_name Chest
extends StaticBody2D

enum ChestType { FOREST, CAVE, DESERT, TUNDRA }



@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_area: Area2D = $InteractArea
var player_nearby: Node = null


@export var chest_type: ChestType = ChestType.FOREST:
	set(value):
		chest_type = value
		_update_chest_texture()

@export var forest_chest: Texture2D:
	set(value):
		forest_chest = value
		if chest_type == ChestType.FOREST:
			_update_chest_texture()

@export var loot: Array[InventoryItem] = []
@export var loot_quantities: Array[int] = []

var can_interact: bool = false
var is_opened: bool = false

#func _ready() -> void:
#	_update_chest_texture()

func _update_chest_texture() -> void:
	if not sprite:
		return

	match chest_type:
		ChestType.FOREST:
			sprite.texture = forest_chest

func _input(event: InputEvent) -> void:
	if can_interact and event.is_action_pressed("interact") and not is_opened:
		animation_player.play("open")
		is_opened = true
		can_interact = false
		spawn_items()

func spawn_items() -> void:
	if loot.size() != loot_quantities.size():
		push_error("Loot and loot_quantities must be the same size.")
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("No player found in 'player' group.")
		return

	for i in range(loot.size()):
		var item: InventoryItem = loot[i]
		var amount: int = loot_quantities[i]

		for j in range(amount):
			player.inventory.insert(item)

	print("Loot added to player inventory.")


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player and not is_opened:
		can_interact = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		can_interact = false

#func _ready():
#	_update_chest_texture()
#	$InteractArea.connect("body_entered", _on_body_entered)
#	$InteractArea.connect("body_exited", _on_body_exited)
#	

#func _on_body_entered(body):
#	if body.is_in_group("player"):
#		player_nearby = body
#		print("Player entered chest area")

#func _on_body_exited(body):
#	if body == player_nearby:
#		player_nearby = null
#		print("Player left chest area")
