extends "res://main/combat/graphic_effects/graphic_effect.gd"

# some multi effect code needed to be copied and used here to allow for special camera effects

export var particle_skulls: PackedScene
export var impact_effect: PackedScene
export var wait_time := 0.55

func animate(user: Node, targets: Array) -> void:
	cam.toggle_shake(true)
	var particles = []
	for fighter in targets:
		var new_particle = particle_skulls.instance()
		add_child(new_particle)
		new_particle.global_position = fighter.get_node("SelectIcon").global_position
		particles.append(new_particle)
		$Tween.interpolate_property(new_particle, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.35)
	$Tween.interpolate_property($CanvasLayer/ColorRect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
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
	
	for particle in particles:
		$Tween.interpolate_property(particle, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.35)
	$Tween.interpolate_property($CanvasLayer/ColorRect, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.15)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	for particle in particles:
		particle.queue_free()
	cam.toggle_shake(false)
	emit_signal("effect_complete")
