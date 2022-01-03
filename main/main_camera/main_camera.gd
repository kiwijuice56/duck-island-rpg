extends Camera2D

func pan(node: Node2D, pan_time: float, pan_offset: Vector2) -> void:
	$Tween.interpolate_property(self, "global_position", null, node.global_position + pan_offset, pan_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
