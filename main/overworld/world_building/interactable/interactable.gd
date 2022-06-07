extends Area2D
class_name Interactable

var body
var disabled := true
onready var overworld_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/OverworldUI/Overworld")
onready var cam = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")
onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var overworld = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Overworld")

func _ready():
	connect("body_entered", self, "body_entered")
	connect("body_exited", self, "body_exited")
	overworld_ui.connect("menu_opened", self, "body_exited", [null])

func body_entered(body) -> void:
	body.connect("battle_started", self, "battle_started")
	set_process_input(true)
	self.body = body
	disabled = false

func body_exited(_body) -> void:
	if body and body.is_connected("battle_started", self, "battle_started"):
		body.disconnect("battle_started", self, "battle_started")
	self.body = null
	set_process_input(false)
	disabled = true
	overworld_ui.hide_prompt()

# prevent interactions when battles interrupt prompts
func battle_started() -> void:
	body_exited(null)
