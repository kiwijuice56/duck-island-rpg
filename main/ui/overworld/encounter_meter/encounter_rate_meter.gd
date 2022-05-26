extends Control

export(Gradient) var color
var color_change := -.15 setget set_color_change
var under = true

func _ready():
	$Tween.connect("tween_completed", self, "reset_tween")
	reset_tween(null, null)

func reset_tween(tween, key) -> void:
	if under:
		$Tween.interpolate_property(self, "color_change", -.15, 0, 1.5)
	else:
		$Tween.interpolate_property(self, "color_change", 0, -.15, 1.5)
	$Tween.start()
	under = not under

func set_encounter_modulate(steps) -> void:
	$Progress.modulate = color.interpolate((255-steps)/255.0) + Color(color_change, color_change, color_change)

func set_color_change(new_change):
	color_change = new_change
