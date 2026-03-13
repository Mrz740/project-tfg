extends Sprite2D
class_name Bomb

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@export var radius: int

func activate_bomb() -> void:
	animationPlayer.play("bomb_detonation")


func activate_explosion() -> void:
	var tilemap = TileManager.destructible_tilemap
	var tile_pos = tilemap.local_to_map(global_position)
	tilemap.destroy_tile(tile_pos, radius)
	
	queue_free()
