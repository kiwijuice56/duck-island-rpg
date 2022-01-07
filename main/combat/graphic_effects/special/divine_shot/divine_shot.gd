extends "res://main/combat/graphic_effects/graphic_effect.gd"

export var beam: PackedScene
export var swoosh: PackedScene

func animate(user: Node, targets: Array) -> void:
	yield(cam.pan(targets[0], .5, Vector2()), "completed")
	cam.toggle_cover(true)
	cam.prioritize([user, targets[0]])
	user.get_node("SpriteAnimationPlayer").current_animation = "hold_physical"
	var new_beam = beam.instance()
	add_child(new_beam)
	$AudioStreamPlayer.playing = true
	new_beam.global_position = Vector2()
	new_beam.get_node("Line2D").set_point_position(0, user.get_node("SpearPivot").global_position-Vector2(32, -21))
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(user, "modulate", Color(1,1,1,0), Color(1.5,1.5,1.5,1), .95, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	new_beam.impact(targets[0])
	cam.toggle_shake(true)
	yield(new_beam, "complete")
	tween.interpolate_property(user, "modulate", Color(1.5,1.5,1.5,1), Color(1,1,1,1), .6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	for i in range(10):
		for target in targets:
			var new_swoosh = swoosh.instance()
			add_child(new_swoosh)
			new_swoosh.global_position = target.get_node("SelectIcon").global_position
		$Timer.start(.1)
		yield($Timer, "timeout")
	cam.toggle_shake(false)
	$Timer.start(.5)
	yield($Timer, "timeout")
	user.get_node("SpriteAnimationPlayer").current_animation = "idle"
	cam.deprioritize([user, targets[0]])
	cam.toggle_cover(false)
	emit_signal("effect_complete")
	tween.queue_free()
