extends Node

func _ready():
	randomize()
	MusicPlayer.play_music(MusicPlayer.title)

func load_game(file: Resource) -> void:
	pass
