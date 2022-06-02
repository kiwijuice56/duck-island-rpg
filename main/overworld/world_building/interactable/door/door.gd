extends Interactable
class_name Door

export var room_to_save_id := ""
export var door_to_id := ""
export var id := ""

func _input(event):
	if (not disabled and not overworld_ui.open) and Input.is_action_just_pressed("ui_accept"):
		call_deferred("enter", body)

func enter(player) -> void:
	disabled = true
	overworld_ui.hide_prompt()
	yield(transition.transition_in(), "completed")
	get_parent().remove_child(self)
	var overworld: Node = player.get_parent()
	var room: Node = overworld.load_room(room_to_save_id)
	var spawn_door: Node
	for door in room.get_node("Doors").get_children():
		if door.id == door_to_id:
			spawn_door = door
			break
	# will error if there is no door
	player.global_position = spawn_door.get_node("Spawn").global_position
	yield(transition.transition_out(), "completed")

func body_entered(body) -> void:
	self.body = body
	disabled = false
	overworld_ui.display_prompt("Enter: Z")

func body_exited(body) -> void:
	body = null
	disabled = true
	overworld_ui.hide_prompt()
