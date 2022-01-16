extends Control

var open := false
onready var buttons := get_node("PopupMenu/HBoxContainer/PanelContainer/VBoxContainer")

func _input(event):
	if event.is_action_pressed("menu", false):
		if open: close()
		else: open()
		hide_prompt()
	if open and (event.is_action_pressed("ui_up", false) or event.is_action_pressed("ui_down", false)) :
		SoundPlayer.play_sound(SoundPlayer.action)

func _ready():
	$PopupMenu.modulate = Color(1,1,1,0)
	disable()

func enable() -> void:
	set_process_input(true)

func disable() -> void:
	set_process_input(false)

func open() -> void:
	SoundPlayer.play_sound(SoundPlayer.accept)
	get_tree().get_root().get_node("Main/Overworld/Player").disable()
	open = true
	$Tween.interpolate_property($PopupMenu, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	buttons.get_child(0).grab_focus()

func close() -> void:
	SoundPlayer.play_sound(SoundPlayer.cancel)
	open = false
	$Tween.interpolate_property($PopupMenu, "modulate", null, Color(1,1,1,0), 0.1)
	$Tween.start()
	get_tree().get_root().get_node("Main/Overworld/Player").enable()

func display_prompt(text: String) -> void:
	$Prompt/Label.text = text
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")

func hide_prompt() -> void:
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,0), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")
