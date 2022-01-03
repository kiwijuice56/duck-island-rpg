extends PanelContainer

onready var label := $RichTextLabel

func display_text(text: String, sec_per_char: float, after_delay: float) -> void:
	label.text = text
	$Tween.interpolate_property(label, "percent_visible", 0.0, 1.0, len(text) * sec_per_char, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Timer.start(after_delay)
	yield($Timer, "timeout")
