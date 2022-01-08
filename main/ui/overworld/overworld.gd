extends Control

func display_prompt(text: String) -> void:
	$Prompt/Label.text = text
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")

func hide_prompt() -> void:
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,0), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")
