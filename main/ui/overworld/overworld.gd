extends Control

var open := false
onready var buttons := get_node("PopupMenu/HBoxContainer/PanelContainer/VBoxContainer")
onready var system_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SystemUI/System")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")

func _input(event):
	if event.is_action_pressed("menu", false):
		if open: close()
		else: open()
		hide_prompt()
	if open and (event.is_action_pressed("ui_up", false) or event.is_action_pressed("ui_down", false)) :
		SoundPlayer.play_sound(SoundPlayer.action)
	if open and event.is_action_pressed("ui_accept", false):
		SoundPlayer.play_sound(SoundPlayer.accept)

func _ready():
	$PopupMenu.modulate = Color(1,1,1,0)
	for button in buttons.get_children():
		button.connect("pressed", self, "button_pressed", [button.text])
	disable()
	
func button_pressed(button_name: String) -> void:
	match button_name:
		"System":
			disable()
			yield(transition.transition_in(), "completed")
			system_ui.visible = true
			system_ui.last = self
			system_ui.last_func = "choose_button"
			visible = false
			yield(transition.transition_out(), "completed")
			system_ui.enable()
			system_ui.edit_options()

func enable() -> void:
	set_process_input(true)
	buttons.get_child(0).grab_focus()
	for button in buttons.get_children():
		button.disabled = false

func disable() -> void:
	set_process_input(false)
	for button in buttons.get_children():
		button.disabled = true

func choose_button() -> void:
	buttons.get_child(0).grab_focus()

func open() -> void:
	SoundPlayer.play_sound(SoundPlayer.accept)
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld/Player").disable()
	enable()
	open = true
	$Tween.interpolate_property($PopupMenu, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	choose_button()

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
