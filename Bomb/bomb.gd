extends GridEntity
class_name Bomb

@export var radius: int = 2
@export var explode_time: float = 2.0
@export var flash_interval: float = 0.2

var direction: Vector2 = Vector2.ZERO
var flashing: bool = false
var elapsed: float = 0.0
var flash_timer: float = 0.0

func _ready():
	super()
	add_to_group("bombs")
	visible = true
	global_position = get_snapped_position(global_position)

func activate_bomb() -> void:
	visible = true
	flashing = true
	elapsed = 0.0
	flash_timer = 0.0

func push(dir: Vector2) -> void:
	direction = dir
	try_move(dir)

func can_be_pushed(dir: Vector2) -> bool:
	var next_tile = get_snapped_position(global_position) + dir * TileManager.tile_size

	for entity in get_tree().get_nodes_in_group("grid_entities"):
		if entity == self:
			continue

		var check_pos = entity.target_position if entity.moving else entity.global_position

		if get_snapped_position(check_pos) == next_tile:
			if entity.is_in_group("bombs"):
				return entity.can_be_pushed(dir)
			else:
				return false

	return TileManager.is_tile_free(next_tile)
	
func _physics_process(delta: float) -> void:
	flashing_effect(delta)

	if elapsed >= explode_time:
		explode()

	if direction != Vector2.ZERO and not moving:
		if can_be_pushed(direction):
			try_move(direction)
		else:
			direction = Vector2.ZERO

	move_toward_target(delta)

func flashing_effect(delta: float) -> void:
	elapsed += delta
	flash_timer += delta
	if flash_timer >= flash_interval:
		flash_timer = 0.0
		modulate = Color.RED if modulate == Color.WHITE else Color.WHITE
	if elapsed > explode_time * 0.85:
		flash_interval = 0.05
	elif elapsed > explode_time * 0.6:
		flash_interval = 0.1

func explode() -> void:
	global_position = get_snapped_position(global_position)
	var tile_pos = TileManager.destructible_tilemap.local_to_map(global_position)
	TileManager.destroy_tile(tile_pos, radius)
	queue_free()
