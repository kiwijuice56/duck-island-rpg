extends "res://addons/rpg_framework/custom_nodes/action_decider/action_decider.gd"

onready var combat_ui := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/CombatUI/Combat")
onready var circle_menu := combat_ui.get_node("CircleMenu")
onready var text_box = combat_ui.get_node("VBoxContainer/TextBox")
onready var cam := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")

func decide(context: Dictionary) -> void:
	yield(cam.pan(get_parent().get_node("Sprite"), 0.35, Vector2(300,64)), "completed")
	text_box.display_text("What will %s do?" % get_parent().save_id, 0.015, 0.5)
	circle_menu.call_deferred("select_action", get_parent())
	var selection: Dictionary = yield(circle_menu, "action_selected")
	emit_signal("action_decided", selection)
