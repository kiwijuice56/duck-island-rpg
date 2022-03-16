extends Sprite3D

export var life_time := 0.5
export var life_range := .1
export var scale_range := .4

func _ready() -> void:
	frame = randi() % hframes
	var new_scale := 1 + rand_range(-scale_range/2, scale_range/2)
	scale = Vector3(new_scale, new_scale, new_scale)

func start() -> void:
	var life_span := life_time + rand_range(-life_range/2, life_range)
	$Tween.interpolate_property(self, "translation:y", null, translation.y +.2, life_span, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), life_span, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()
