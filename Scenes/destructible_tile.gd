extends TileMapLayer

func _ready():
	TileManager.destructible_tilemap = self

func destroy_tile(target: Vector2i, bomb_range: int) -> void:
	erase_cell(target)
	for i in range(1, bomb_range + 1):
		erase_cell(target + Vector2i(i,0))
		erase_cell(target + Vector2i(-i,0))
		erase_cell(target + Vector2i(0,i))
		erase_cell(target + Vector2i(0,-i))

func spawn_tile(target: Vector2i) -> void:
	#set_cell(target,)
	pass
