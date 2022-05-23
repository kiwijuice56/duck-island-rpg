extends TileMap

export var frames: int
export var size: int

var offset := Vector2()
var returning = false

func _ready() -> void:
	$Timer.connect("timeout", self, "next_frame")

func next_frame() -> void:
	if not returning:
		offset.x += size/frames
	else:
		offset.x -= size/frames
	if offset.x < 0:
		returning = false
		offset.x += 2*size/frames
	if offset.x >= size:
		returning = true
		offset.x -= 2*size/frames
	var rect = get_tileset().tile_get_region(0)
	rect.position = offset
	get_tileset().tile_set_region(0, rect)
	
