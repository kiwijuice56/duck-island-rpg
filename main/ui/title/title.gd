extends Control

onready var save_file_handler := get_node("../../SaveFileHandler")
onready var buttons = $MarginContainer/VBoxContainer/VBoxContainer
onready var transition = get_tree().get_root().get_node("Main/Transition")
onready var save_ui = get_tree().get_root().get_node("Main/SaveUI/Save")
onready var system_ui = get_tree().get_root().get_node("Main/SystemUI/System")

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
	match button_name:
		"Load Game":
			disable()
			yield(transition.transition_in(), "completed")
			save_ui.visible = true
			save_ui.last = self
			visible = false
			yield(transition.transition_out(), "completed")
			save_ui.enable()
			save_ui.select_file()
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