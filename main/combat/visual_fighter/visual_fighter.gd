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
	$CurrentIcon.modulate = Color(1,1,1,0)
	$SelectIcon.modulate = Color(1,1,1,0)
	$Sprite.visible = false

func set_select_eligible(enable: bool) -> void:
	if enable:
		$SelectIcon/TransitionTween.interpolate_property($SelectIcon, "modulate", null, Color(1,1,1,1), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$SelectIcon/TransitionTween.start()
		$SelectIcon.frame = 1
	else:
		$SelectIcon/TransitionTween.interpolate_property($SelectIcon, "modulate", null, Color(1,1,1,0), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$SelectIcon/TransitionTween.start()

func set_select_animation(enable: bool) -> void:
	if enable:
		$SelectIcon.frame = 0
		$SelectIcon/SelectAnim.current_animation = "select"
	else:
		$SelectIcon.frame = 1
		$SelectIcon/SelectAnim.current_animation = "[stop]"
		$SelectIcon/SelectTween.interpolate_property($Sprite, "modulate", null, Color(1,1,1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$SelectIcon/SelectTween.start()

func act(context: Dictionary) -> void:
	$CurrentIcon/CurrentIconAnim.current_animation = "current"
	get_action_decider().call_deferred("decide", context)
	var decision : Dictionary = yield(get_action_decider(), "action_decided")
	match decision["action_type"]:
		"Pass":
			yield(text_box.display_text("%s passed!" % save_id, 0.015, 0.5), "completed")
			emit_signal("act_completed", {"success": 1})
		"Defend":
			yield(text_box.display_text("%s went into a defensive stance!" % save_id, 0.015, 0.5), "completed")
			emit_signal("act_completed", {"success": 0})
		"Flee":
			emit_signal("act_completed", {"success": 0})
		"Skill":
			decision["action"].action(self, decision["targets"])
			emit_signal("act_completed", yield(decision["action"], "action_completed"))
	$CurrentIcon/CurrentIconAnim.current_animation = "[stop]"
	$CurrentIcon/CurrentIconTween.interpolate_property($CurrentIcon, "modulate", null, Color(1,1,1,0), .4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CurrentIcon/CurrentIconTween.start()
	yield($CurrentIcon/CurrentIconTween, "tween_completed")