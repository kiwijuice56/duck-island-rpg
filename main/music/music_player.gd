extends AudioStreamPlayer

const battle = preload("res://main/music/encounter.mp3")
const boss = preload("res://main/music/boss_theme_1.mp3")
const overworld = preload("res://main/music/overworld_demo.mp3")
const water = preload("res://main/music/swimming_ducklings.mp3")
const title = preload("res://main/music/mysterious_duck_island.mp3")
const island = preload("res://main/music/beach_theme_1.mp3")
const cave = preload("res://main/music/cave_theme_1.mp3")
const menu = preload("res://main/music/menu.mp3")
const save_menu = preload("res://main/music/save_menu_theme.mp3")
const victory = preload("res://main/music/victory.mp3")

var stream_volume := -80
var global_volume := -80 setget set_volume
var current_music: Resource
var tween: Tween

const volumes = {
	battle: -12,
	overworld: -10.0,
	boss: -7.0,
	water: -6.5,
	title: -8,
	island: -15,
	cave: 1,
	menu: -11,
	save_menu: -6,
	victory: -10,
}

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)

func set_volume(new_global_volume) -> void:
	global_volume = new_global_volume
	volume_db = stream_volume + global_volume

func play_music(sound, transition_time=0.35) -> void:
	tween.interpolate_property(self, "volume_db", (-80 if not current_music else volumes[current_music])+global_volume, -50, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	stream = sound
	stream_volume = volumes[sound]
	tween.interpolate_property(self, "volume_db", -50, volumes[sound]+global_volume, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	playing = true
	yield(tween, "tween_completed")
	current_music = sound

func stop() -> void:
	tween.stop_all()
	stream = null
	playing = false
