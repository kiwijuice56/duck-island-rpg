extends CanvasLayer

func _ready() -> void:
	$ColorRect.visible= true
	$ColorRect.get_material().set_shader_param("dissolve_state", 0)

func transition_in() -> void:
	$AnimationPlayer.current_animation = "transition_in"
	yield($AnimationPlayer, "animation_finished")

func transition_out() -> void:
	$AnimationPlayer.current_animation = "transition_out"
	yield($AnimationPlayer, "animation_finished")

func heavy_transition_in() -> void:
	$AnimationPlayer.current_animation = "h_transition_in"
	yield($AnimationPlayer, "animation_finished")

func heavy_transition_out() -> void:
	$AnimationPlayer.current_animation = "h_transition_out"
	yield($AnimationPlayer, "animation_finished")
