extends Sprite

func _ready():
	$AnimationPlayer.current_animation = "floop"
	$AnimationPlayer.seek(randf()*3, true)
	$AnimationPlayer.playback_speed = (randf() - 0.1) * 1.5
