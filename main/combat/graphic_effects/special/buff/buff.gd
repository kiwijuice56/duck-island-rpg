extends "res://main/combat/graphic_effects/graphic_effect.gd"

export var flicker: PackedScene
export var ghost_swoosh: PackedScene

func animate(user: Node, targets: Array) -> void:
	var angle = 0
	yield(cam.pan(targets[0], .5, Vector2()), "completed")
	$AudioStreamPlayer2.playing = true
	cam.toggle_cover(true)
	cam.prioritize([user] +targets)
	if user.get_node("SpriteAnimationPlayer").has_animation("hold_magic"):
		user.get_node("SpriteAnimationPlayer").current_animation = "hold_magic"
	
	for target in targets:
		for _i in range(7):
			
			
			var new_swoosh = ghost_swoosh.instance()
			add_child(new_swoosh)
			new_swoosh.global_position = target.get_node("SelectIcon").global_position + Vector2(randi() % 64 - 32, randi() % 64 - 32)
			$Timer.start(.03)
			yield($Timer, "timeout")
	
	for target in targets:
		
		yield(cam.pan(target.get_node("SelectIcon"), .3, Vector2()), "completed")
		for _j in range(16):
				var new_flicker = flicker.instance()
				add_child(new_flicker)
				new_flicker.global_position = target.get_node("SelectIcon").global_position + Vector2(randi() % 128 - 64, -randi() % 32)
				new_flicker.rotation_degrees = -90
		
		$Timer.start(.2)
		yield($Timer, "timeout")
		target.on_impact()
		$AudioStreamPlayer.playing = true
	$Timer.start(.5)
	yield($Timer, "timeout")
	
	if user.get_node("SpriteAnimationPlayer").has_animation("idle"):
		user.get_node("SpriteAnimationPlayer").current_animation = "idle"
	cam.toggle_cover(false)
	cam.deprioritize([user] + targets)
	
	emit_signal("effect_complete")
