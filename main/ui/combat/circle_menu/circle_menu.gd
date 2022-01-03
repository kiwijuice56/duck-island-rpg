extends Control

export var transition_time := 0.11
var index := 0 setget set_index

signal action_selected(selection)

func _ready() -> void:
	reset()
	disable()
	modulate = Color(1,1,1,0)

func reset() -> void:
	index = 0
	var rad_rot = (2*PI)/$Buttons.get_child_count()
	var rot = Vector2(64, 0).rotated(rad_rot)
	for button in $Buttons.get_children():
		button.rect_scale = Vector2(1,1)
		button.modulate = Color(1,1,1,1)
		button.rect_position = rot + Vector2(48,48)
		rot = rot.rotated(rad_rot)
	$Buttons.get_child($Buttons.get_child_count()-1).rect_scale = Vector2(2,2)
	$LabelContainer/Label.text = $Buttons.get_child($Buttons.get_child_count()-1).name

func _input(event):
	if event.is_action_pressed("ui_accept", false):
		yield(center_selection(), "completed")
		var button_name := $Buttons.get_child($Buttons.get_child_count()-1-index).name
		if button_name in ["Pass", "Defend", "Flee"]:
			yield(transition_out(), "completed")
			disable()
			emit_signal("action_selected", {"action_type": button_name})
		else:
			switch_menu(button_name)
	if event.is_action_pressed("ui_left", false):
		rotate(-1)
	if event.is_action_pressed("ui_right", false):
		rotate(1)

func select_action() -> void:
	reset()
	yield(transition_in(), "completed")
	enable()

func enable() -> void:
	set_process_input(true)
	$SkillContainer.disable()
	$ItemContainer.disable()

func disable() -> void:
	set_process_input(false)
	$SkillContainer.disable()
	$ItemContainer.disable()

func transition_in() -> void:
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func transition_out() -> void:
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func set_index(new_index: int):
	index = new_index
	index %= $Buttons.get_child_count()
	if index < 0:
		index = $Buttons.get_child_count() + index

func switch_menu(input: String) -> void:
	match input:
		"Skills":
			disable()
			yield($SkillContainer.transition_in(), "completed")
			$SkillContainer.enable()
		"Items":
			disable()
			yield($ItemContainer.transition_in(), "completed")
			$ItemContainer.enable()

func center_selection() -> void:
	for i in range($Buttons.get_child_count()):
		if not i == $Buttons.get_child_count()-1-index:
			$Tween.interpolate_property($Buttons.get_child(i), "modulate", Color(1,1,1,1), Color(1,1,1,0), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		else:
			$Tween.interpolate_property($Buttons.get_child(i), "rect_position", null, Vector2(48, 48), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func decenter_selection() -> void:
	for i in range($Buttons.get_child_count()):
		if not i == $Buttons.get_child_count()-1-index:
			$Tween.interpolate_property($Buttons.get_child(i), "modulate", Color(1,1,1,0), Color(1,1,1,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		else:
			$Tween.interpolate_property($Buttons.get_child(i), "rect_position", null, Vector2(100, 48), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func rotate(dir: int) -> void:
	$Tween.interpolate_property($Buttons.get_child($Buttons.get_child_count()-1-index), "rect_scale", null, Vector2(1,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.index += dir
	$Tween.interpolate_property($Buttons.get_child($Buttons.get_child_count()-1-index), "rect_scale", null, Vector2(2,2), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$LabelContainer/Label.text = $Buttons.get_child($Buttons.get_child_count()-1-index).name
	var rad_rot = (2*PI)/$Buttons.get_child_count()
	var rot = Vector2(64, 0).rotated(rad_rot * (index+1))
	for button in $Buttons.get_children():
		$Tween.interpolate_property(button, "rect_position", null, rot+Vector2(48,48), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		rot = rot.rotated(rad_rot)
	$Tween.start()
