extends "res://addons/rpg_framework/custom_nodes/action/action.gd"

export(String, "hp", "mp") var cost_type := "hp"
export(String, "physical", "gun", "fire", "water", "earth", "electric", "ghost", "support", "heal") var type := "physical"
export var cost: int

export var graphic_effect: PackedScene

