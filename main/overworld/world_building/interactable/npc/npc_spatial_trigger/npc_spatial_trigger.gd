extends Npc
class_name NpcSpatialTrigger

export var one_shot := true
var triggered := false

func body_entered(body) -> void:
	if triggered and one_shot:
		return
	triggered = true
	call_deferred("talk", body)
