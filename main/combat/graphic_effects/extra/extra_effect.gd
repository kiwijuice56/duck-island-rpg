extends Sprite

func _ready() -> void:
	$AnimationPlayer.current_animation = "effect"
	yield($AnimationPlayer, "animation_finished")
	queue_free()
