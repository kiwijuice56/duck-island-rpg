extends Control
onready var save_file_handler := get_node("../../SaveFileHandler")
onready var file_container = get_node("MarginContainer/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer")

export var save_button = preload("res://main/ui/save/save_button/SaveButton.tscn")

func _ready() -> void:
	initialize()
	disable()

func _input(event) -> void:
	if event.is_action_pressed("ui_up", false) or  event.is_action_pressed("ui_down", false):
		SoundPlayer.play_sound(SoundPlayer.action)
	if event.is_action_pressed("ui_accept", false):
		SoundPlayer.play_sound(SoundPlayer.accept)

func select_file() -> void:
	file_container.get_child(0).get_node("Button").grab_focus()

func initialize() -> void:
	for child in file_container.get_children():
		file_container.remove_child(child)
		child.queue_free()
	for file in save_file_handler.get_files(true):
		var loaded_file = ResourceLoader.load(file)
		var new_save_button = save_button.instance()
		new_save_button.initialize(loaded_file)
		file_container.add_child(new_save_button)

func enable() -> void:
	set_process_input(true)

func disable() -> void:
	set_process_input(false)
