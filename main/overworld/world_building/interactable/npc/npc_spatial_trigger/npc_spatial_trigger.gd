extends Npc
class_name NpcSpatialTrigger

export var one_shot := true
var triggered := false

func body_entered(body) -> void:
	if triggered and one_shot:
		return
	if overworld_ui.open:
		yield(overworld_ui, "menu_closed")
	triggered = true
	talk(body)
