extends "res://main/combat/skills/skill.gd"

export(String, "panic") var status := "panic"

func calculation(user: Node, targets: Array) -> Dictionary:
	var missed := false
	var success := 0
	for target in targets:
		var affinity := "" if not type in target.defense else target.defense[type] 
		
		if rand_range(0, 1.0) > accuracy:
			missed = true
			target.calculation_cache["contact"] = "miss"
			continue
		
		match affinity:
			"":
				target.calculation_cache["contact"] = "normal"
				target.calculation_cache["damage"] = status
				target.status = status
			"weak":
				target.calculation_cache["contact"] = "weak"
				target.calculation_cache["damage"] = status
				target.status = status
				if success >= 0:
					success = 2
			"resist":
				target.calculation_cache["contact"] = "normal"
				target.calculation_cache["damage"] = status
				target.status = status
			"null":
				target.calculation_cache["contact"] = "null"
				success = min(success, -1)
			"absorb":
				target.calculation_cache["contact"] = "absorb"
				target.calculation_cache["damage"] = status
				success = min(success, -2)
	return {"success": success}

