extends "res://main/combat/skills/skill.gd"

export(String, "panic") var status := "panic"

func calculation(user: Node, targets: Array) -> Dictionary:
	var missed := false
	for target in targets:
		if rand_range(0, 1.0) > accuracy:
			missed = true
			target.calculation_cache["contact"] = "miss"
		else:
			target.calculation_cache["contact"] = "normal"
			target.calculation_cache["damage"] = "panic"
			target.status = status
		if target.hp <= 0:
			target.hp = 0
			target.status = "dead"
	return {"success": 0}

