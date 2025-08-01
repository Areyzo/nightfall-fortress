extends Area2D
@export var itemsRes : InventoryItem

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("get_inventory"):
		var inventory: Inventory = body.get_inventory()
		collect(inventory)

func collect(inventory: Inventory):
	inventory.insert(itemsRes)
	queue_free()
