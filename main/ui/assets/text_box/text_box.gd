extends PanelContainer

export var speed_up_enabled := false

signal pressed

var icons := {
	"mii_duck" : preload("res://main/ui/assets/text_box/icons/mii_duck.png"),
	"yukid" : preload("res://main/ui/assets/text_box/icons/mii_duck.png")
}

onready var label := $HBoxContainer/RichTextLabel

func _input(event):
	if Input.is_action_pressed("ui_accept") and speed_up_enabled:
		$Tween.playback_speed = 2.0
	else:
		$Tween.playback_speed = 1.0
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("pressed")

func display_text(text: String, sec_per_char: float, after_delay: float) -> void:
	$HBoxContainer/Icon.visible = false
	label.text = text
	$Tween.interpolate_property(label, "percent_visible", 0.0, 1.0, len(text) * sec_per_char, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Timer.start(after_delay)
	yield($Timer, "timeout")

func display_convo(convo: Array) -> void:
	for sentence in convo:
		label.text = sentence[2]
		$HBoxContainer/Icon.texture = icons[sentence[0]]
		$HBoxContainer/Icon. visible = true
		$Tween.interpolate_property(label, "percent_visible", 0.0, 1.0, len(sentence[2]) * float(sentence[1]), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		yield(self, "pressed")
