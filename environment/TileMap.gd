extends TileMap

const NAVMESH_TILE_ID = 0

func _ready():
	var t_left = world_to_map($MapTopLeft.global_position)
	var b_right = world_to_map($MapBotRight.global_position)
	var x_start = round(int(t_left.x))
	var x_end = round(int(b_right.x))
	var y_start = round(int(t_left.y))
	var y_end = round(int(b_right.y))
	for x in range(x_start, x_end):
		for y in range(y_start, y_end):
			if get_cell(x, y) < 0:
				set_cell(x, y, NAVMESH_TILE_ID)
