extends "res://addons/rpg_framework/custom_nodes/fighter_cycle/team_cycle/team_cycle.gd"

onready var combat_ui := get_tree().get_root().get_node("Main/CanvasLayer/Combat")
onready var press_turn_container := combat_ui.get_node("VBoxContainer/Top/PressTurnContainer")

func _ready() -> void:
	battle()

func battle() -> void:
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
