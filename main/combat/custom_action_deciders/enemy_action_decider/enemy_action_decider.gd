extends "res://addons/rpg_framework/custom_nodes/action_decider/action_decider.gd"

onready var cam := get_tree().get_root().get_node("Main/MainCamera")

func decide(context: Dictionary) -> void:
	yield(cam.pan(get_parent().get_node("Sprite"), 0.35, Vector2(-200,64)), "completed")
	var targets := []
	var action: Node
	if get_child_count() == 0 or rand_range(0, 1.0) > .35:
		targets.append(context["fighters"][1][randi() % len(context["fighters"][1])])
		action = get_node("../Attack")
	else:
		action = get_children()[randi() % get_child_count()]
		if action.target_count == "one":
			targets.append(context["fighters"][0 if action.party_target == "team" else 1][randi() % len(context["fighters"][0 if action.party_target == "team" else 1])])
		else:
			targets = context["fighters"][0 if action.party_target == "team" else 1]
	emit_signal("action_decided", {"action_type": "Skill", "action": action, "targets":  targets})
