extends Control

onready var player_party = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Combat/PressTurnCycle/PlayerParty")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var status_ui := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/StatusUI/Status")
onready var item_container = $PanelContainer/MarginContainer/VBoxContainer/ItemPanel/VBoxContainer/GridContainer
onready var money_label = $PanelContainer/MarginContainer/VBoxContainer/MoneyPanel/VBoxContainer/Money
onready var experience_label = $PanelContainer/MarginContainer/VBoxContainer/MoneyPanel/VBoxContainer/Exp

# the node that opened this menu
var last = null
var last_func = ""

signal pressed

func _ready():
	disable()

func _input(event):
	if event.is_action_pressed("ui_accept", false):
		emit_signal("pressed")
		
	if event.is_action_pressed("ui_cancel", false):
		pass

func show_info(money: int, experience: int, items: Array) -> void:
	money_label.text = "Money: " + str(money)
	experience_label.text = "Exp: " + str(experience)

func check_level_up() -> void:
	enable()
	yield(self, "pressed")
	SoundPlayer.play_sound(SoundPlayer.accept)
	disable()
	for fighter in player_party.get_children():
		if fighter.experience >= fighter.experience_to_level:
			yield(transition.transition_in(), "completed")
			var stat_count = fighter.level_up()
			status_ui.visible = true
			status_ui.initialize(fighter)
			yield(transition.transition_out(), "completed")
			status_ui.enable()
			yield(status_ui.show_level_up(fighter, stat_count), "completed")
			status_ui.disable()
			status_ui.visible = false
	yield(transition.transition_in(), "completed")
	visible = false
	if last.has_method("enable"):
		last.enable()
	last.call(last_func)

func enable():
	set_process_input(true)

func disable():
	set_process_input(false)
