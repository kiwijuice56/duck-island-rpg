extends AudioStreamPlayer

var battle = preload("res://main/music/encounter.mp3")
var overworld = preload("res://main/music/overworld_demo.mp3")

func play_music(sound) -> void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "volume_db", -10, -50, 0.35,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	stream = sound
	tween.interpolate_property(self, "volume_db", -50, -10, 0.35,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	playing = true
	yield(tween, "tween_completed")
	tween.queue_free()
