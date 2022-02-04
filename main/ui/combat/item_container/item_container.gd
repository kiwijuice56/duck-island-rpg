extends PanelContainer

export var transition_time := 0.125
export var item_button = preload("res://main/ui/combat/circle_menu/item_button/ItemButton.tscn")
onready var items := get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Items")

signal action_selected(action)

func _input(event):
	if event.is_action_pressed("ui_cancel", false):
		disable()
		emit_signal("action_selected", [null, null])
	if event.is_action_pressed("ui_up", false):
		SoundPlayer.play_sound(SoundPlayer.action)
	if event.is_action_pressed("ui_down", false):
		SoundPlayer.play_sound(SoundPlayer.action)

func enable() -> void:
	get_node("ScrollContainer").get_child(0).get_child(0).grab_focus()
	set_process_input(true)

func disable() -> void:
	if get_focus_owner():
		get_focus_owner().release_focus()
	set_process_input(false)

func initialize() -> void:
	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)
		child.queue_free()
	var last_button = null
	for inventory in [items.combat_items, items.healing_items]:
		if not inventory:
			continue
		for item in inventory:
			var new_button = item_button.instance()
			new_button.connect("button_down", self, "button_down", [new_button])
			$ScrollContainer/VBoxContainer.add_child(new_button)
			new_button.initialize(item, inventory[item])
			last_button = new_button
	last_button.set_focus_neighbour(MARGIN_BOTTOM, last_button.get_path())

func button_down(button: Button) -> void:
	SoundPlayer.play_sound(SoundPlayer.accept)
	emit_signal("action_selected", [items.instance_item(button.action), button.item])

func transition_in() -> void:
	$ScrollContainer.modulate = Color(1,1,1,0)
	$Tween.interpolate_property(self, "rect_scale", Vector2(0,1), Vector2(1,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property($ScrollContainer, "modulate", null, Color(1,1,1,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func transition_out() -> void:
	$Tween.interpolate_property($ScrollContainer, "modulate", Color(1,1,1,1), Color(1,1,1,0), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(self, "rect_scale", Vector2(1,1), Vector2(0,1), transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
