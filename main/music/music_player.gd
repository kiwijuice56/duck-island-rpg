extends AudioStreamPlayer

var global_volume := 0 setget set_volume

var battle = preload("res://main/music/boss_theme_2.mp3")
var boss = preload("res://main/music/boss_theme_1.mp3")
var overworld = preload("res://main/music/overworld_demo.mp3")
var water = preload("res://main/music/swimming_ducklings.mp3")
var title = preload("res://main/music/title_theme.mp3")
var island = preload("res://main/music/beach_theme_1.mp3")
var menu = preload("res://main/music/menu.mp3")
var victory = preload("res://main/music/victory.mp3")

var stream_volume := 0.0

var volumes = {
	battle: -13,
	overworld: -10.0,
	boss: -7.0,
	water: -6.5,
	title: -8,
	island: -11,
	menu: -11,
	victory: -10,
}

func set_volume(new_global_volume) -> void:
	global_volume = new_global_volume
	volume_db = stream_volume + global_volume

func play_music(sound) -> void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "volume_db", volumes[sound]+global_volume, -50, 0.35,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	stream = sound
	stream_volume = volumes[sound]
	tween.interpolate_property(self, "volume_db", -50, volumes[sound]+global_volume, 0.35,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	playing = true
	yield(tween, "tween_completed")
	tween.queue_free()
