extends Npc

onready var transition = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/Transition")
onready var save_room = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/SaveRoomUI/SaveRoom")

func close_save_room() -> void:
	body.enable()

func talk(player) -> void:
	disabled = true
	overworld_ui.hide_prompt()
	player.disable()
	yield(transition.transition_in(), "completed")
	save_room.visible = true
	save_room.last = self
	save_room.last_func = "close_save_room"
	yield(transition.transition_out(), "completed")
	save_room.enable()
	save_room.choose_button()