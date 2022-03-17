extends CanvasLayer

signal finished

func finish() -> void:
	emit_signal("finished")
