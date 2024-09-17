class_name Inventory extends Resource

var slots: Array[InventorySlot] = []
@export var capacity: int = 5  # Maximum weight capacity of the inventory

signal item_added(item:InventoryItem, slot_idx:int)
signal item_removed(item:InventoryItem, slot_idx:int)
signal capacity_changed(from:int, to:int)

# Returns true if all items in the array are of the same InventoryItemType
static func is_items_of_same_type(items: Array[InventoryItem]) -> bool:
	if items.size() == 0:
		return true
	
	var item_type = items[0].item_type
	for i in range(1, items.size()):
		if items[i].item_type != item_type:
			return false
	
	return true

# Initialize the slots with empty InventorySlots
func _init():
	for i in range(capacity):
		var slot = InventorySlot.new()
		slots.append(slot)
		slot.item_added.connect(_on_slot_item_added.bind(i))
		slot.item_removed.connect(_on_slot_item_removed.bind(i))


func _on_slot_item_added(item:InventoryItem, slot_idx:int):
	item_added.emit(item, slot_idx)


func _on_slot_item_removed(item:InventoryItem, slot_idx:int):
	item_removed.emit(item, slot_idx)


# sorts all items by type and in ascending order
# all items we be temporarily taken out of their slots
# and after will after sorting be inserted again, starting from the beginning of the inventory
func sort():
	var items = take_all_items()
	items.sort_custom(_custom_sort_item_type)
	
	for item in items:
		put(item)


func _custom_sort_item_type(a:InventoryItem, b:InventoryItem) -> bool:
	var names = [a.item_type.name, b.item_type.name]
	names.sort()
	return names[0] == a.name


func get_all_items() -> Array[InventoryItem]:
	var items : Array[InventoryItem] = []
	
	for slot in slots:
		items.append_array(slot.items)
	
	return items


func take_all_items() -> Array[InventoryItem]:
	var items :Array[InventoryItem] = []
	
	for slot in slots:
		items.append_array(slot.take_all())
	
	return items


func get_count() -> int:
	var count = 0
	for slot in slots:
		count += slot.count
	
	return count


func is_empty() -> bool:
	return get_count() == 0


# Change the capacity of the inventory
func resize(new_capacity: int):
	if new_capacity == capacity:
		return
	
	var old_capacity = capacity
	
	if new_capacity < capacity:
		slots.resize(new_capacity)  # Remove excess slots
	else:
		for i in range(capacity, new_capacity):
			slots.append(InventorySlot.new())  # Add new empty slots
	capacity = new_capacity

	capacity_changed.emit(old_capacity, new_capacity)


# Check if we have space for the given item
func has_space_for_item(item: InventoryItem) -> bool:
	for slot in slots:
		if slot.type == null or (slot.type == item and slot.type.stackable and slot.available_stacks() > 0):
			return true
	return false

# Put an item into the inventory
func put(item: InventoryItem) -> bool:
	if not has_space_for_item(item):
		return false
	
	# Try to stack the item in an existing slot
	for slot in slots:
		if slot.type == item.item_type and item.item_type.stackable:
			if slot.available_stacks() > 0:
				slot.put(item)
				print("Item stacked")
				return true
	
	# If stacking isn't possible, find an empty slot
	for slot in slots:
		if slot.type == null:
			slot.put(item)
			print("item added")
			return true
	
	return false

# Check if we have space for multiple items
func has_space_for_items(items: Array[InventoryItem]) -> bool:
	for item in items:
		if not has_space_for_item(item):
			return false
	return true

# Put many items at once into the inventory
func put_many(items: Array[InventoryItem]) -> bool:
	if not has_space_for_items(items):
		return false
	
	for item in items:
		if not put(item):
			return false
	return true

# Remove the given item from the inventory
func take(item: InventoryItem):
	for slot in slots:
		if slot.item == item:
			slot.remove_from_stack(item.stack_count)
			if slot.is_empty():
				slot.clear()
			return

# Take all items from a slot
func take_all_from_slot(slot_idx: int) -> Array[InventoryItem]:
	var slot = slots[slot_idx]
	var items: Array[InventoryItem] = []
	if slot.item != null:
		items.append(slot.item)
		slot.clear()
	return items

# Get all items of the given type
func get_of_type(type: InventoryItemType) -> Array[InventoryItem]:
	var items: Array[InventoryItem] = []
	for slot in slots:
		if slot.item != null and slot.item.item_type == type:
			items.append(slot.item)
	return items

# Check if an item exists in the inventory
func has_item(item: InventoryItem) -> bool:
	for slot in slots:
		if slot.item == item:
			return true
	return false

# Check if an item of a given type exists in the inventory
func has_item_of_type(type: InventoryItemType) -> bool:
	for slot in slots:
		if slot.item != null and slot.item.item_type == type:
			return true
	return false

# Get the amount of a specific item type
func get_amount_of_item_type(type: InventoryItemType) -> int:
	var amount = 0
	for slot in slots:
		if slot.item != null and slot.item.item_type == type:
			amount += slot.stack_count
	return amount

# Move an item from its current slot to a different slot
func move(item: InventoryItem, new_slot_idx: int):
	for i in range(slots.size()):
		if slots[i].items.has(item):  # Check if the current slot contains the item
			var current_slot = slots[i]
			var new_slot = slots[new_slot_idx]
			
			# If the new slot contains the same item type and the item is stackable, try to stack
			if new_slot.type == item.item_type and item.item_type.stackable:
				# Transfer as many items as possible
				var remaining_items = current_slot.take(new_slot.available_stacks())
				new_slot.put_all(remaining_items)
				
				# Clear current slot if empty
				if current_slot.is_empty():
					current_slot.clear()
			else:
				# Swap the items if they cannot be stacked
				var temp_items = new_slot.take_all()  # Take all items from the new slot
				new_slot.put_all(current_slot.take_all())  # Move all items from the current slot to the new slot
				current_slot.put_all(temp_items)  # Put the previously taken items into the original slot
			return


# Get the total weight of all items in the inventory
func get_total_weight() -> int:
	var total_weight: int = 0
	for slot in slots:
		total_weight += slot.weight
	return total_weight
