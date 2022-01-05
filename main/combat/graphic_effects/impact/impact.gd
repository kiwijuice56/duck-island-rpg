extends Sprite

export var anim_name := ""

signal complete

func impact(target: Node) -> void:
	global_position = target.get_node("SelectIcon").global_position 
	$AnimationPlayer.current_animation = anim_name
	yield($AnimationPlayer, "animation_finished")
	emit_signal("complete")
	queue_free()
