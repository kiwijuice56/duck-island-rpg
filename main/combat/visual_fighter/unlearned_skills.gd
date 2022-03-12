extends Node

export(Array, int) var skill_levels: Array
export(Array, PackedScene) var skills: Array

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
	
