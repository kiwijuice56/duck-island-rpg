extends "res://main/overworld/overworld_map/_assets/interactable/interactable.gd"

export var direction := Vector2(32, 0)

func _input(event):
	if (not disabled and not overworld_ui.open) and Input.is_action_just_pressed("ui_accept"):
		call_deferred("jump", body)

func jump(player) -> void:
	disabled = true
	overworld_ui.hide_prompt()
	yield(body.jump(global_position + direction), "completed")

func body_entered(body) -> void:
	self.body = body
	disabled = false
	overworld_ui.display_prompt("Jump in: Z")

func body_exited(body) -> void:
	body = null
	disabled = true
	overworld_ui.hide_prompt()
