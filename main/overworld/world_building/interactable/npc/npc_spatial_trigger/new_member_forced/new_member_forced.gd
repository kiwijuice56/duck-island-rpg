extends NpcSpatialTrigger
class_name NpcNewMemberForced

# adds member to party after cutscene
# will need more robust method later on to handle inactive and active party members

export var member: PackedScene

onready var party := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Combat/PressTurnCycle/PlayerParty")

func _ready() -> void:
	var new_member = member.instance()
	if new_member.save_id in overworld.flags and overworld.flags[new_member.save_id]:
		queue_free()
	new_member.queue_free()

func talk(player) -> void:
	disabled = true
	player.disable()
	yield($Cutscene.play([player, self]), "completed")
	var new_member = member.instance()
	party.add_child(new_member)
	overworld.flags[new_member.save_id] = true
	player.enable()
