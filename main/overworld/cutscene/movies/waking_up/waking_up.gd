extends "res://main/overworld/cutscene/movies/movie.gd"

onready var transition := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")

func _ready() -> void:
	yield(transition.heavy_transition_out(), "completed")

func finish() -> void:
	yield(transition.heavy_transition_in(), "completed")
	transition.heavy_transition_out()
	emit_signal("finished")
