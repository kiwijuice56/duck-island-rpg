tool
extends Sprite

export var enable_resize := true

func _ready() -> void:
	connect("item_rect_changed", self, "calculate_aspect_ratio")
	calculate_aspect_ratio()

func calculate_aspect_ratio():
	if enable_resize:
		material.set_shader_param("aspect_ratio", scale.y / scale.x)
		material.set_shader_param("tile_factor", scale.x/2)
