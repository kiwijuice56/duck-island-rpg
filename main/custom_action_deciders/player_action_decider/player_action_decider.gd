extends "res://addons/rpg_framework/custom_nodes/action_decider/action_decider.gd"

onready var combat_ui := get_tree().get_root().get_node("Main/CanvasLayer/Combat")
onready var circle_menu := combat_ui.get_node("CircleMenu")

func decide(context: Dictionary) -> Dictionary:
	circle_menu.call_deferred("select_action")
	var selection: Dictionary = yield(circle_menu, "action_selected")
	print(selection)
	return selection
