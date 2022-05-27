extends MultiEffect

# some multi effect code needed to be copied and used here to allow for special camera effects

export var particle_skulls: PackedScene

func animate(user: Node, targets: Array) -> void:
	cam.toggle_shake(true)
	$EarthquakeSound.playing = true
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
	
	.animate(user, targets)
	yield(self, "extension_effect")
	
	for particle in particles:
		$Tween.interpolate_property(particle, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.35)
	$Tween.interpolate_property($CanvasLayer/ColorRect, "modulate", Color(1,1,1,1), Color(1,1,1,0), .65)
	$Tween.interpolate_property($EarthquakeSound, "volume_db", null, -35, .75)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	for particle in particles:
		particle.queue_free()
	cam.toggle_shake(false)
	emit_signal("effect_complete")
