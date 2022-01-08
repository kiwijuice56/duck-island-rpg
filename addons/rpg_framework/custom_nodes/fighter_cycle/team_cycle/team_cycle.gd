extends "res://addons/rpg_framework/custom_nodes/fighter_cycle/fighter_cycle.gd"

var sub_cycle : Array

func update_cycle() -> Array:
	var fighter_script : Script = load("res://addons/rpg_framework/custom_nodes/fighter/fighter.gd")
	var party_script : Script = load("res://addons/rpg_framework/custom_nodes/party/party.gd")
	for party in get_children():
		if not party is party_script:
			continue
		var party_cycle: Array = []
		for fighter in party.get_children():
			if not fighter is fighter_script:
				continue
			if not fighter.is_connected("tree_exited", self, "remove_fighter_from_cycle"):
				fighter.connect("tree_exited", self, "remove_fighter_from_cycle", [fighter])
			party_cycle.append(fighter)
			party_cycle.sort_custom(self, "compare_fighters")
		cycle.append(party_cycle)
	return cycle

func switch_sub_cycle() -> void:
	if len(cycle) > 0:
		var temp = cycle[0]
		cycle.remove(0)
		cycle.append(temp)
		sub_cycle = cycle[0]

func start_next_fighter() -> Dictionary:
	if len(sub_cycle) == 0:
		return {}
	emit_signal("act_started")
	sub_cycle[0].call_deferred("act", {"fighters": cycle})
	var report : Dictionary = yield(sub_cycle[0], "act_completed")
	emit_signal("act_ended")
	var temp = sub_cycle[0]
	sub_cycle.remove(0)
	sub_cycle.append(temp)
	return report
