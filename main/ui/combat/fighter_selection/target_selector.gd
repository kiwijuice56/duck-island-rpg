extends Control

signal targets_selected(targets)

var party := []
var targets := []
var index := 0 setget set_index
var allow_movement := false

func _ready() -> void:
	set_process_input(false)

func set_index(new_index: int) -> void:
	index = new_index
	if index < 0:
		index = len(party) + index
	index %= len(party)

func _input(event):
	if event.is_action_pressed("ui_accept", false):
		SoundPlayer.play_sound(SoundPlayer.accept)
		for fighter in party:
			fighter.set_select_animation(false)
			fighter.set_select_eligible(false)
		emit_signal("targets_selected", targets)
		set_process_input(false)
	if event.is_action_pressed("ui_cancel", false):
		SoundPlayer.play_sound(SoundPlayer.cancel)
		for fighter in party:
			fighter.set_select_animation(false)
			fighter.set_select_eligible(false)
		emit_signal("targets_selected", [])
		set_process_input(false)
	if allow_movement and event.is_action_pressed("ui_left", false):
		SoundPlayer.play_sound(SoundPlayer.action)
		self.index -= 1
		targets[0].set_select_animation(false)
		targets.clear()
		party[index].set_select_animation(true)
		targets.append(party[index])
	if allow_movement and event.is_action_pressed("ui_right", false):
		SoundPlayer.play_sound(SoundPlayer.action)
		self.index += 1
		targets[0].set_select_animation(false)
		targets.clear()
		party[index].set_select_animation(true)
		targets.append(party[index])

func select_targets(party_node: Node, count: String) -> void:
	party = []
	for node in party_node.get_children():
		if node.status != "dead":
			party.append(node)
	self.targets = []
	self.index = 0
	for fighter in party:
		fighter.set_select_eligible(true)
	if count == "one":
		party[0].set_select_animation(true)
		targets.append(party[0])
		allow_movement = true
	if count == "all":
		allow_movement = false
		for child in party:
			child.set_select_animation(true)
			targets.append(child)
	set_process_input(true)
