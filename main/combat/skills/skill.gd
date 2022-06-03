extends "res://addons/rpg_framework/custom_nodes/action/action.gd"

export(String, "hp", "mp", "") var cost_type := "hp"
export(String, "phys","fire", "water", "elec", "wind", "nuclear", "ghost", "buff", "heal") var type := "phys"
export var cost: int
export var accuracy := 1.0
export(String, "all", "one", "random") var target_count = "one"
export(String, "team", "enemy") var party_target = "enemy"
onready var text_box = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/UI/CombatUI/Combat/VBoxContainer/TextBox")
onready var item_node = get_tree().get_root().get_node("Main/ViewportContainer/Viewport/Items")

export var graphic_effect: PackedScene

func action(user: Node, targets: Array, item: ItemData = null, anim: bool = true) -> void:
	if cost_type != "" and not item:
		user.set(cost_type, user.get(cost_type) - cost)
		user.emit_signal("update_points")
	# item pop up if item data is provided
	var tween = Tween.new()
	add_child(tween)
	var item_sprite = Sprite.new()
	if item:
		# gets inventory specific to this category of nodes and removes one of this item
		var inventory = item_node.get(item.category + "_items")
		inventory[item] -= 1
		if inventory[item] == 0:
			inventory.erase(item)
		if anim:
			yield(item_anim_in(item, item_sprite, tween, user.get_node("SelectIcon").global_position), "completed")
	
	var result: Dictionary = calculation(user, targets)
	if anim:
		var init_pos: Vector2 = user.position
		var new_effect = graphic_effect.instance()
		add_child(new_effect)
		yield(text_box.display_text(user.save_id + " used " + save_id.capitalize() + "!", 0.02, 0.35), "completed")
		if party_target == "enemy":
			# assuming that user is a node2d (which it should for this game)
			# sloppy but uses parenting to flip position moved
			tween.interpolate_property(user, "global_position:x", null, 256, 0.25, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.interpolate_property(user, "position:y", init_pos.y, 0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.start()
			yield(tween, "tween_completed")
		new_effect.animate(user, targets)
		yield(new_effect, "effect_complete")
		if party_target == "enemy":
			# assuming that user is a node2d (which it should for this game)
			tween.interpolate_property(user, "position:x", null, init_pos.x, 0.35, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.interpolate_property(user, "position:y", null, init_pos.y, 0.35, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.start()
			yield(tween, "tween_completed")
		new_effect.queue_free()
	else:
		for target in targets:
			target.on_impact()
	# Item fade out
	if item and anim:
		yield(item_anim_out(item, item_sprite, tween), "completed")
	tween.queue_free()
	item_sprite.queue_free()
	emit_signal("action_completed", result)

func item_anim_in(item: ItemData, item_sprite: Sprite, tween: Tween, target: Vector2) -> void:
	item_sprite.scale = Vector2(2,2)
	item_sprite.texture = item.texture
	add_child(item_sprite)
	item_sprite.global_position = target
	tween.interpolate_property(item_sprite, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.6)
	tween.interpolate_property(item_sprite, "position", null, item_sprite.position + Vector2(0,-128), 0.8)
	tween.start()
	yield(tween, "tween_completed")

func item_anim_out(item: ItemData, item_sprite: Sprite, tween: Tween) -> void:
	tween.interpolate_property(item_sprite, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2)
	tween.interpolate_property(item_sprite, "position", null, item_sprite.position - Vector2(0,-128), 0.4)
	tween.start()
	yield(tween, "tween_completed")

func calculation(user: Node, targets: Array) -> Dictionary:
	return {"success": 0}
