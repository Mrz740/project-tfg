extends Node

var background_tilemap: TileMapLayer = null  # stores reference
var destructible_tilemap: TileMapLayer = null  # stores reference

@export var tile_size: int = 4

func is_tile_free(pos: Vector2) -> bool:
	var local_pos = background_tilemap.to_local(pos)
	var tile = background_tilemap.local_to_map(local_pos)
	if background_tilemap.get_cell_tile_data(tile) != null:
		return false

	local_pos = destructible_tilemap.to_local(pos)
	tile = destructible_tilemap.local_to_map(local_pos)
	if destructible_tilemap.get_cell_tile_data(tile) != null:
		return false

	for bomb_inst in get_tree().get_nodes_in_group("bombs"):
		if bomb_inst.global_position.distance_to(pos) < tile_size / 2:
			return false

	return true
