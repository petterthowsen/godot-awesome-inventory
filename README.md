# Awesome Inventory System

This is a simple and extensible framework for handling items and storage.

There are four major classes, all of them extending Resource:
1. Inventory
2. InventoryItemType: defines a kind of item
3. InventoryItem: defines a "real" item that exists in the game. References a InventoryItemType.
4. InventorySlot: defines a slot in the inventory. Can hold 1 item, or can hold mulitple items of the same type if that type is stackable.

It may seem overkill at first glance, but it's more flexible this way.

One constraint as you may notice is that *all* items are real objects. I.E, there's no "stack" counter that virtually signify an amount of some item.
It's just easier this way.

# Usage
Given, for example a Player class, simply add
@export var inventory:Inventory

and in the inspector, create a new Inventory resource, set its capacity and optionally initial items to populate the inventory with.

# Contributing
Just submit a pull request! 
