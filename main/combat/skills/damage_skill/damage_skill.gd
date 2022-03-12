extends "res://main/combat/skills/skill.gd"

export(String, "strength", "magic") var power_stat := "strength"
export var power := 0
export var critical := 0.05

func calculation(user: Node, targets: Array) -> Dictionary:
	var success := 0
	var crit := false
	
	for target in targets:
		var affinity := "" if not type in target.defense else target.defense[type] 
		target.calculation_cache = {}
		# check for misses
		if rand_range(0, 1.0) > accuracy:
			success = min(success, -1)
			target.calculation_cache["contact"] = "miss"
			target.calculation_cache["damage"] = 0
			continue
			
		var damage := 0
		
		if power < 0:
			damage = ceil((power/1.5) - (user.get(power_stat) * 1.75))
		else:
			damage = ceil(  (1 + (user.atk * .21) - (user.def * .21)) * (power/1.5) + (user.get(power_stat) * 1.75) )
		
		match affinity:
			"":
				target.calculation_cache["contact"] = "normal"
			"weak":
				target.calculation_cache["contact"] = "weak"
				damage *= 1.5
				if success >= 0:
					success = 2
			"resist":
				target.calculation_cache["contact"] = "normal"
				damage *= .7
			"null":
				target.calculation_cache["contact"] = "null"
				damage = 0
				success = min(success, -1)
			"absorb":
				target.calculation_cache["contact"] = "absorb"
				damage *= -1
				success = min(success, -2)
		
		if target.calculation_cache["contact"] in ["normal", "weak"] and rand_range(0, 1.0) < critical:
			crit = true
			damage *= 1.8
			target.calculation_cache["critical"] = true
			if success >= 0:
				success = 2
		
		target.hp -= damage
		target.calculation_cache["damage"] = damage
		if target.hp <= 0:
			target.status = "dead"
		target.hp = min(target.max_hp, max(0, target.hp))
		
		# switch contact to heal to prevent attacking animations with healing skills, then abs the damage for labels
		if damage < 0 and not target.calculation_cache["contact"] == "absorb":
			target.calculation_cache["contact"] = "heal"
		if damage < 0:
			target.calculation_cache["damage"] = abs(damage)
	return {"success": success}
