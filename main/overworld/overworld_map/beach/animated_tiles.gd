extends TileMap

export var frames: int
export var size: int

var offset := Vector2()

func _ready() -> void:
	$Timer.connect("timeout", self, "next_frame")

func next_frame() -> void:
	offset.x += size/frames
	if offset.x >= size:
		offset.x = 0
	var rect = get_tileset().tile_get_region(0)
	rect.position = offset
	get_tileset().tile_set_region(0, rect)
