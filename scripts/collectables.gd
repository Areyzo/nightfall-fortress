extends Area2D
@export var itemsRes : InventoryItem

func _ready():
	connect("body_entered", _on_body_entered)
	print("=== COLLECTABLES READY ===")
	print("Position: ", global_position)
	print("ItemsRes: ", itemsRes.name if itemsRes else "NULL")
	if itemsRes:
		print("ItemsRes name: ", itemsRes.name)
		print("ItemsRes texture: ", itemsRes.texture)
	print("===========================")

func _on_body_entered(body):
	print("=== COLLECTABLES: Body entered ===")
	print("Body name: ", body.name)
	print("Is in player group: ", body.is_in_group("player"))
	print("Has get_inventory method: ", body.has_method("get_inventory"))
	print("ItemsRes available: ", itemsRes != null)
	if itemsRes:
		print("ItemsRes name: ", itemsRes.name)
		print("ItemsRes texture: ", itemsRes.texture != null)
	
	if body.is_in_group("player") and body.has_method("get_inventory"):
		if not itemsRes:
			print("ERROR: itemsRes is NULL! Cannot collect.")
			return
		var inventory: Inventory = body.get_inventory()
		if not inventory:
			print("ERROR: Player inventory is NULL!")
			return
		collect(inventory)

func collect(inventory: Inventory):
	print("=== COLLECTABLES: Starting collection ===")
	if not itemsRes:
		print("ERROR: Cannot collect - itemsRes is NULL")
		return
	if not inventory:
		print("ERROR: Cannot collect - inventory is NULL")
		return
		
	print("SUCCESS: Collecting item: ", itemsRes.name)
	inventory.insert(itemsRes)
	print("=== COLLECTABLES: Item queued for removal ===")
	queue_free()
