extends Control

onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var item_container = $PanelContainer/MarginContainer/VBoxContainer/ItemPanel/VBoxContainer/GridContainer
onready var money_label = $PanelContainer/MarginContainer/VBoxContainer/MoneyPanel/VBoxContainer/Money
onready var experience_label = $PanelContainer/MarginContainer/VBoxContainer/MoneyPanel/VBoxContainer/Exp

# the node that opened this menu
var last = null
var last_func = ""

func _ready():
	disable()

func _input(event):
	if event.is_action_pressed("ui_accept", false):
		SoundPlayer.play_sound(SoundPlayer.accept)
		disable()
		yield(transition.transition_in(), "completed")
		disable()
		visible = false
		if last.has_method("enable"):
			last.enable()
		last.call(last_func)
	if event.is_action_pressed("ui_cancel", false):
		pass

func show_info(money: int, experience: int, items: Array) -> void:
	money_label.text = "Money: " + str(money)
	experience_label.text = "Exp: " + str(experience)

func enable():
	set_process_input(true)

func disable():
	set_process_input(false)
