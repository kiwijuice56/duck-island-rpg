extends Node

func _ready():
	MusicPlayer.play_music(MusicPlayer.title)

func load_game(file: Resource) -> void:
	pass
