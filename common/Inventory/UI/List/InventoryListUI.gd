class_name InventoryListUI extends ScrollContainer

@export var InventoryListItemUI:PackedScene

@export var initial_items:Array[InventoryItem]

@export var inventory:Inventory:set = set_inventory
@onready var vbox:VBoxContainer = $VBoxContainer

func set_inventory(it:Inventory):
	if inventory == it:
		return
	
	inventory = it
	
	if is_inside_tree():
		_clear_ui()
		_create_ui()
		if initial_items:
			inventory.put_many(initial_items)


func _clear_ui():
	for itemUI in vbox.get_children():
		itemUI.queue_free()


func _create_ui():
	for item in inventory.get_all_items():
		_create_inventory_list_item_ui(item)
	
	inventory.item_added.connect(_on_inventory_item_added)
	inventory.item_removed.connect(_on_inventory_item_removed)


func _on_inventory_item_added(item:InventoryItem, slot:int):
	_create_inventory_list_item_ui(item)


func _on_inventory_item_removed(item:InventoryItem, slot:int):
	var itemUI = get_item_ui(item)
	vbox.remove_child(itemUI)
	itemUI.queue_free()


func _create_inventory_list_item_ui(item:InventoryItem):
	var itemUI:Control = InventoryListItemUI.instantiate()
	itemUI.item = item
	vbox.add_child(itemUI)


func get_item_ui(item:InventoryItem) -> InventoryListItemUI:
	for child in vbox.get_children():
		if child is InventoryListItemUI and child.item == item:
			return child
	return null


func _ready():
	_clear_ui()
	_create_ui()
	if initial_items:
		inventory.put_many(initial_items)
