extends Interactable
class_name Npc

export(Array, Array, String) var convo := []

func _input(event):
	if not disabled and not overworld_ui.open and Input.is_action_just_pressed("ui_accept"):
		call_deferred("talk", body)

func body_entered(body) -> void:
	.body_entered(body)
	overworld_ui.display_prompt("Talk: Z")

func talk(player) -> void:
	disabled = true
	overworld_ui.hide_prompt()
	player.disable()
	overworld_ui.get_node("TextBox").label.text = ""
	overworld_ui.get_node("TextBox/HBoxContainer/Icon").visible = false
	$Tween.interpolate_property(overworld_ui.get_node("TextBox"), "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2)
	$Tween.start()
	yield($Tween, "tween_completed")
	yield(overworld_ui.get_node("TextBox").display_convo(convo), "completed")
	$Tween.interpolate_property(overworld_ui.get_node("TextBox"), "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2)
	$Tween.start()
	yield($Tween, "tween_completed")
	player.enable()
