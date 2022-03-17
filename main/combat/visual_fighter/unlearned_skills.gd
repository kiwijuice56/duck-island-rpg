extends Node

export var action_scene_path := ""
export(Array, int) var skill_levels: Array
export(Array, PackedScene) var skills: Array

func get_data() -> Array:
	var skill_ids := []
	for scene in get_skill_scenes():
		skill_ids.append(scene.save_id)
		scene.queue_free()
	return [skill_ids, skill_levels]

func load_data(data: Array) -> void:
	skills = []
	for save_id in data[0]:
		var f = File.new()
		var skill_folder = ""
		for folder in ["buff_skill", "damage_skill", "status_skill"]:
			if f.file_exists(action_scene_path + folder +"/%s/%s" % [save_id, save_id] + ".tscn"):
				skill_folder = folder
		skills.append(load(action_scene_path + skill_folder + "/%s/%s" % [save_id, save_id] + ".tscn"))
		skill_levels = data[1]

func get_skill_scenes() -> Array:
	var scenes := []
	for skill in skills:
		var skill_instance = skill.instance()
		scenes.append(skill_instance)
	return scenes

func get_learnable_skills(level: int) -> Array:
	var learnable_skills := []
	while len(skill_levels) and level >= skill_levels[0]:
		learnable_skills.append(skills.pop_front())
		skill_levels.pop_front()
	return learnable_skills

func has_learnable_skills(level: int) -> bool:
	for skill_level in skill_levels:
		print(skill_level)
		if level >= skill_level:
			return true
	return false

