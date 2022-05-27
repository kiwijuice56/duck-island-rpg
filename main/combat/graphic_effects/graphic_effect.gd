extends Node2D

const no_anim_wait := 0.55

export (String, "phys", "magic") var anim_class := "phys"
export var anim_name: String = ""

signal effect_complete
signal animation_impact_complete
onready var cam := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")

func animate(user: Node, targets: Array) -> void:
	if not anim_name == "":
		$AnimationPlayer.current_animation = anim_name
	$Timer.start(1)
	yield($Timer, "timeout")
	emit_signal("effect_complete")

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
