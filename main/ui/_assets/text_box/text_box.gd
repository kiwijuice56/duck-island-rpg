extends PanelContainer

export var speed_up_enabled := false

signal pressed

var icons := {
	"mii_duck" : preload("res://main/ui/_assets/text_box/icons/mii_duck.png"),
	"yukid" : preload("res://main/ui/_assets/text_box/icons/yukid.png")
}

var voices := {
	"mii_duck" : preload("res://main/ui/_assets/text_box/voices/mii_duck.wav"),
	"yukid" : preload("res://main/ui/_assets/text_box/voices/yukid.wav")
}

var sound_on := false
var visible_characters := -1 setget set_visible
onready var label := $HBoxContainer/RichTextLabel

func _input(event):
	if Input.is_action_pressed("ui_accept") and speed_up_enabled:
		$Tween.playback_speed = 2.0
	else:
		$Tween.playback_speed = 1.0
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("pressed")

func display_text(text: String, sec_per_char: float, after_delay: float) -> void:
	self.visible_characters = 0
	$HBoxContainer/Icon.visible = false
	label.text = text
	$Tween.interpolate_property(self, "visible_characters", 0,  len(text), len(text) * sec_per_char, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Timer.start(after_delay)
	yield($Timer, "timeout")

func display_convo(convo: Array) -> void:
	sound_on = true
	for sentence in convo:
		self.visible_characters = 0
		$AudioStreamPlayer.stream = voices[sentence[0]]
		$HBoxContainer/Icon.texture = icons[sentence[0]]
		$HBoxContainer/Icon. visible = true
		label.text = sentence[2]
		$Tween.interpolate_property(self, "visible_characters", 0, len(sentence[2]), len(sentence[2]) * float(sentence[1]), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		
		yield($Tween, "tween_completed")
		yield(self, "pressed")
	sound_on = false

func set_visible(new_visible) -> void:
	if sound_on and int(new_visible) != visible_characters:
		$AudioStreamPlayer.playing = true
	visible_characters = new_visible
	label.visible_characters = visible_characters
	
	
	
