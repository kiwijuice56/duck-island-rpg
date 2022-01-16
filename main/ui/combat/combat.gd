extends Control

func set_turn_label(team) -> void:
	$TurnLabel/AnimationPlayer.current_animation = team
	yield($TurnLabel/AnimationPlayer, "animation_finished")
