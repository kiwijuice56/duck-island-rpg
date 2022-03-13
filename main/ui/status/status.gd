extends Control

onready var player_party = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Combat/PressTurnCycle/PlayerParty")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var save_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SaveUI/Save")
onready var system_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SystemUI/System")
onready var skill_container = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SkillContainer
onready var stat_container = $PanelContainer/MarginContainer/VBoxContainer/StarBarContainer/VBoxContainer
onready var name_label = $PanelContainer/MarginContainer/VBoxContainer/NameLabelContainer/Label
onready var exp_label = $PanelContainer/MarginContainer/VBoxContainer/ExpLabelContainer/Label

# the node that opened this menu
var last = null
var last_func = ""

var choosing_stats := false
var leveling_up := false
var fighters := []
var idx := 0

const STATS = ["strength", "magic", "vitality", "luck", "agility"]

var portraits = {
	"yukid": preload("res://main/ui/status/portraits/yukid.png"),
	"duckling": preload("res://main/ui/status/portraits/duckling.png"),
}

signal pressed

func _ready():
	disable()

func _input(event):
	if (event.is_action_pressed("ui_up", false) or event.is_action_pressed("ui_down", false)) and choosing_stats:
		SoundPlayer.play_sound(SoundPlayer.action)
	if event.is_action_pressed("ui_left", false) and not leveling_up:
		idx -= 1
		if idx < 0:
			idx = len(fighters)-1
		initialize(fighters[idx])
		SoundPlayer.play_sound(SoundPlayer.switch)
	if event.is_action_pressed("ui_right", false) and not leveling_up:
		idx += 1
		if idx == len(fighters):
			idx = 0
		initialize(fighters[idx])
		SoundPlayer.play_sound(SoundPlayer.switch)
	if event.is_action_pressed("ui_cancel", false) and not leveling_up:
		SoundPlayer.play_sound(SoundPlayer.cancel)
		disable()
		yield(transition.transition_in(), "completed")
		last.visible = true
		visible = false
		yield(transition.transition_out(), "completed")
		if last.has_method("enable"):
			last.enable()
		last.call(last_func)
	if event.is_action_pressed("ui_accept", false):
		emit_signal("pressed")

func show_status() -> void:
	$TextBox.visible = false
	idx = 0
	fighters = player_party.get_children()
	initialize(fighters[0])
	leveling_up = false

func show_level_up(fighter: Node, stat_count: int) -> void:
	fighters = player_party.get_children()
	idx = fighter.get_index()
	leveling_up = true
	
	# show text box
	$TextBox.clear_text()
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($TextBox, "modulate", Color(1,1,1,0), Color(1,1,1,1), .25)
	tween.start()
	$TextBox.visible = true
	yield(tween, "tween_completed")
	yield($TextBox.display_text("%s leveled up! Distribute their stats." %  (fighter.save_id.capitalize()), 0.01, .25, true), "completed")
	tween.interpolate_property($TextBox, "modulate", Color(1,1,1,1), Color(1,1,1,0), .25)
	tween.start()
	yield(tween, "tween_completed")
	$TextBox.clear_text()
	var confirm := false
	while not confirm:
		choosing_stats = true
		stat_container.get_child(0).grab_focus()
		var stat_increases := [0,0,0,0,0]
		for _i in range(stat_count):
			yield(self, "pressed")
			stat_increases[get_focus_owner().get_index()] += 1
			fighter.set(STATS[get_focus_owner().get_index()], fighter.get(STATS[get_focus_owner().get_index()])+1)
			initialize(fighter)
			SoundPlayer.play_sound(SoundPlayer.accept)
		get_focus_owner().release_focus()
		choosing_stats = false
		tween.interpolate_property($TextBox, "modulate", Color(1,1,1,0), Color(1,1,1,1), .25)
		tween.start()
		yield(tween, "tween_completed")
		var choice : String = yield($TextBox.display_choices("Are you sure that you want to increase these stats?", ["> Yes", "> No"], 0.01, 0), "completed")
		tween.interpolate_property($TextBox, "modulate", Color(1,1,1,1), Color(1,1,1,0), .25)
		tween.start()
		yield(tween, "tween_completed")
		$TextBox.clear_text()
		confirm = choice == "> Yes"
		if not confirm:
			for j in range(len(stat_increases)):
				fighter.set(STATS[j], fighter.get(STATS[j]) - stat_increases[j])
		initialize(fighter)
	if fighter.get_node("UnlearnedSkills").has_learnable_skills(fighter.level):
		var skills = fighter.get_node("UnlearnedSkills").get_learnable_skills(fighter.level)
		for skill in skills:
			fighter.get_node("ActionDecider").add_child(skill.instance())
		initialize(fighter)
		tween.interpolate_property($TextBox, "modulate", Color(1,1,1,0), Color(1,1,1,1), .25)
		tween.start()
		yield(tween, "tween_completed")
		yield($TextBox.display_text("%s learned a new skill!" % (fighter.save_id.capitalize()), 0.02, 0, true), "completed")
		tween.interpolate_property($TextBox, "modulate", Color(1,1,1,1), Color(1,1,1,0), .25)
		tween.start()
		yield(tween, "tween_completed")

func initialize(fighter: Node) -> void:
	name_label.text = fighter.save_id.capitalize()
	exp_label.text = ""
	$PanelContainer/Portrait.texture = portraits[fighter.save_id]
	for i in range(5):
		stat_container.get_child(i).get_child(0).set_stat(STATS[i], fighter.get(STATS[i]))
	skill_container.initialize(fighter)

func enable():
	set_process_input(true)

func disable():
	set_process_input(false)
