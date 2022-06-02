extends Interactable

export var direction := Vector2(32, 0)
export var going_into_water := false

func _input(event):
	if (not disabled and not overworld_ui.open) and Input.is_action_just_pressed("ui_accept"):
		call_deferred("jump", body)

func jump(player) -> void:
	disabled = true
	overworld_ui.hide_prompt()
	yield(body.jump(global_position + direction, going_into_water), "completed")

func body_entered(body) -> void:
	self.body = body
	disabled = false
	overworld_ui.display_prompt("Jump in: Z" if going_into_water else "Jump out: Z")

func body_exited(body) -> void:
	body = null
	disabled = true
	overworld_ui.hide_prompt()
