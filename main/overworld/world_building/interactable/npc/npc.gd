extends Interactable
class_name Npc

func _input(event):
	if not disabled and not overworld_ui.open and Input.is_action_just_pressed("ui_accept"):
		talk(body)

func body_entered(body) -> void:
	.body_entered(body)
	overworld_ui.display_prompt("Talk: Z")

func talk(player) -> void:
	disabled = true
	player.disable()
	yield($Cutscene.play([player, self]), "completed")
	player.enable()
