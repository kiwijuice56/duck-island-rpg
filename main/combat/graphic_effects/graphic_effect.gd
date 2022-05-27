extends Node2D
class_name GraphicEffect

const no_anim_wait := 0.55

export (String, "phys", "magic") var anim_class := "phys"
export var anim_name: String = ""
export var has_extension := false # used for extending scripts to perform more actions instead of emitting the final signal

signal effect_complete
signal extension_effect
signal animation_impact_complete
onready var cam := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")

func animate(user: Node, targets: Array) -> void:
	if not anim_name == "":
		$AnimationPlayer.current_animation = anim_name
	$Timer.start(1)
	yield($Timer, "timeout")
	if not has_extension:
		emit_signal("effect_complete")
	else:
		emit_signal("extension_effect")

func animate_user(user: Node) -> void:
	if not user.get_node("SpriteAnimationPlayer").has_animation(anim_class):
		var timer = Timer.new() # needs a yield for the other methods to not error when they attempt to yield this
		add_child(timer)
		timer.start(no_anim_wait)
		yield(timer, "timeout")
	else:
		user.get_node("SpriteAnimationPlayer").current_animation = "phys"
		yield(user, "animation_impact")
	# other methods still need to reset user idle animation

func reset_user_animation(user: Node) -> void:
	if user.get_node("SpriteAnimationPlayer").has_animation("idle"):
			user.get_node("SpriteAnimationPlayer").current_animation = "idle"
