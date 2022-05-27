extends Camera2D

var res := Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

func toggle_cover(enable: bool) -> void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($Cover, "modulate", null, Color(1,1,1,.6) if enable else Color(1,1,1,0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()

func prioritize(nodes: Array):
	for node in nodes:
		node.z_index = 6

func deprioritize(nodes: Array):
	for node in nodes:
		node.z_index = 0

func toggle_shake(shake: bool) -> void:
	print_stack()
	if shake:
		$AnimationPlayer.current_animation = "shake"
	else:
		$AnimationPlayer.current_animation = "[stop]"
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(self, "offset", null, Vector2(), 0.3)
		tween.start()
		yield(tween, "tween_completed")
		tween.queue_free()

func pan(node: Node2D, pan_time: float, pan_offset: Vector2) -> void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "global_position", global_position, node.global_position + pan_offset, pan_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "zoom", null, Vector2(1,1), pan_time,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()

func fit(nodes: Array, fit_time: float, margin: int) -> void:
	var avg_pos := Vector2()
	for node in nodes:
		avg_pos += node.global_position
	avg_pos /= len(nodes)
	global_position = avg_pos
	
	var farthest := Vector2()
	for node in nodes:
		if (node.global_position - global_position).length() > (farthest-global_position).length():
			farthest = node.global_position 
	var dif = (farthest - global_position) + ((farthest - global_position).normalized()*margin)
	var farthest_clipped = dif.normalized() * (res.y/2)
	var scale_factor = dif.length()/farthest_clipped.length()
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "zoom", null, Vector2(1,1)*scale_factor, fit_time,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()
