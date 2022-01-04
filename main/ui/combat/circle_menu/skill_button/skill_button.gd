extends Button

export var hp_color := Color("#fde1c1")
export var mp_color := Color("#d4bbfb")

func initialize(skill: Node) -> void:
	$RichTextLabel.clear()
	var color_label = ""
	if skill.cost_type == "hp":
		color_label = "[color=#" + hp_color.to_html() + "]"
	else:
		color_label = "[color=#" + mp_color.to_html() + "]"
	$RichTextLabel.bbcode_text = "[right]" + skill.save_id.capitalize() + " " + color_label + str(skill.cost) + skill.cost_type + "[/color][/right]"
