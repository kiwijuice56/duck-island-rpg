extends GraphicEffect
class_name MultiEffect

export var wait_time := 0.1
export var impact_effect: PackedScene

func animate(user: Node, targets: Array) -> void:
	if not anim_name == "":
		$AnimationPlayer.current_animation = anim_name
	cam.toggle_cover(true)
	cam.prioritize([user] + targets)
	for i in range(len(targets)):
		cam.pan(targets[i].get_node("SelectIcon"), 0.25, Vector2(-100 if targets[i].global_position.x > cam.global_position.x else 100, 0))
		yield(animate_user(user), "completed") # pause until ready to add effects mid attack animation
		var new_impact = impact_effect.instance()
		add_child(new_impact)
		new_impact.impact(targets[i])
		if i == len(targets)-1:
			yield(new_impact, "complete")
		$Timer.start(wait_time)
		yield($Timer, "timeout")
	reset_user_animation(user)
	cam.deprioritize([user] + targets)
	cam.toggle_cover(false)
	if not has_extension:
		emit_signal("effect_complete")
	else:
		emit_signal("extension_effect")
