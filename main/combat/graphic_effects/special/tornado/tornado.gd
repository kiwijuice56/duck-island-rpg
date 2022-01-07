extends "res://main/combat/graphic_effects/graphic_effect.gd"

export var impact_effect: PackedScene
export var slash: PackedScene
export var flicker: PackedScene
export var swoosh: PackedScene

func animate(user: Node, targets: Array) -> void:
	var angle = 0
	yield(cam.pan(targets[0], .5, Vector2()), "completed")

	
	cam.toggle_cover(true)
	cam.prioritize([user] +targets)
	user.get_node("SpriteAnimationPlayer").current_animation = "hold_magic"
	for _i in range(5):
		for target in targets:
			var new_swoosh = swoosh.instance()
			add_child(new_swoosh)
			new_swoosh.global_position = target.get_node("SelectIcon").global_position
		$Timer.start(.2)
		yield($Timer, "timeout")
	$Timer.start(.05)
	yield($Timer, "timeout")
	for i in range(len(targets)):
		cam.pan(targets[i], .1, Vector2())
		var new_impact = impact_effect.instance()
		add_child(new_impact)
		new_impact.impact(targets[i])
		
		for _j in range(12):
			var new_flicker = flicker.instance()
			add_child(new_flicker)
			new_flicker.global_position = targets[i].get_node("SelectIcon").global_position - Vector2(rand_range(-32,32), rand_range(-32,32))
		
		var new_swoosh = swoosh.instance()
		add_child(new_swoosh)
		new_swoosh.global_position = targets[i].get_node("SelectIcon").global_position
		
		if i == len(targets)-1:
			yield(new_impact, "complete")
		$Timer.start(0.6)
		yield($Timer, "timeout")
	user.get_node("SpriteAnimationPlayer").current_animation = "idle"
	cam.toggle_cover(false)
	cam.deprioritize([user] + targets)
	
	emit_signal("effect_complete")
