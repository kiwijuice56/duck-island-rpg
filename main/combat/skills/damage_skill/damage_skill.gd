extends "res://main/combat/skills/skill.gd"

export var power := 0
export var accuracy := 100

func calculation(user: Node, targets: Array) -> Dictionary:
	var missed := false
	for target in targets:
		if rand_range(0, 1.0) > 0.5:
			missed = true
			target.calculation_cache["contact"] = "miss"
			target.calculation_cache["damage"] = 0
		else:
			target.calculation_cache["contact"] = "normal"
			target.calculation_cache["damage"] = 35
	return {"success": 0}
