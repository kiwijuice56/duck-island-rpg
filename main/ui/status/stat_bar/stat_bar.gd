extends HBoxContainer

func set_stat(stat: String, value: int) -> void:
	$Label.text = stat.substr(0, 3).to_upper()
	$Num.text = str(value)
	$TextureProgress.value = value
