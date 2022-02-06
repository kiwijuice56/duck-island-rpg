extends Control

var open := false
onready var buttons := get_node("PopupMenu/HBoxContainer/PanelContainer/VBoxContainer")
onready var system_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SystemUI/System")
onready var status_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/StatusUI/Status")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")

signal menu_opened

func _input(event):
	if event.is_action_pressed("menu", false):
		hide_prompt()
		if open: close()
		else: open()
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
	if not open:
		return
	disable()
	yield(transition.transition_in(), "completed")
	visible = false
	match button_name:
		"System":
			system_ui.visible = true
			system_ui.last = self
			system_ui.last_func = "choose_button"
			yield(transition.transition_out(), "completed")
			system_ui.enable()
			system_ui.edit_options()
		"Check":
			status_ui.visible = true
			status_ui.last = self
			status_ui.last_func = "choose_button"
			status_ui.show_status()
			yield(transition.transition_out(), "completed")
			status_ui.enable()

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
	MusicPlayer.play_music(MusicPlayer.menu)
	$MiniTransition.transition_in()
	# calling disable also disables this node due to needing to stop menu opening in other menus
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld/Player").disable()
	enable()
	open = true
	$Tween.interpolate_property($PopupMenu, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	choose_button()
	emit_signal("menu_opened")

func close() -> void:
	SoundPlayer.play_sound(SoundPlayer.cancel)
	MusicPlayer.play_music(MusicPlayer.island)
	open = false
	yield($MiniTransition.transition_out(), "completed")
	$Tween.interpolate_property($PopupMenu, "modulate", null, Color(1,1,1,0), 0.1)
	$Tween.start()
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld/Player").enable()

func display_prompt(text: String) -> void:
	if open:
		return
	$Prompt/Label.text = text
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")

func hide_prompt() -> void:
	$Tween.stop($Prompt, "modulate")
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,0), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")
