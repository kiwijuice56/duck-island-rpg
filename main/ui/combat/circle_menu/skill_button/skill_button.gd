extends Button

export var disabled_color := Color("#fde1c1")
export var hp_color := Color("#fde1c1")
export var mp_color := Color("#d4bbfb")
var action: Node

func initialize(skill: Node) -> void:
	action = skill
	$HBoxContainer/RichTextLabel.clear()
	var color_label = ""
	if skill.cost_type == "hp":
		color_label = "[color=#" + hp_color.to_html() + "]"
	elif skill.cost_type == "mp":
		color_label = "[color=#" + mp_color.to_html() + "]"
	else:
		$HBoxContainer/RichTextLabel.bbcode_text = "[right]" + skill.save_id.capitalize() + "[/right]"
		return
	if disabled:
		$HBoxContainer/RichTextLabel.bbcode_text = "[right]" + "[color=#" + disabled_color.to_html() + "]" + skill.save_id.capitalize() + "[/color] " + color_label + str(skill.cost) + skill.cost_type + "[/color][/right]"
	else:
		$HBoxContainer/RichTextLabel.bbcode_text = "[right]" + skill.save_id.capitalize() + " " + color_label + str(skill.cost) + skill.cost_type + "[/color][/right]"

