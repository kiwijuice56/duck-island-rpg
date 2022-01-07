extends "res://addons/rpg_framework/custom_nodes/action_decider/action_decider.gd"

onready var cam := get_tree().get_root().get_node("Main/MainCamera")

func decide(context: Dictionary) -> void:
	yield(cam.pan(get_parent().get_node("Sprite"), 0.35, Vector2(-200,64)), "completed")
	var target: Node
	emit_signal("action_decided", {"action_type": "Skill", "action": get_node("../Attack"), "targets": [context["fighters"][1][randi() % len(context["fighters"][1]) ]] })
