extends Control

var open := false

onready var skill_container := get_node("SkillControl/Skills")
onready var item_container := get_node("ItemControl/Items")
onready var buttons := get_node("PopupMenu/HBoxContainer/PanelContainer/VBoxContainer")
onready var party = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Combat/PressTurnCycle/PlayerParty")
onready var system_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SystemUI/System")
onready var status_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/StatusUI/Status")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")

signal menu_opened

func _input(event):
	if event.is_action_pressed("menu", false):
		hide_prompt()
		if open:
			close()
		else: 
			open()
	if open and (event.is_action_pressed("ui_up", false) or event.is_action_pressed("ui_down", false)) :
		SoundPlayer.play_sound(SoundPlayer.action)
	if open and event.is_action_pressed("ui_accept", false):
		SoundPlayer.play_sound(SoundPlayer.accept)

func _ready():
	$PopupMenu.modulate = Color(1,1,1,0)
	for button in buttons.get_children():
		button.connect("pressed", self, "button_pressed", [button.text])
	disable()

func button_pressed(button_name: String) -> void:
	if not open:
		return
	match button_name:
		"Items":
			disable()
			if get_focus_owner():
				get_focus_owner().release_focus()
			item_container.initialize()
			yield(item_container.transition_in(), "completed")
			item_container.enable()
			var action_data: Array = yield(item_container, "action_selected")
			var action = action_data[0]
			
			if not action:
				item_container.disable()
				SoundPlayer.play_sound(SoundPlayer.cancel)
				yield(item_container.transition_out(), "completed")
				enable()
				return
			
			item_container.disable()
			item_container.transition_out()
			$TargetSelector.call_deferred("select_targets", party, action.target_count)
			var targets = yield($TargetSelector, "targets_selected")
			
			if len(targets) == 0:
				button_pressed("Items")
			else:
				# may change later, but user should not matter for items outside of battle
				action.action(party.get_child(0), targets, action_data[1], false)
		"System":
			disable()
			yield(transition.transition_in(), "completed")
			visible = false
			system_ui.visible = true
			system_ui.last = self
			system_ui.last_func = "choose_button"
			yield(transition.transition_out(), "completed")
			system_ui.enable()
			system_ui.edit_options()
		"Check":
			disable()
			yield(transition.transition_in(), "completed")
			visible = false
			status_ui.visible = true
			status_ui.last = self
			status_ui.last_func = "choose_button"
			status_ui.show_status()
			yield(transition.transition_out(), "completed")
			status_ui.enable()

func enable() -> void:
	set_process_input(true)
	buttons.get_child(0).grab_focus()
	for button in buttons.get_children():
		button.disabled = false

func disable() -> void:
	set_process_input(false)
	for button in buttons.get_children():
		button.disabled = true

func choose_button() -> void:
	buttons.get_child(0).grab_focus()

func open() -> void:
	SoundPlayer.play_sound(SoundPlayer.accept)
	MusicPlayer.play_music(MusicPlayer.menu)
	emit_signal("menu_opened")
	# calling disable also disables this node due to needing to stop menu opening in other menus
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld/Player").disable()
	yield($MiniTransition.transition_in(), "completed")
	enable()
	open = true
	$Tween.interpolate_property($PopupMenu, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	choose_button()

func close() -> void:
	disable()
	SoundPlayer.play_sound(SoundPlayer.cancel)
	MusicPlayer.play_music(MusicPlayer.island)
	open = false
	get_focus_owner().release_focus()
	$Tween.interpolate_property($PopupMenu, "modulate", null, Color(1,1,1,0), 0.1)
	$Tween.start()
	yield($MiniTransition.transition_out(), "completed")
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld/Player").enable()

func display_prompt(text: String) -> void:
	if open:
		return
	$Prompt/Label.text = text
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,1), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")

func hide_prompt() -> void:
	$Tween.stop($Prompt, "modulate")
	$Tween.interpolate_property($Prompt, "modulate", null, Color(1,1,1,0), 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")
