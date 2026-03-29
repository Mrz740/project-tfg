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

	return true
	
func destroy_tile(origin: Vector2i, bomb_range: int) -> void:
	_apply_explosion(origin, Vector2.ZERO)

	for i in range(1, bomb_range + 1):
		_apply_explosion(origin + Vector2i(i, 0), Vector2.RIGHT)
		_apply_explosion(origin + Vector2i(-i, 0), Vector2.LEFT)
		_apply_explosion(origin + Vector2i(0, i), Vector2.DOWN)
		_apply_explosion(origin + Vector2i(0, -i), Vector2.UP)
		
func _apply_explosion(tile_pos: Vector2i, dir: Vector2) -> void:
	destructible_tilemap.erase_cell(tile_pos)

	var world_pos = destructible_tilemap.map_to_local(tile_pos)

	for bomb in get_tree().get_nodes_in_group("bombs"):
		if bomb.global_position.distance_to(world_pos) < tile_size * 0.5:
			if dir != Vector2.ZERO:
				bomb.push(dir)
				
func spawn_tile(target: Vector2i, atlas_coords: Vector2) -> void:
	destructible_tilemap.set_cell(target,2,atlas_coords)
	
