extends Area2D

var body

func _ready():
	connect("body_entered", self, "body_entered")
	connect("body_exited", self, "body_exited")

func body_entered(body) -> void:
	pass

func body_exited(body) -> void:
	pass
