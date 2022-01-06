extends "res://main/combat/graphic_effects/extra/extra_effect.gd"

func _ready() -> void:
	$AnimationPlayer.current_animation = "effect"
	yield($AnimationPlayer, "animation_finished")
	queue_free()
