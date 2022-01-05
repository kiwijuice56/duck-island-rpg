extends Node2D

signal effect_complete
onready var cam := get_tree().get_root().get_node("Main/MainCamera")

func animate(user: Node, targets: Array) -> void:
	$Timer.start(1)
	yield($Timer, "timeout")
	emit_signal("effect_complete")
