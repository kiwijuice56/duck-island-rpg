extends Interactable
class_name Telescope

func _ready() -> void:
	$Camera2D.set_process(false)

func _input(event) -> void:
	if not disabled and  not $Camera2D.current and not overworld_ui.open and Input.is_action_just_pressed("ui_accept"):
		call_deferred("look", body)
	if $Camera2D.current and Input.is_action_just_pressed("ui_accept"):
		call_deferred("exit", body)

func body_entered(body) -> void:
	.body_entered(body)
	overworld_ui.display_prompt("Look: Z")

func look(player) -> void:
	$Camera2D.position = Vector2()
	disabled = true
	overworld_ui.hide_prompt()
	player.disable()
	yield(transition.transition_in(), "completed")
	$CanvasLayer/Cover.visible = true
	$AnimationPlayer.current_animation = "open_telescope"
	yield($AnimationPlayer, "animation_finished")
	$Camera2D.current = true
	yield(transition.transition_out(), "completed")
	$Camera2D.set_process(true)
	overworld_ui.display_prompt("Exit: Z")
	

func exit(player) -> void:
	set_process_input(false)
	overworld_ui.hide_prompt()
	$Camera2D.set_process(false)
	yield(transition.transition_in(), "completed")
	$AnimationPlayer.current_animation = "close_telescope"
	yield($AnimationPlayer, "animation_finished")
	$CanvasLayer/Cover.visible = false
	$Camera2D.current = false
	player.get_node("Camera2D").current = true
	yield(transition.transition_out(), "completed")
	player.enable()
	
