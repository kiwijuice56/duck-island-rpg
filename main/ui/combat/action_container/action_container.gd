extends PanelContainer

export var transition_time := 0.125

func _input(event):
	if event.is_action_pressed("ui_cancel", false):
		disable()
		yield(transition_out(), "completed")
		get_parent().enable()

func enable() -> void:
	get_node("ScrollContainer").get_child(0).get_child(0).grab_focus()
	set_process_input(true)

func disable() -> void:
	if get_focus_owner():
		get_focus_owner().release_focus()
	set_process_input(false)

func transition_in() -> void:
	$ScrollContainer.modulate = Color(1,1,1,0)
	$Tween.interpolate_property(self, "rect_scale", Vector2(0,1), Vector2(1,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property($ScrollContainer, "modulate", null, Color(1,1,1,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func transition_out() -> void:
	$Tween.interpolate_property($ScrollContainer, "modulate", Color(1,1,1,1), Color(1,1,1,0), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(self, "rect_scale", Vector2(1,1), Vector2(0,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	get_parent().decenter_selection()
