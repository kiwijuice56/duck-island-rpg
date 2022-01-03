extends HBoxContainer

onready var anim := get_node("../AnimationPlayer")
var full_texture := preload("res://main/ui/combat/press_turn_container/press_turn1.png")
var half_texture := preload("res://main/ui/combat/press_turn_container/half_turn.tres")

func update_turns(full: int, half: int) -> void:
	anim.current_animation = "fade_in"
	yield(anim, "animation_finished")
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for _i in range(full):
		var full_turn = TextureRect.new()
		full_turn.texture = full_texture
		add_child(full_turn)
	for _i in range(half):
		var half_turn = TextureRect.new()
		half_turn.texture = half_texture
		add_child(half_turn)
	anim.current_animation = "fade_out"
