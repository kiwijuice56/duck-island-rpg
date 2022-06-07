extends PanelContainer

export var speed_up_enabled := false
var choice_button := preload("res://main/ui/_assets/text_box/choice_button/ChoiceButton.tscn")

signal pressed

var icons := {
	"mii duck" : preload("res://main/ui/_assets/text_box/icons/mii_duck.png"),
	"yukid" : preload("res://main/ui/_assets/text_box/icons/yukid.png"),
	"lotad" : preload("res://main/ui/_assets/text_box/icons/lotad.png"),
	"sistar" : preload("res://main/ui/_assets/text_box/icons/lotad.png"),
}

var voices := {
	"mii duck" : preload("res://main/ui/_assets/text_box/voices/mii_duck.wav"),
	"yukid" : preload("res://main/ui/_assets/text_box/voices/yukid.wav"),
	"lotad" : preload("res://main/ui/_assets/text_box/voices/mii_duck.wav"),
	"sistar" : preload("res://main/ui/_assets/text_box/voices/yukid.wav"),
}

var selecting_choice := false
var sound_on := false
var visible_characters := -1 setget set_visible
onready var label := $HBoxContainer/RichTextLabel

func _input(event):
	if (event.is_action_pressed("ui_left", false) or event.is_action_pressed("ui_right", false)) and selecting_choice:
		SoundPlayer.play_sound(SoundPlayer.action)
	if Input.is_action_pressed("ui_accept") and speed_up_enabled:
		$Tween.playback_speed = 2.0
	else:
		$Tween.playback_speed = 1.0
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("pressed")

func display_choices(text: String, choices: Array, sec_per_char: float, after_delay: float) -> String:
	yield(display_text(text, sec_per_char, after_delay), "completed")
	$ChoiceContainer.visible = true
	for choice in choices:
		var button = choice_button.instance()
		button.text = choice
		button.modulate = Color(1,1,1,0)
		$Tween.interpolate_property(button, "modulate", null, Color(1,1,1,1), .125)
		$ChoiceContainer.add_child(button)
		button.focus_neighbour_top = button.get_path()
		button.focus_neighbour_bottom = button.get_path()
	$Tween.start()
	yield($Tween, "tween_completed")
	$ChoiceContainer.get_child(1).grab_focus()
	selecting_choice = true
	yield(self, "pressed")
	selecting_choice = false
	var index = get_focus_owner().get_index() - 1 # spacing is a child of ChoiceContainer also
	for child in $ChoiceContainer.get_children():
		if child is Button:
			child.queue_free()
	$ChoiceContainer.visible = false
	return choices[index]

func display_text(text: String, sec_per_char: float, after_delay: float, require_press := false, speaker := "") -> void:
	if speaker != "none" and len(speaker) > 0:
		sound_on = true
		$AudioStreamPlayer.stream = voices[speaker]
		$HBoxContainer/Icon.texture = icons[speaker]
		$HBoxContainer/Icon.visible = true
	else:
		sound_on = false
		$HBoxContainer/Icon.visible = false
	self.visible_characters = 0
	
	label.text = text
	$Tween.interpolate_property(self, "visible_characters", 0,  len(text), len(text) * sec_per_char, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	if (after_delay > 0):
		$Timer.start(after_delay)
		yield($Timer, "timeout")
	if require_press:
		yield(self, "pressed")

#func display_convo(convo: Array) -> void:
#	sound_on = true
#	for sentence in convo:
#		self.visible_characters = 0
#		$AudioStreamPlayer.stream = voices[sentence[0]]
#		$HBoxContainer/Icon.texture = icons[sentence[0]]
#		$HBoxContainer/Icon. visible = true
#		label.text = sentence[2]
#		$Tween.interpolate_property(self, "visible_characters", 0, len(sentence[2]), len(sentence[2]) * float(sentence[1]), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		$Tween.start()
#
#		yield($Tween, "tween_completed")
#		yield(self, "pressed")
#	sound_on = false

func set_visible(new_visible) -> void:
	if sound_on and int(new_visible) != visible_characters:
		$AudioStreamPlayer.playing = true
	visible_characters = new_visible
	label.visible_characters = visible_characters

func clear_text() -> void:
	$HBoxContainer/Icon.visible = false
	label.text = ""
