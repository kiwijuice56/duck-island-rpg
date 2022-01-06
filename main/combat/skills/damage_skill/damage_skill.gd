extends "res://main/combat/skills/skill.gd"

export(String, "strength", "magic") var power_stat := "strength"
export var power := 0
export var accuracy := 1.0
export var critical := 0.05

func calculation(user: Node, targets: Array) -> Dictionary:
	var missed := false
	var crit := false
	for target in targets:
		if rand_range(0, 1.0) > accuracy:
			missed = true
			target.calculation_cache["contact"] = "miss"
			target.calculation_cache["damage"] = 0
		else:
			if rand_range(0, 1.0) < critical:
				crit = true
				var damage = ceil ( power + (user.get(power_stat) * 2.333) )
				
				target.calculation_cache["contact"] = "critical"
				target.calculation_cache["damage"] = damage
				target.hp -= damage
			else:
				target.calculation_cache["contact"] = "normal"
				var damage = ceil(  power + (user.get(power_stat) * 1.5) )
				target.calculation_cache["damage"] = damage
				target.hp -= damage
			if target.hp <= 0:
				target.status = "dead"
	if missed:
		return {"success": -1}
	elif crit:
		return {"success": 2}
	else:
		return {"success": 0}
	
