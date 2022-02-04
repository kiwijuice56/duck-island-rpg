extends Control
onready var save_file_handler := get_node("../../../SaveFileHandler")
onready var file_container = get_node("MarginContainer/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")

export var save_button = preload("res://main/ui/save/save_button/SaveButton.tscn")

var last = null
var last_func =""

var mode := "load"

func _ready() -> void:
	initialize()
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

func load_file() -> void:
	file_container.get_child(0).get_node("Button").grab_focus()
	mode = "load"

func save_file() -> void:
	file_container.get_child(0).get_node("Button").grab_focus()
	mode = "save"

func initialize() -> void:
	for child in file_container.get_children():
		file_container.remove_child(child)
		child.queue_free()
	var files = save_file_handler.get_files(true)
	for i in range(99):
		var new_save_button = save_button.instance()
		if i < len(files):
			var loaded_file = ResourceLoader.load(files[i])
			new_save_button.initialize(loaded_file)
		else:
			new_save_button.initialize(null)
		new_save_button.get_node("Button").connect("pressed", self, "pressed", [new_save_button])
		file_container.add_child(new_save_button)

func pressed(button):
	if mode == "load":
		if not save_file_handler.file_exists(button.get_index(), true):
			return
		get_focus_owner().release_focus()
		disable()
		yield(transition.transition_in(), "completed")
		save_file_handler.call_deferred("load_file", button.get_index(), true)
		visible = false
		yield(save_file_handler, "file_managing_complete")
		yield(transition.transition_out(), "completed")
	if mode == "save":
		var saved_index = button.get_index()
		get_focus_owner().release_focus()
		disable()
		save_file_handler.call_deferred("save_file", saved_index, true)
		yield(save_file_handler, "file_managing_complete")
		initialize()
		file_container.get_child(saved_index).get_node("Button").grab_focus()
		enable()

func enable() -> void:
	set_process_input(true)

func disable() -> void:
	set_process_input(false)
