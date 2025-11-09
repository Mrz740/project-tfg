extends Node2D

class_name MainLevel

@onready var tilemap : TileMapLayer = $TileMapLayer/BlockLayer

func destroyTiles(location: Vector2, radius: int) -> void:
	location = Vector2(location.x- 0.5,location.y - 0.5)
	
	while radius != 0:
		tilemap.erase_cell(Vector2(location.x - radius,location.y))
		tilemap.erase_cell(Vector2(location.x,location.y - radius))
		tilemap.erase_cell(Vector2(location.x + radius,location.y))
		tilemap.erase_cell(Vector2(location.x,location.y + radius))
		radius -= 1
