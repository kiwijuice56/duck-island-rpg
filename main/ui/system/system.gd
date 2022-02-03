extends Control

onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var music_slider = get_node("MarginContainer/PanelContainer/ScrollContainer/VBoxContainer/MusicVolume/HSlider")
var last 
var last_func = ""

func _ready() -> void:
	music_slider.connect("value_changed", self, "music_slider_changed")
	disable()

func _input(event) -> void:
	if event.is_action_pressed("ui_up", false) or  event.is_action_pressed("ui_down", false):
		SoundPlayer.play_sound(SoundPlayer.action)
	if event.is_action_pressed("ui_accept", false):
		SoundPlayer.play_sound(SoundPlayer.accept)
	if event.is_action_pressed("ui_cancel", false):
		SoundPlayer.play_sound(SoundPlayer.cancel)
		disable()
		yield(transition.transition_in(), "completed")
		last.visible = true
		disable()
		visible = false
		yield(transition.transition_out(), "completed")
		last.enable()
		last.call(last_func)

func edit_options() -> void:
	music_slider.grab_focus()

func music_slider_changed(val) -> void:
	MusicPlayer.global_volume = music_slider.value

func enable() -> void:
	set_process_input(true)

func disable() -> void:
	set_process_input(false)
