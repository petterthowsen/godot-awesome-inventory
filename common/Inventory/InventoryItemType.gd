class_name InventoryItemType extends Resource

@export var name: String = "Unknown Item"
@export var description: String
@export var texture:Texture
@export var weight: int = 1  # Weight of a single item
@export var stackable: bool = true  # Whether this item can be stacked
@export var max_stack_size: int = 99  # Maximum stack size, if stackable
@export var size:Vector2i = Vector2i(1, 1)
