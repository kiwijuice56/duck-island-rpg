extends Node2D

export var save_id := "overworld"
export var location_folder = "res://main/overworld/overworld_map/"
var current_location := ""
var save_location := 0

var items := {}

func load_data(data: Dictionary) -> void:
	if current_location:
		get_child(0).queue_free()
	items = data["items"]
	var new_location = load(location_folder + data["location"] + "/" + data["location"] + ".tscn").instance()
	current_location = data["location"]
	add_child(new_location)
	move_child(new_location, 0)
	$Player.global_position = new_location.get_node("SaveLocations").get_child(data["save_location"]).get_node("Spawn").global_position

func enable() -> void:
	MusicPlayer.play_music(MusicPlayer.get(get_child(0).music))
	$Player.enable()
	$Player.room_loaded()

func save_data() -> Dictionary:
	var data := {}
	data["location"] = current_location
	data["items"] = items
	data["save_location"] = save_location
	return data
