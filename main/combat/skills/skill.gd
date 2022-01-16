extends "res://addons/rpg_framework/custom_nodes/action/action.gd"

export(String, "hp", "mp", "") var cost_type := "hp"
export(String, "physical", "gun", "fire", "water", "earth", "electric", "ghost", "support", "heal") var type := "physical"
export var cost: int
export var accuracy := 1.0
export(String, "all", "one", "random") var target_count = "one"
export(String, "team", "enemy") var party_target = "enemy"
onready var text_box = get_tree().get_root().get_node("Main/CombatUI/Combat/VBoxContainer/TextBox")

export var graphic_effect: PackedScene

func action(user: Node, targets: Array) -> void:
	if cost_type != "":
		user.set(cost_type, user.get(cost_type) - cost)
		user.emit_signal("update_points")
	var result = calculation(user, targets)
	var new_effect = graphic_effect.instance()
	add_child(new_effect)
	yield(text_box.display_text(user.save_id + " used " + save_id.capitalize() + "!", 0.02, 0.5), "completed")
	new_effect.animate(user, targets)
	yield(new_effect, "effect_complete")
	new_effect.queue_free()
	emit_signal("action_completed", result)


func calculation(user: Node, targets: Array) -> Dictionary:
	return {"success": 0}
