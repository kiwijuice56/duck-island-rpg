tool
extends "res://addons/rpg_framework/custom_nodes/fighter/fighter.gd"

export var level: int
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

var atk := 0
var def := 0
var hit_eva := 0

var status := "okay"

onready var combat_ui := get_tree().get_root().get_node("Main/CombatUI/Combat")
onready var text_box = combat_ui.get_node("VBoxContainer/TextBox")
onready var cam := get_tree().get_root().get_node("Main/MainCamera")

var calculation_cache := {}

signal update_points

var miss_color := Color("#ff0044")
var crit_color := Color("#ffcc00")

func _ready() -> void:
	$Sprite.frame = 0
	$Sprite.modulate = Color(1,1,1,1)
	$Sprite.position = Vector2(0, -128)
	$CurrentIcon.modulate = Color(1,1,1,0)
	$SelectIcon.modulate = Color(1,1,1,0)
	$CanvasLayer/DamageLabel.modulate = Color(1,1,1,0)
	$Sprite.visible = false

func on_impact() -> void:
	$ParticleEmitter.global_position = $SelectIcon.global_position
	$CanvasLayer/DamageLabel.rect_position = $SelectIcon.get_global_transform_with_canvas().get_origin()-Vector2(32,0)
	
	emit_signal("update_points")
	
	if calculation_cache["contact"] == "none":
		return
	elif calculation_cache["contact"] == "miss":
		SoundPlayer.play_sound(SoundPlayer.woosh)
		$BasicAnimationPlayer.current_animation = "miss"
		if $SpriteAnimationPlayer.has_animation("miss"):
			$SpriteAnimationPlayer.current_animation = "miss"
		$CanvasLayer/DamageLabel.text = "miss!"
		$CanvasLayer/DamageLabel.add_color_override("font_color", miss_color)
	else:
		if status == "dead":
			$BasicAnimationPlayer.current_animation = "dead"
			if $SpriteAnimationPlayer.has_animation("dead"):
				$SpriteAnimationPlayer.current_animation = "dead"
		else:
			$BasicAnimationPlayer.current_animation = "hurt"
			if $SpriteAnimationPlayer.has_animation("hurt"):
				$SpriteAnimationPlayer.current_animation = "hurt"
		if calculation_cache["contact"] == "critical":
			SoundPlayer.play_sound(SoundPlayer.crit)
			$CanvasLayer/DamageLabel.add_color_override("font_color", crit_color)
			$CanvasLayer/DamageLabel.text = "crit! " + str(calculation_cache["damage"])
		else:
			$CanvasLayer/DamageLabel.add_color_override("font_color", Color(1.0,1.0,1.0))
			$CanvasLayer/DamageLabel.text = str(calculation_cache["damage"])
		
		
	
	$CanvasLayer/DamageLabel/DamageTween.interpolate_property($CanvasLayer/DamageLabel, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CanvasLayer/DamageLabel/DamageTween.interpolate_property($CanvasLayer/DamageLabel, "rect_position", null, $CanvasLayer/DamageLabel.rect_position + Vector2(0,-5), 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CanvasLayer/DamageLabel/DamageTween.start()
	
	yield($CanvasLayer/DamageLabel/DamageTween, "tween_completed")
	
	$CanvasLayer/DamageLabel/DamageTween.interpolate_property($CanvasLayer/DamageLabel, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CanvasLayer/DamageLabel/DamageTween.interpolate_property($CanvasLayer/DamageLabel, "rect_position", null, $CanvasLayer/DamageLabel.rect_position + Vector2(0,-40), 1.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CanvasLayer/DamageLabel/DamageTween.start()

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
