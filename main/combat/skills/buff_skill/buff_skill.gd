extends "res://main/combat/skills/skill.gd"

export(String, "atk", "def", "hit_eva") var buff_type := "atk"
export var stages := 1

func calculation(user: Node, targets: Array) -> Dictionary:
	var missed := false
	var crit := false
	for target in targets:
		target.calculation_cache["contact"] = "none"
		target.set(buff_type, target.get(buff_type)+stages)
		target.set(buff_type, clamp(target.get(buff_type), -2, 2))
	return {"success": 0}
