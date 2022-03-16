extends Sprite3D

export var smoke: PackedScene

func _ready() -> void:
	$Timer.connect("timeout", self, "spawn")

func spawn() -> void:
	var new_smoke = smoke.instance()
	add_child(new_smoke)
	new_smoke.translation.y = .35;
	new_smoke.translation.x = rand_range(-.2,.2)
	new_smoke.start()
