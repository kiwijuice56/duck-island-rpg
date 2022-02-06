extends Node2D

export var save_id:= ""
export var music := ""

export var encounter_steps := [0,4,8,16,32,64]
export(Array, Resource) var encounters := []

func get_enemies(encounter: Resource) -> Array:
	var enemies = []
	for i in range(0, int(rand_range(encounter.enemy_count_min, encounter.enemy_count_max))):
		var rand = rand_range(0,1)
		var j = 0
		while j != len(encounter.enemies)-1:
			rand -= encounter.spawn_chances[j]
			if rand > 0:
				j += 1
			else:
				break
		enemies.append(encounter.enemies[j])
	return enemies
