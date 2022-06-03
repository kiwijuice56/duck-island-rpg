extends "res://addons/rpg_framework/custom_nodes/party/party.gd"

var fighter_containers_combat: Array
var fighter_containers_overworld: Array

func load_data(data) -> void:
	.load_data(data)
	fighter_containers_combat = get_node("../../../UI/CombatUI/Combat/VBoxContainer/FighterBar").set_fighter_containers(get_children())
	fighter_containers_overworld = get_node("../../../UI/OverworldUI/Overworld/PopupMenu/HBoxContainer/FighterPanel/FighterBar").set_fighter_containers(get_children())

func add_child(node: Node, lun: bool = false) -> void:
	.add_child(node)
	fighter_containers_combat = get_node("../../../UI/CombatUI/Combat/VBoxContainer/FighterBar").set_fighter_containers(get_children())
	fighter_containers_overworld = get_node("../../../UI/OverworldUI/Overworld/PopupMenu/HBoxContainer/FighterPanel/FighterBar").set_fighter_containers(get_children())
