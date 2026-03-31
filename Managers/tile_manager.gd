extends Node

var background_tilemap: TileMapLayer = null
var destructible_tilemap: TileMapLayer = null
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


func is_explosion_blocked(pos: Vector2) -> bool:
	var local_pos = background_tilemap.to_local(pos)
	var tile = background_tilemap.local_to_map(local_pos)
	return background_tilemap.get_cell_tile_data(tile) != null


func destroy_tile_at(tile_coords: Vector2i, dir: Vector2) -> bool:
	
	if destructible_tilemap.get_cell_tile_data(tile_coords) != null:
		destructible_tilemap.erase_cell(tile_coords)

		return true

	var local_pos = destructible_tilemap.map_to_local(tile_coords)
	var world_pos = destructible_tilemap.to_global(local_pos)

	for bomb in get_tree().get_nodes_in_group("bombs"):
		if bomb.global_position.distance_to(world_pos) < tile_size * 0.5:
			if dir != Vector2.ZERO:
				bomb.push(dir)
	return false


func tile_to_world(tile_coords: Vector2i) -> Vector2:
	return destructible_tilemap.map_to_local(tile_coords) + Vector2(tile_size/2, tile_size/2)


func get_snapped(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / tile_size) * tile_size + tile_size * 0.5,
		floor(pos.y / tile_size) * tile_size + tile_size * 0.5
	)


func spawn_tile(target: Vector2i, atlas_coords: Vector2) -> void:
	destructible_tilemap.set_cell(target, 2, atlas_coords)
