extends Control

export var fighter_container = preload("res://main/ui/combat/fighter_container/FighterContainer.tscn")

func set_fighter_containers(fighters: Array) -> Array:
	var container = get_node("VBoxContainer/Fighters")
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	var fighter_containers := []
	for fighter in fighters:
		var new_fighter_container = fighter_container.instance()
		new_fighter_container.initialize(fighter)
		container.add_child(new_fighter_container)
		fighter_containers.append(new_fighter_container)
	return fighter_containers

func set_turn_label(team) -> void:
	$TurnLabel/AnimationPlayer.current_animation = team
	yield($TurnLabel/AnimationPlayer, "animation_finished")
