extends Node

var accept = preload("res://main/ui/assets/sounds/select.wav")
var cancel = preload("res://main/ui/assets/sounds/deselect.wav")
var switch = preload("res://main/ui/assets/sounds/switch.wav")
var action = preload("res://main/ui/assets/sounds/action.wav")

func play_sound(sound) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = sound
	player.playing = true
	add_child(player)
	yield(player, "finished")
	remove_child(player)
	player.queue_free()
