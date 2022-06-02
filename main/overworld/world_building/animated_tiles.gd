extends TileMap

export var frames: int
export var size: int
export var ping_pong := false

var returning := false
var offset := Vector2()

func _ready() -> void:
	$Timer.connect("timeout", self, "next_frame")

func next_frame() -> void:
	if not ping_pong:
		offset.x += size/frames
		if offset.x >= size:
			offset.x = 0
		var rect = get_tileset().tile_get_region(0)
		rect.position = offset
		get_tileset().tile_set_region(0, rect)
	else:
		offset.x += size/frames * (-1 if returning else 1)
		if offset.x == size - size/frames:
			returning = true
		if offset.x == 0:
			returning = false
		var rect = get_tileset().tile_get_region(0)
		rect.position = offset
		get_tileset().tile_set_region(0, rect)
