extends "res://addons/rpg_framework/custom_nodes/action_decider/action_decider.gd"

onready var cam := get_tree().get_root().get_node("Main/MainCamera")

func decide(context: Dictionary) -> void:
	yield(cam.pan(get_parent().get_node("Sprite"), 0.35, Vector2(-300,64)), "completed")
	emit_signal("action_decided", {"action_type": "Defend"})
