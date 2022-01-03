extends "res://addons/rpg_framework/custom_nodes/party/party.gd"

var fighter_containers: Array

func _ready() -> void:
	fighter_containers = get_node("../../CanvasLayer/Combat").set_fighter_containers(get_children())
