extends Area2D
class_name Interactable

var body
var disabled := true
onready var overworld_ui = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/OverworldUI/Overworld")
onready var cam = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")

func _ready():
	connect("body_entered", self, "body_entered")
	connect("body_exited", self, "body_exited")
	overworld_ui.connect("menu_opened", self, "body_exited", [null])

func body_entered(body) -> void:
	body.connect("disabled", self, "body_exited", body)

func body_exited(body) -> void:
	self.body = null
	disabled = true
	overworld_ui.hide_prompt()
