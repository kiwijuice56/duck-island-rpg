extends Sprite

export var anim_name := ""
var target: Node

signal complete

func on_impact() -> void:
	target.on_impact()
	target.emit_signal("update_points")

func impact(target: Node) -> void:
	self.target = target
	global_position = target.get_node("SelectIcon").global_position 
	
	# silence all impact sounds
	if target.calculation_cache["contact"] in ["absorb", "miss", "null", "repel"]:
		$ImpactSound.volume_db = -100
	
	$AnimationPlayer.current_animation = anim_name
	yield($AnimationPlayer, "animation_finished")
	emit_signal("complete")
	queue_free()
