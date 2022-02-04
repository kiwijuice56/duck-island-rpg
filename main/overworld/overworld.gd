extends Node2D

export var save_id := "overworld"
export var location_folder = "res://main/overworld/overworld_map/"
var current_location := ""

func load_data(data: Dictionary) -> void:
	var new_location = load(location_folder + data["location"] + "/" + data["location"] + ".tscn").instance()
	current_location = data["location"]
	add_child(new_location)
	move_child(new_location, 0)
	MusicPlayer.play_music(MusicPlayer.get(new_location.music))
	$Player.enable()
	$Player.room_loaded()

func save_data() -> Dictionary:
	var data := {}
	data["location"] = current_location
	return data
