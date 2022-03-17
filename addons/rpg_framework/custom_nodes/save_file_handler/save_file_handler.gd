extends Node
# Manages saving and loading player data using Godot's group system 
# Nodes in each group within save_groups have their save_data functions called to fill the group key of the save file dictionary

export(Array, String) var save_groups: Array

# Developer path can be used to save files within the project root folder to allow for quick editing and testing
# Note that any files saved in res:// are impossible to be read in an exported game, so it is ideal to keep the actual save path within user://
export var save_folder_path: String = "user://"
export var developer_save_folder_path: String = "res://"
export var new_game_developer_path: String = "res://"
export var new_game_path: String = "user://"

signal file_managing_complete

var save_file_template_path: String = "res://main/save_game/save_file_template/save_file_template.gd"

func _ready() -> void:
	pass
#	save_file(0, true)

func get_files(developer_mode: bool) -> Array:
	var dir = Directory.new()
	dir.open(developer_save_folder_path if developer_mode else save_folder_path)
	dir.list_dir_begin()
	var files = []
	for i in range(99):
		if file_exists(i, developer_mode):
			files.append((developer_save_folder_path if developer_mode else save_folder_path) + "%02d.tres" % i)
		else:
			files.append(null)
	dir.list_dir_end()
	return files

func get_file_count(developer_mode: bool) -> int:
	var dir = Directory.new()
	dir.list_dir_begin()
	var count := 0
	while true:
		var file = dir.get_next()
		if file.begins_with("."):
			continue
		if file == "":
			break
		count += 1
	dir.list_dir_end()
	return count

# Developer files are saved as .tres files without encryption
func save_file(id: int, developer_mode: bool) -> void:
	var file = load(save_file_template_path).new()
	for group in save_groups:
		var group_data := {}
		for node in get_tree().get_nodes_in_group(group):
			group_data[node.save_id] = node.save_data()
		file.data[group] = group_data
	var dir = Directory.new()
	if developer_mode:
		dir.remove(developer_save_folder_path + "%02d.tres" % id)
		ResourceSaver.save(developer_save_folder_path + "%02d.tres" % id, file)
	else:
		dir.remove(save_folder_path + "%02d.tres" % id)
		ResourceSaver.save(save_folder_path + "%02d.tres" % id, file)
	emit_signal("file_managing_complete")

func load_file(id: int, developer_mode: bool) -> void:
	var file
	if id == -1:
		if developer_mode:
			file = load(new_game_developer_path)
		else:
			file = load(new_game_path)
	else:
		if developer_mode:
			file = load(developer_save_folder_path + "%02d.tres" % (id)) 
		else:
			file = load(save_folder_path + "%02d.tres" % (id)) 
	for group in save_groups:
		for node in get_tree().get_nodes_in_group(group):
			node.load_data(file.data[group][node.save_id])
	emit_signal("file_managing_complete")

func file_exists(id: int, developer_mode: bool) -> bool:
	var file = File.new()
	if developer_mode:
		return file.file_exists(developer_save_folder_path + "%02d.tres" % (id))
	else:
		return file.file_exists(save_folder_path + "%02d.tres" % (id))
