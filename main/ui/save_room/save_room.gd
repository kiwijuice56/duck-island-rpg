extends Control

onready var save_file_handler := get_node("../../../SaveFileHandler")
onready var buttons = $MarginContainer/PanelContainer/VBoxContainer
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var save_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SaveUI/Save")
onready var system_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SystemUI/System")

# the node that opened this menu
var last = null
var last_func = ""

func _ready():
	for child in buttons.get_children():
		child.connect("pressed", self, "pressed", [child.name])
	disable()

func _input(event):
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
		if last.has_method("enable"):
			last.enable()
		last.call(last_func)

func pressed(button_name: String) -> void:
	match button_name:
		"Save Game":
			disable()
			yield(transition.transition_in(), "completed")
			save_ui.visible = true
			save_ui.last = self
			save_ui.last_func = "choose_button"
			visible = false
			yield(transition.transition_out(), "completed")
			save_ui.enable()
			save_ui.save_file()
		"Load Game":
			disable()
			yield(transition.transition_in(), "completed")
			save_ui.visible = true
			save_ui.last = self
			save_ui.last_func = "choose_button"
			visible = false
			yield(transition.transition_out(), "completed")
			save_ui.enable()
			save_ui.load_file()
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

func choose_button() -> void:
	buttons.get_child(0).grab_focus()

func enable():
	set_process_input(true)
	for child in buttons.get_children():
		child.disabled = false

func disable():
	set_process_input(false)
	for child in buttons.get_children():
		child.disabled = true
