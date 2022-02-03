extends "res://addons/rpg_framework/custom_nodes/party/party.gd"

var fighter_containers_combat: Array
var fighter_containers_overworld: Array

func _ready() -> void:
	fighter_containers_combat = get_node("../../../UI/CombatUI/Combat/VBoxContainer/FighterBar").set_fighter_containers(get_children())
	fighter_containers_overworld = get_node("../../../UI/OverworldUI/Overworld/PopupMenu/HBoxContainer/FighterPanel/FighterBar").set_fighter_containers(get_children())
	print(fighter_containers_overworld)
