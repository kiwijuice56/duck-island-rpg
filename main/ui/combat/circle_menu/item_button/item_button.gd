extends Button

export var disabled_color := Color("#fde1c1")

var icon_path = "res://main/ui/_assets/affinity_icons/"
var action: Node

func initialize(item: ItemData, count: int) -> void:
	action = item.attached_skill
	$HBoxContainer/TextureRect.texture = load(icon_path + item.type + ".png")
	$HBoxContainer/RichTextLabel.clear()
	if disabled:
		$HBoxContainer/RichTextLabel.bbcode_text = "[right]" + "[color=#" + disabled_color.to_html() + "]" + item.save_id.capitalize() + " x" + str(count) + "[/color][/right]"
	else:
		$HBoxContainer/RichTextLabel.bbcode_text = "[right]" + "[color=#ffffff]" + item.save_id.capitalize() + " x" + str(count) + "[/color][/right]"

