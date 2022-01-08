tool
extends Sprite

func _ready() -> void:
	connect("item_rect_changed", self, "calculate_aspect_ratio")

func calculate_aspect_ratio():
	material.set_shader_param("aspect_ratio", scale.y / scale.x)
	material.set_shader_param("tile_factor", scale.x/2)
