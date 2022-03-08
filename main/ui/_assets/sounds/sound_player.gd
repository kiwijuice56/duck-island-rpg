extends Node

var accept = preload("res://main/ui/_assets/sounds/select.wav")
var cancel = preload("res://main/ui/_assets/sounds/deselect.wav")
var switch = preload("res://main/ui/_assets/sounds/switch.wav")
var action = preload("res://main/ui/_assets/sounds/action.wav")
var glass_break = preload("res://main/ui/_assets/sounds/glass_break.wav")
var woosh = preload("res://main/ui/_assets/sounds/woosh.wav")
var crit = preload("res://main/ui/_assets/sounds/P4 Critical Cut-In.wav")
var null_sound = preload("res://main/ui/_assets/sounds/null.wav")
var absorb = preload("res://main/ui/_assets/sounds/absorb.wav")

var global_volume = 0

func play_sound(sound) -> void:
	var player = AudioStreamPlayer.new()
	player.volume_db = global_volume
	player.stream = sound
	player.playing = true
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport").add_child(player)
	yield(player, "finished")
	get_tree().get_root().get_node("Main/ViewportContainer/Viewport").remove_child(player)
	player.queue_free()
