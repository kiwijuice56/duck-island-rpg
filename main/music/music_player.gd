extends AudioStreamPlayer

const battle = null
const boss = null
const overworld = null
const water = null
const title = null
const island = null
const cave = null
const menu = null
const save_menu = null
const victory = null

var stream_volume := -80
var global_volume := 0 setget set_volume
var current_music: Resource
var tween: Tween

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)

func set_volume(new_global_volume) -> void:
	global_volume = new_global_volume
	volume_db = stream_volume + global_volume

func play_music(sound, transition_time=0.35) -> void:
	return
#	tween.interpolate_property(self, "volume_db", (-80 if not current_music else volumes[current_music])+global_volume, -50, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
#	yield(tween, "tween_completed")
#	stream = sound
#	stream_volume = volumes[sound]
#	tween.interpolate_property(self, "volume_db", -50, volumes[sound]+global_volume, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
#	playing = true
#	yield(tween, "tween_completed")
#	current_music = sound

func stop() -> void:
	tween.stop_all()
	stream = null
	playing = false
