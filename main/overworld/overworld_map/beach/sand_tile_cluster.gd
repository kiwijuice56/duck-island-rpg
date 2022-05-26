tool
extends TileSet

const ID_1 = 0
const ID_2 = 1

var binds = {
	ID_1: [ID_2],
	ID_2: [ID_1]
}

func _is_tile_bound(id, nid):
	print(id)
	return nid in binds[id]
