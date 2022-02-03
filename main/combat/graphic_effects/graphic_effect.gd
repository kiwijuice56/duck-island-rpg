extends Node2D

export (String, "phys", "magic") var anim_class := "phys"
export var anim_name: String = ""

signal effect_complete
onready var cam := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/MainCamera")

func animate(user: Node, targets: Array) -> void:
	$Timer.start(1)
	yield($Timer, "timeout")
	emit_signal("effect_complete")
