tool
extends "res://addons/rpg_framework/custom_nodes/fighter/fighter.gd"

export var hp: int
export var mp: int
export var max_hp: int
export var max_mp: int

export var strength: int
export var vitality: int
export var magic: int
export var agility: int
export var luck: int

export var defense := {}
export var offense := {}

onready var combat_ui := get_tree().get_root().get_node("Main/CombatUI/Combat")
onready var text_box = combat_ui.get_node("VBoxContainer/TextBox")
onready var cam := get_tree().get_root().get_node("Main/MainCamera")

func _ready() -> void:
	$Sprite.visible = false

func act(context: Dictionary) -> void:
	yield(cam.pan(get_node("Sprite"), 0.35, Vector2(300,64)), "completed")
	text_box.display_text("What will %s do?" % save_id, 0.015, 0.5)
	var decision : Dictionary = yield(get_action_decider().decide(context), "completed")
	match decision["action_type"]:
		"Pass":
			yield(text_box.display_text("%s passed!" % save_id, 0.015, 0.5), "completed")
			emit_signal("act_completed", {"success": 1})
		"Defend":
			yield(text_box.display_text("%s went into a defensive stance!" % save_id, 0.015, 0.5), "completed")
			emit_signal("act_completed", {"success": 0})
		"Flee":
			emit_signal("act_completed", {"success": 0})
		_:
			pass
