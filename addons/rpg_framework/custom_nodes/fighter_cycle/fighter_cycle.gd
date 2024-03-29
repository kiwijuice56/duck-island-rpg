extends Node
# Collection of all Fighters and Parties in a battle and functions as the root of a combat tree

signal act_started
signal act_ended

var cycle := []

# Updates the cycle by adding all grandchildren Fighters from Party children
# In your extension, override this method and implement your own sorting logic
func update_cycle() -> Array:
	return cycle

# Compares Fighters for sorting
# In your extension, override this and implement your own comparison
func compare_fighters(a: Node, b: Node) -> bool:
	return false

func remove_fighter_from_cycle(fighter: Node) -> bool:
	var idx := cycle.find(fighter)
	if not idx == -1:
		if fighter.is_inside_tree():
			push_warning("Removing a fighter from the PartyCycle while still in tree")
		cycle.remove(idx)
		return true
	return false

func start_next_fighter() -> Dictionary:
	emit_signal("act_started")
	
	# ...
	
	emit_signal("act_ended")
	return {}
