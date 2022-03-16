extends Control

onready var save_file_handler := get_node("../../../SaveFileHandler")
onready var buttons = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var save_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SaveUI/Save")
onready var system_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SystemUI/System")

# the node that opened this menu
var last = null
var last_func = ""

func _ready():
	for child in buttons.get_children():
		child.connect("pressed", self, "pressed", [child.name])
	if save_file_handler.get_file_count(true) == 0:
		buttons.get_node("Load Game").disabled = true
	enable()
	choose_button()

func _input(event):
	if event.is_action_pressed("ui_up", false) or  event.is_action_pressed("ui_down", false):
		SoundPlayer.play_sound(SoundPlayer.action)
	if event.is_action_pressed("ui_accept", false):
		SoundPlayer.play_sound(SoundPlayer.accept)

func pressed(button_name: String) -> void:
	disable()
	yield(transition.transition_in(), "completed")
	match button_name:
		"New Game":
			save_file_handler.call_deferred("load_file", -1, true)
			visible = false
			yield(save_file_handler, "file_managing_complete")
			yield(transition.transition_out(), "completed")
		"Load Game":
			save_ui.visible = true
			save_ui.last = self
			save_ui.last_func = "choose_button"
			save_ui.label.text = "Load what file?"
			visible = false
			yield(transition.transition_out(), "completed")
			save_ui.enable()
			save_ui.load_file()
		"System":
			system_ui.visible = true
			system_ui.last = self
			system_ui.last_func = "choose_button"
			visible = false
			yield(transition.transition_out(), "completed")
			system_ui.enable()
			system_ui.edit_options()
		"Quit":
			get_tree().quit()

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
