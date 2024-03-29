tool
extends Node
# Basic framework for a Fighter in an RPG

export var save_id := ""

# Array of strings that represent special abilities or traits of this Fighter
export(Array, String) var attributes: Array

signal act_completed(result)

# Called by Party parent node to continue turn-based battle sequence
# Input context consists of other parties in a battle and other conditional information
# Emits a signal with a report of this fighter's turn
# In your extension class, override this method and implement any unique game logic
func act(context: Dictionary) -> void:
	get_action_decider().call_deferred("decide", context)
	var decision : Dictionary = yield(get_action_decider(), "action_decided")
	emit_signal("act_completed", {"success": true})

func get_action_decider() -> Node:
	var action_decider_script : Script = load("res://addons/rpg_framework/custom_nodes/action_decider/action_decider.gd")
	for child in get_children():
		if child is ActionDecider:
			return child
	push_error("Missing ActionDecider as child of Fighter")
	return null

# Returns data to be put in save game by a parent Party node
# In your extension class, override this method and return any data necessary to preserve the state of the Fighter
func save_data() -> Dictionary:
	var data := {}
	data["Actions"] = get_action_decider().get_action_array()
	data["Attributes"] = attributes
	return data

func load_data(data: Dictionary) -> void:
	get_action_decider().load_data(data["Actions"])
	attributes = data["Attributes"]

# Overrides built-in configuration warning to display warning when missing an ActionDecider
func _get_configuration_warning() -> String:
	var action_decider_script : Script = load("res://addons/rpg_framework/custom_nodes/action_decider/action_decider.gd")
	var action_decider_count := 0
	for child in get_children():
		if child is action_decider_script:
			action_decider_count += 1
	if action_decider_count == 0:
		return "A Fighter node requires one ActionDecider (or extension) as a child node"
	if action_decider_count > 1:
		return "Multiple ActionDecider children detected; the Fighter node will only use the first in the node tree"
	return ""
