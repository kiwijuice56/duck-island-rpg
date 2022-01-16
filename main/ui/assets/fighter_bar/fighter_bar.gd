extends Container

export var fighter_container = preload("res://main/ui/assets/fighter_bar/fighter_container/FighterContainer.tscn")

func set_fighter_containers(fighters: Array) -> Array:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var fighter_containers := []
	for fighter in fighters:
		var new_fighter_container = fighter_container.instance()
		new_fighter_container.initialize(fighter)
		add_child(new_fighter_container)
		fighter_containers.append(new_fighter_container)
	return fighter_containers
