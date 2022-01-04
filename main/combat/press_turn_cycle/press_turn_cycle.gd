extends "res://addons/rpg_framework/custom_nodes/fighter_cycle/team_cycle/team_cycle.gd"

onready var combat_ui := get_tree().get_root().get_node("Main/CombatUI/Combat")
onready var text_box = combat_ui.get_node("VBoxContainer/TextBox")
onready var press_turn_container := combat_ui.get_node("VBoxContainer/Top/PressTurnContainer")
onready var cam := get_tree().get_root().get_node("Main/MainCamera")
onready var transition = get_tree().get_root().get_node("Main/Transition")

func set_enemies(enemies: Array) -> void:
	for child in $EnemyParty.get_children():
		$EnemyParty.remove_child(child)
		child.queue_free()
	for enemy in enemies:
		var new_enemy = enemy.instance()
		$EnemyParty.add_child(new_enemy)

func position_fighters() -> void:
	for i in range($PlayerParty.get_child_count()):
		$PlayerParty.get_child(i).global_position = get_node("../Positions").get_child($PlayerParty.get_child_count()-1).get_child(i).global_position
		$PlayerParty.get_child(i).global_position.x -= 250
	for i in range($EnemyParty.get_child_count()):
		$EnemyParty.get_child(i).global_position = get_node("../Positions").get_child($EnemyParty.get_child_count()-1).get_child(i).global_position
		$EnemyParty.get_child(i).global_position.x += 250

func battle() -> void:
	cam.current = true
	position_fighters()
	for child in get_children():
		for fighter in child.get_children():
			fighter.get_node("Sprite").visible = true
	cam.fit($EnemyParty.get_children(), 0, 0)
	yield(transition.transition_out(), "completed")
	text_box.display_text("Enemies approach!", 0.02, .7)
	yield(cam.fit($EnemyParty.get_children(), 2, -75), "completed")
	while true:
		update_cycle()
		for _i in range(get_child_count()):
			var full_turns := len(sub_cycle)
			var half_turns := 0
			
			yield(press_turn_container.update_turns(full_turns, half_turns), "completed")
			while full_turns + half_turns > 0: 
				var report: Dictionary = yield(start_next_fighter(), "completed")
				match report["success"]:
					0:
						if half_turns > 0:
							half_turns -= 1
						else:
							full_turns -= 1
					1:
						if half_turns > 0:
							half_turns -= 1
						else:
							full_turns -= 1
							half_turns += 1
				yield(press_turn_container.update_turns(full_turns, half_turns), "completed")
			switch_sub_cycle()
