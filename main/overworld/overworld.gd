extends Node2D

export var save_id := "overworld"
export var location_folder = "res://main/overworld/overworld_map/"
var current_location := ""
var save_location := 0

var items := {}

func load_data(data: Dictionary) -> void:
	var room := load_room(data["location"])
	$Player.global_position = room.get_node("SaveLocations").get_child(data["save_location"]).get_node("Spawn").global_position
	items = data["items"]

func load_room(location: String) -> Node:
	if current_location:
		get_child(0).queue_free()
	current_location = location
	var new_location = load(location_folder + location + "/" + location + ".tscn").instance()
	add_child(new_location)
	move_child(new_location, 0)
	play_room_music()
	$Player.room_loaded()
	return new_location

func enable() -> void:
	play_room_music()
	$Player.enable()
	$Player.room_loaded()

func play_room_music() -> void:
	MusicPlayer.play_music(MusicPlayer.get(get_child(0).music))

func save_data() -> Dictionary:
	var data := {}
	data["location"] = current_location
	data["items"] = items
	data["save_location"] = save_location
	return data
