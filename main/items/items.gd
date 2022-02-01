extends Node

export var combat_items: Dictionary
var instanced_item: Node

func _ready() -> void:
	combat_items[load("res://main/items/combat/puffle/puffle.tres")] = 2

func instance_item(item: PackedScene) -> Node:
	if instanced_item:
		deinstance_item()
	instanced_item = item.instance()
	add_child(instanced_item)
	return instanced_item

func deinstance_item() -> void:
	remove_child(instanced_item)
	instanced_item.queue_free()

