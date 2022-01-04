extends Camera2D

var res := Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

func pan(node: Node2D, pan_time: float, pan_offset: Vector2) -> void:
	$Tween.interpolate_property(self, "global_position", null, node.global_position + pan_offset, pan_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "zoom", null, Vector2(1,1), pan_time,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func fit(nodes: Array, fit_time: float, margin: int) -> void:
	var avg_pos := Vector2()
	for node in nodes:
		avg_pos += node.global_position
	avg_pos /= len(nodes)
	print(avg_pos)
	global_position = avg_pos
	
	var farthest := Vector2()
	for node in nodes:
		if (node.global_position - global_position).length() > (farthest-global_position).length():
			farthest = node.global_position 
			print(node.name)
	var dif = (farthest - global_position) + ((farthest - global_position).normalized()*margin)
	var farthest_clipped = dif.normalized() * (res.y/2)
	var scale_factor = dif.length()/farthest_clipped.length()
	$Tween.interpolate_property(self, "zoom", null, Vector2(1,1)*scale_factor, fit_time,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
