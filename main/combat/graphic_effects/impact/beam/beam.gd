extends "res://main/combat/graphic_effects/impact/impact.gd"

func impact(target: Node) -> void:
	self.target = target
	$Light2D2.global_position = $Line2D.get_point_position(0)
	$Tween.interpolate_property(self, "modulate", Color(.5,.5,1,0), Color(2,3,2,1), 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_method(self, "update_point", $Line2D.points[1], target.global_position*2, .85, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$Tween.interpolate_property(self, "modulate", Color(2,2,2,1), Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	on_impact()
	emit_signal("complete")
	yield($Tween, "tween_completed")
	queue_free()

func update_point(new_pos):
	$Line2D.set_point_position(1, new_pos)
	$Light2D.global_position = new_pos
