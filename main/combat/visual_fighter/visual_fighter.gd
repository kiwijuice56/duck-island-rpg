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

onready var blood = $ParticleEffects/Blood
onready var panic = $ParticleEffects/Panic
onready var damage_label = $CanvasLayer/DamageLabel

var calculation_cache := {}

signal update_points

var miss_color := Color("#ff0044")
var crit_color := Color("#ffcc00")
var panic_color := Color("#e0addd")

func _ready() -> void:
	$ParticleEffects.global_position = $SelectIcon.global_position
	$Sprite.frame = 0
	$Sprite.modulate = Color(1,1,1,1)
	$Sprite.position = Vector2(0, -128)
	$CurrentIcon.modulate = Color(1,1,1,0)
	$SelectIcon.modulate = Color(1,1,1,0)
	$CanvasLayer/DamageLabel.modulate = Color(1,1,1,0)
	$Sprite.visible = false

func on_impact() -> void:
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
			damage_label.add_color_override("font_color", crit_color)
			damage_label.text = "crit! " + str(calculation_cache["damage"])
		else:
			damage_label.add_color_override("font_color", Color(1.0,1.0,1.0))
			damage_label.text = str(calculation_cache["damage"])
	update_status()
	
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.1)
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "rect_position", null, damage_label.rect_position + Vector2(0,-5), 0.4)
	damage_label.get_node("DamageTween").start()
	
	yield(damage_label.get_node("DamageTween"), "tween_completed")
	
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.0)
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "rect_position", null, damage_label.rect_position + Vector2(0,-40), 1.2)
	damage_label.get_node("DamageTween").start()
	if $SpriteAnimationPlayer.is_playing() and not $SpriteAnimationPlayer.current_animation == "idle":
		yield($SpriteAnimationPlayer, "animation_finished")
	if not status == "dead":
		$SpriteAnimationPlayer.current_animation = "idle"

func update_status():
	match status:
		"panic": 
			$Sprite.self_modulate = panic_color
			panic.emitting = true
		_:
			$Sprite.self_modulate = Color(1.0,1.0,1.0)
			panic.emitting = false

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
			emit_signal("act_completed", {"success": 0 if status == "panic" else 1})
		"Defend":
			yield(text_box.display_text("%s went into a defensive stance!" % save_id, 0.015, 0.5), "completed")
			emit_signal("act_completed", {"success": 0})
		"Flee":
			emit_signal("act_completed", {"success": 0})
		"Skill":
			decision["action"].action(self, decision["targets"])
			var data = yield(decision["action"], "action_completed")
			if status == "panic":
				data["success"] = min(0, data["success"])
			emit_signal("act_completed", data)
		"Item":
			decision["action"].action(self, decision["targets"], decision["item"])
			var data = yield(decision["action"], "action_completed")
			if status == "panic":
				data["success"] = min(0, data["success"])
			emit_signal("act_completed", data)
	$CurrentIcon/CurrentIconAnim.current_animation = "[stop]"
	$CurrentIcon/CurrentIconTween.interpolate_property($CurrentIcon, "modulate", null, Color(1,1,1,0), .4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CurrentIcon/CurrentIconTween.start()
	yield($CurrentIcon/CurrentIconTween, "tween_completed")
