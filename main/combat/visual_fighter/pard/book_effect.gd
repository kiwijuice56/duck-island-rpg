extends Sprite

export var letter: PackedScene

func burst() -> void:
	for _i in range(10):
		$Timer.start()
		yield($Timer, "timeout")
		var new_letter = letter.instance()
		new_letter.position = Vector2(randi() % 32 - 16, randi() % 32 - 16)
		add_child(new_letter)
