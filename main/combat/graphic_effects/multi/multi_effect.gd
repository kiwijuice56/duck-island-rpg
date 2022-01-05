extends "res://main/combat/graphic_effects/graphic_effect.gd"

export var wait_time := 0.1
export var impact_effect: PackedScene

func animate(user: Node, targets: Array) -> void:
	for i in range(len(targets)):
		$Timer.start(wait_time)
		yield($Timer, "timeout")
		cam.pan(targets[i], .1, Vector2())
		var new_impact = impact_effect.instance()
		add_child(new_impact)
		new_impact.impact(targets[i])
		if i == len(targets)-1:
			yield(new_impact, "complete")
	emit_signal("effect_complete")