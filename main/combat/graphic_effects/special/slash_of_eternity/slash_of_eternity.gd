extends "res://main/combat/graphic_effects/graphic_effect.gd"

export var slash: PackedScene
export var flicker: PackedScene
export var swoosh: PackedScene

func animate(user: Node, targets: Array) -> void:
	var angle = 0
	yield(cam.pan(targets[0].get_node("SelectIcon"), .5, Vector2(0,-32)), "completed")
	var old_speed1 = targets[0].get_node("BasicAnimationPlayer").playback_speed 
	var old_speed2 = targets[0].get_node("SpriteAnimationPlayer").playback_speed 
	
	if not targets[0].calculation_cache["contact"] in ["absorb", "miss", "null", "repel"]:
		targets[0].get_node("SpriteAnimationPlayer").playback_speed = 2
		targets[0].get_node("BasicAnimationPlayer").playback_speed = 2
	
	cam.toggle_cover(true)
	cam.prioritize([user] + [targets[0]])
	user.get_node("SpriteAnimationPlayer").current_animation = "hold_magic"
	cam.toggle_shake(true)
	for _i in range(35):
		angle = rand_range(0, 360)
		var new_slash = slash.instance()
		new_slash.rotation_degrees = angle
		add_child(new_slash)
		
		for _j in range(rand_range(2, 6)):
			var new_flicker = flicker.instance()
			new_flicker.rotation_degrees = rand_range(0,360)
			add_child(new_flicker)
			new_flicker.global_position = targets[0].get_node("SelectIcon").global_position
		
		new_slash.global_position = targets[0].get_node("SelectIcon").global_position
		
		var new_swoosh = swoosh.instance()
		add_child(new_swoosh)
		new_swoosh.global_position = targets[0].get_node("SelectIcon").global_position
		$Timer.start(.13 + rand_range(-.05, .05))
		
		if not targets[0].calculation_cache["contact"] in ["absorb", "miss", "null", "repel"]:
			targets[0].get_node("BasicAnimationPlayer").current_animation = "hurt"
			targets[0].get_node("SpriteAnimationPlayer").current_animation = "hurt"
		yield($Timer, "timeout")
	targets[0].get_node("BasicAnimationPlayer").playback_speed = old_speed1
	targets[0].get_node("SpriteAnimationPlayer").playback_speed = old_speed2
	targets[0].on_impact()
	
	$Timer.start(.5)
	yield($Timer, "timeout")
	cam.toggle_shake(false)
	user.get_node("SpriteAnimationPlayer").current_animation = "idle"
	cam.toggle_cover(false)
	cam.deprioritize([user] + [targets[0]])
	
	emit_signal("effect_complete")
