extends "res://addons/rpg_framework/custom_nodes/action/action.gd"

export(String, "hp", "mp") var cost_type := "hp"
export(String, "physical", "gun", "fire", "water", "earth", "electric", "ghost", "support", "heal") var type := "physical"
export var cost: int
export(String, "all", "one", "random") var target_count = "one"
export(String, "team", "enemy") var party_target = "enemy"

export var graphic_effect: PackedScene

func action(user: Node, targets: Array) -> void:
	var new_effect = graphic_effect.instance()
	add_child(new_effect)
	new_effect.animate(user, targets)
	yield(new_effect, "effect_complete")
	new_effect.queue_free()
	emit_signal("action_completed", {"success": 0, "Critical": true, "Hit Weakness": true})
