extends Sprite2D
class_name GridEntity

@export var speed: float = 32

var moving: bool = false
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	global_position = get_snapped_position(global_position)
	add_to_group("grid_entities")

func get_snapped_position(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5,
		floor(pos.y / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5
	)

func try_move(dir: Vector2) -> bool:
	if moving:
		return false
	if dir == Vector2.ZERO:
		return false

	var next_tile = get_snapped_position(global_position) + dir * TileManager.tile_size
	var hit_entity = null

	for entity in get_tree().get_nodes_in_group("grid_entities"):
		if entity == self:
			continue

		var check_pos = entity.target_position if entity.moving else entity.global_position

		if get_snapped_position(check_pos) == next_tile:
			hit_entity = entity
			break

	if hit_entity != null:
		if self.is_in_group("players") and hit_entity.can_be_pushed(dir):
			hit_entity.push(dir)
		else:
			return false

	if not TileManager.is_tile_free(next_tile):
		return false

	target_position = next_tile
	moving = true
	return true

func move_toward_target(delta: float) -> void:
	if not moving:
		return

	var new_position = global_position.move_toward(target_position, speed * delta)

	global_position = new_position

	if global_position.distance_to(target_position) < 0.1:
		global_position = target_position
		moving = false