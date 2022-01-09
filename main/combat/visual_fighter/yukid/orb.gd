extends Sprite

export var on := false setget set_on

func set_on(new_val):
	if on == new_val:
		return
	else:
		on = new_val
		if on:
			on()
		else:
			off()

func on() -> void:
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Light2D/AnimationPlayer.current_animation = "flicker"

func off() -> void:
	$Light2D/AnimationPlayer.current_animation = "[stop]"
	$Light2D.energy = 0
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
