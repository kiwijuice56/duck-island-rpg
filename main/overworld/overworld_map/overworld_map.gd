extends Node2D

export var save_id:= ""
export var music := ""

export var encounter_steps := [0,3,6,13,24,48]
export(Array, Resource) var encounters := []

func _ready() -> void:
	if save_id in get_parent().items:
		for item in $Items.get_children():
			if get_parent().items[save_id][item.name]:
				item.queue_free()
	else:
		var items = {}
		for item in $Items.get_children():
			items[item.name] = false
		get_parent().items[save_id] = items
	
	for item in $Items.get_children():
		item.connect("collected", self, "collected", [item.name])

func collected(item_name: String) -> void:
	get_parent().items[save_id][item_name] = true

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
