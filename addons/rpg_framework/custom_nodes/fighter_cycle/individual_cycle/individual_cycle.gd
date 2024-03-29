extends "res://addons/rpg_framework/custom_nodes/fighter_cycle/fighter_cycle.gd"

func update_cycle() -> Array:
	var fighter_script : Script = load(RpgFramework.addon_path + "fighter/fighter.gd")
	var party_script : Script = load(RpgFramework.addon_path + "party/party.gd")
	for party in get_children():
		if not party is party_script:
			continue
		for fighter in party.get_children():
			if not fighter is fighter_script:
				continue
			fighter.connect("tree_exited", self, "remove_fighter_from_cycle", [fighter])
			cycle.append(fighter)
	cycle.sort_custom(self, "compare_fighters")
	return cycle

func start_next_fighter() -> Dictionary:
	if len(cycle) == 0:
		return {}
	emit_signal("act_started")
	cycle[0].call_deferred("act", {"fighters": cycle})
	var report : Dictionary = yield(cycle[0], "act_completed")
	
	var temp = cycle[0]
	cycle.remove(0)
	cycle.append(temp)
	emit_signal("act_ended")
	return report
