extends "res://addons/rpg_framework/custom_nodes/action/action.gd"

export(String, "hp", "mp", "") var cost_type := "hp"
export(String, "phys","fire", "water", "elec", "wind", "nuclear", "ghost", "buff", "heal") var type := "phys"
export var cost: int
export var accuracy := 1.0
export(String, "all", "one", "random") var target_count = "one"
export(String, "team", "enemy") var party_target = "enemy"
onready var text_box = get_tree().get_root().get_node("Main/CombatUI/Combat/VBoxContainer/TextBox")

export var graphic_effect: PackedScene

func action(user: Node, targets: Array, item_icon=null) -> void:
	if cost_type != "":
		user.set(cost_type, user.get(cost_type) - cost)
		user.emit_signal("update_points")
	
	var tween 
	var item_sprite
	if item_icon:
		tween = Tween.new()
		add_child(tween)
		item_sprite = Sprite.new()
		item_sprite.scale = Vector2(2,2)
		item_sprite.texture = item_icon
		add_child(item_sprite)
		item_sprite.global_position = user.get_node("SelectIcon").global_position
		tween.interpolate_property(item_sprite, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.6)
		tween.interpolate_property(item_sprite, "position", null, item_sprite.position + Vector2(0,-128), 0.8)
		tween.start()
		yield(tween, "tween_completed")
	
	var result = calculation(user, targets)
	var new_effect = graphic_effect.instance()
	add_child(new_effect)
	yield(text_box.display_text(user.save_id + " used " + save_id.capitalize() + "!", 0.02, 0.5), "completed")
	new_effect.animate(user, targets)
	yield(new_effect, "effect_complete")
	new_effect.queue_free()
	if item_icon:
		tween.interpolate_property(item_sprite, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2)
		tween.interpolate_property(item_sprite, "position", null, item_sprite.position - Vector2(0,-128), 0.4)
		tween.start()
		yield(tween, "tween_completed")
		tween.queue_free()
		item_sprite.queue_free()
	emit_signal("action_completed", result)


func calculation(user: Node, targets: Array) -> Dictionary:
	return {"success": 0}
