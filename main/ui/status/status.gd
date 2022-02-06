extends Control

onready var player_party = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Combat/PressTurnCycle/PlayerParty")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var save_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SaveUI/Save")
onready var system_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SystemUI/System")
onready var stat_container = $PanelContainer/MarginContainer/VBoxContainer/StarBarContainer/VBoxContainer
onready var name_label = $PanelContainer/MarginContainer/VBoxContainer/NameLabelContainer/Label
onready var exp_label = $PanelContainer/MarginContainer/VBoxContainer/ExpLabelContainer/Label

# the node that opened this menu
var last = null
var last_func = ""

var fighters := []
var idx := 0

func _ready():
	disable()

func _input(event):
	if event.is_action_pressed("ui_left", false):
		idx -= 1
		if idx < 0:
			idx = len(fighters)-1
		initialize(fighters[idx])
		SoundPlayer.play_sound(SoundPlayer.switch)
	if event.is_action_pressed("ui_right", false):
		idx += 1
		if idx == len(fighters):
			idx = 0
		initialize(fighters[idx])
		SoundPlayer.play_sound(SoundPlayer.switch)
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

func show_status() -> void:
	idx = 0
	fighters = player_party.get_children()
	initialize(fighters[0])

func initialize(fighter: Node) -> void:
	name_label.text = fighter.save_id.capitalize()
	exp_label.text = ""
	var stats = ["strength", "magic", "vitality", "luck", "agility"]
	for i in range(5):
		stat_container.get_child(i).set_stat(stats[i], fighter.get(stats[i]))

func enable():
	set_process_input(true)

func disable():
	set_process_input(false)
