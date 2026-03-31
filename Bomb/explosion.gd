extends Sprite2D

@export var tile_delay := 0.05
@export var piece_lifetime := 0.3
@onready var explosion_texture: Texture2D = preload("res://Bomb/explosion.png")

func start(origin: Vector2, radius: int) -> void:
	var center_tile = Vector2i(
		int(origin.x / TileManager.tile_size),
		int(origin.y / TileManager.tile_size)
	)

	spawn_piece(tile_to_world(center_tile))

	var directions = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]

	for dir in directions:
		propagate(center_tile, dir, radius)

	await get_tree().create_timer(piece_lifetime + tile_delay * radius).timeout
	queue_free()


func propagate(origin_tile: Vector2i, dir: Vector2, radius: int) -> void:
	for i in range(1, radius + 1):
		var next_tile = origin_tile + Vector2i(int(dir.x * i), int(dir.y * i))
		var world_pos = tile_to_world(next_tile)

		await get_tree().create_timer(tile_delay).timeout

		spawn_piece(world_pos)
		TileManager.destroy_tile_at(next_tile, dir)
		
		if TileManager.is_explosion_blocked(world_pos):
			break


func spawn_piece(world_pos: Vector2) -> void:
	var sprite = Sprite2D.new()
	sprite.texture = explosion_texture
	sprite.global_position = world_pos
	add_child(sprite)

	sprite.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)

	await get_tree().create_timer(piece_lifetime).timeout
	sprite.queue_free()


func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(
		tile.x * TileManager.tile_size + TileManager.tile_size * 0.5,
		tile.y * TileManager.tile_size + TileManager.tile_size * 0.5
	)
