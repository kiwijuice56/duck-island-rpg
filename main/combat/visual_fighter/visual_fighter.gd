tool
extends "res://addons/rpg_framework/custom_nodes/fighter/fighter.gd"

const STATS = ["level", "hp", "max_hp", "mp", "max_mp", "experience", "status", "experience_to_level", "strength", "magic", "vitality", "luck", "agility"]

export var level: int
export var hp: int
export var mp: int
export var max_hp: int
export var max_mp: int

export var strength: int
export var vitality: int setget set_vitality
export var magic: int setget set_magic
export var agility: int
export var luck: int

func set_vitality(v) -> void:
	vitality = v
	set_max_points()
func set_magic(m) -> void:
	magic = m
	set_max_points()

# affinities
export var defense := {}
export var offense := {}

var atk := 0
var def := 0
var hit_eva := 0

var status := "ok"

var experience := 0
var experience_to_level := 0

onready var combat_ui := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/CombatUI/Combat")
onready var text_box = combat_ui.get_node("VBoxContainer/TextBox")
onready var cam := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")

onready var blood = $ParticleEffects/Blood
onready var panic = $ParticleEffects/Panic
onready var damage_label = $DamageLabel
onready var extra_label = $ExtraLabel

var calculation_cache := {}

signal update_points
signal selected

var miss_color := Color("#ff0044")
var null_color := Color("#ff0033")
var absorb_color := Color("#7aff70")
var crit_color := Color("#ffcc00")
var panic_color := Color("#e0addd")
var heal_color := Color("#7aff70")

func _ready() -> void:
	$ParticleEffects.global_position = $SelectIcon.global_position
	$Sprite.frame = 0
	$Sprite.modulate = Color(1,1,1,1)
	$Sprite.position = Vector2(0, -128)
	$CurrentIcon.modulate = Color(1,1,1,0)
	$SelectIcon.modulate = Color(1,1,1,0)
	$DamageLabel.modulate = Color(1,1,1,0)
	$Sprite.visible = false
	experience_to_level = 15 * level * log(level + 1)

func get_experience() -> int:
	return int(max_hp)

func level_up() -> int:
	var stat_count := 0
	while experience >= experience_to_level:
		stat_count += 1
		level += 1
		experience -= experience_to_level
		experience_to_level = 15 * level * log(level + 1)
	set_max_points()
	return stat_count

func set_max_points() -> void:
	max_hp = int((level/2 + vitality*1.25) * 9)
	max_mp = int((level/3 + magic) * 8)
	emit_signal("update_points")

func on_impact() -> void:
	emit_signal("update_points")
	
	extra_label.text = ""
	
	if calculation_cache["contact"] == "none":
		return
	elif calculation_cache["contact"] == "miss":
		SoundPlayer.play_sound(SoundPlayer.woosh)
		$BasicAnimationPlayer.current_animation = "miss"
		if $SpriteAnimationPlayer.has_animation("miss"):
			$SpriteAnimationPlayer.current_animation = "miss"
		damage_label.text = "miss!"
		damage_label.add_color_override("font_color", miss_color)
	elif calculation_cache["contact"] == "heal" or calculation_cache["contact"] == "absorb":
		SoundPlayer.play_sound(SoundPlayer.absorb)
		damage_label.add_color_override("font_color", heal_color)
		damage_label.text = "+" + str(calculation_cache["damage"])
	elif calculation_cache["contact"] == "null":
		SoundPlayer.play_sound(SoundPlayer.null_sound)
		extra_label.add_color_override("font_color", null_color)
		extra_label.text = "null!"
		damage_label.text = ""
	else:
		if status == "dead":
			$BasicAnimationPlayer.current_animation = "dead"
			if $SpriteAnimationPlayer.has_animation("dead"):
				$SpriteAnimationPlayer.current_animation = "dead"
		else:
			$BasicAnimationPlayer.current_animation = "hurt"
			if $SpriteAnimationPlayer.has_animation("hurt"):
				$SpriteAnimationPlayer.current_animation = "hurt"
		
		damage_label.text = str(calculation_cache["damage"])
		damage_label.add_color_override("font_color", Color(1.0,1.0,1.0))
		
		if calculation_cache["contact"] == "weak" or "critical" in calculation_cache:
			SoundPlayer.play_sound(SoundPlayer.crit)
			extra_label.add_color_override("font_color", crit_color)
			damage_label.add_color_override("font_color", crit_color)
		if calculation_cache["contact"] == "weak":
			extra_label.text = "weak!"
		if "critical" in calculation_cache:
			extra_label.text += " crit!"
	
	update_status()
	
	# reset size to minimum
	damage_label.rect_size = Vector2()
	extra_label.rect_size = Vector2()
	
	extra_label.get_node("ExtraTween").interpolate_property(extra_label, "percent_visible", 0.0, 1.0, 0.2)
	extra_label.get_node("ExtraTween").start()
	extra_label.modulate = Color(1,1,1,1)
	
	damage_label.rect_position = $SelectIcon.position 
	extra_label.rect_position = $SelectIcon.position - extra_label.rect_size / 2.0
	
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.1)
	
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "rect_position:y", null, 
		damage_label.rect_position.y - 48, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "rect_position:x", null, 
		damage_label.rect_position.x + rand_range(-48,48), 1.4)
	
	damage_label.get_node("DamageTween").start()
	
	# wait until fade tween
	yield(damage_label.get_node("DamageTween"), "tween_completed")
	# wait unil jump tween
	yield(damage_label.get_node("DamageTween"), "tween_completed")
	
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.0)
	
	damage_label.get_node("DamageTween").interpolate_property(damage_label, "rect_position:y", null, 
		damage_label.rect_position.y + 78, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	
	damage_label.get_node("DamageTween").start()
	
	extra_label.get_node("ExtraTween").interpolate_property(extra_label, "modulate", null, Color(1,1,1,0), 0.3)
	extra_label.get_node("ExtraTween").start()
	
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
		emit_signal("selected", true)
	else:
		$SelectIcon.frame = 1
		$SelectIcon/SelectAnim.current_animation = "[stop]"
		$SelectIcon/SelectTween.interpolate_property($Sprite, "modulate", null, Color(1,1,1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$SelectIcon/SelectTween.start()
		emit_signal("selected", false)

func reset_buffs() -> void:
	self.atk = 0
	self.def = 0
	self.hit_eva = 0
	emit_signal("update_points")

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

func save_data() -> Dictionary:
	var data := .save_data()
	var saved_stats := {}
	for stat in STATS:
		saved_stats[stat] = get(stat)
	data["Stats"] = saved_stats
	data["Unlearned"] = $UnlearnedSkills.get_data()
	return data

func load_data(data: Dictionary) -> void:
	.load_data(data)
	$UnlearnedSkills.load_data(data["Unlearned"])
	for stat in data["Stats"]:
		set(stat, data["Stats"][stat])
