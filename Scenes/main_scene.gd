extends Node2D

func _ready():
	TileManager.background_tilemap = $BackgroundTile
	TileManager.destructible_tilemap = $DestructibleTile


func _on_spawn_tile_timer_timeout():
	#TileManager.spawn_tile(Vector2(10,10),Vector2(1,0))
	pass
