extends Node

export var combat_items: Dictionary

func _ready() -> void:
	combat_items[load("res://main/items/combat/puffle/puffle.tres")] = 2
