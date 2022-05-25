extends Sprite

export var walk_time := 2
export var time_min := 7
export var time_max := 15

func _ready() -> void:
	$Timer.connect("timeout", self, "migrate")
	$Timer.start(rand_range(time_min, time_max))

func migrate() -> void:
	$AnimationPlayer.current_animation = "leave_sand"
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.current_animation = "walk"
	$Tween.interpolate_property(self, "position", null, position + $B.position, walk_time)
	$Tween.start()
	yield($Tween, "tween_completed")
	$AnimationPlayer.current_animation = "enter_sand"
	yield($AnimationPlayer, "animation_finished")
	position -= $B.position
