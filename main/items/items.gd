extends Node

var combat_items := {}
var healing_items := {}
export var save_id := "items"
var instanced_item: Node

func _ready() -> void:
	pass

func instance_item(item: PackedScene) -> Node:
	if instanced_item:
		deinstance_item()
	instanced_item = item.instance()
	add_child(instanced_item)
	return instanced_item

func deinstance_item() -> void:
	remove_child(instanced_item)
	instanced_item.queue_free()

func load_data(data: Dictionary) -> void:
	healing_items = data["healing_items"]
	combat_items = data["combat_items"]

func save_data() -> Dictionary:
	var data := {}
	data["healing_items"] = healing_items
	data["combat_items"] = combat_items
	return data
