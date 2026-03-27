extends Sprite2D
class_name Bomb

@export var speed: float = 30
@export var radius: int = 2
@export var explode_time: float = 2.0
@export var flash_interval: float = 0.2

var moving: bool = false
var direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

var flashing: bool = false
var elapsed: float = 0.0
var flash_timer: float = 0.0

func _ready():
	add_to_group("bombs")
	visible = false

func activate_bomb() -> void:
	visible = true
	flashing = true
	elapsed = 0.0
	flash_timer = 0.0

func push(dir: Vector2) -> void:
	direction = dir
	var next_pos = global_position + dir * TileManager.tile_size
	if TileManager.is_tile_free(next_pos):
		target_position = next_pos
		moving = true
	else:
		moving = false

func can_be_pushed(dir: Vector2) -> bool:
	var next_pos = global_position + dir * TileManager.tile_size
	return TileManager.is_tile_free(next_pos)

func _physics_process(delta: float) -> void:
	if flashing:
		elapsed += delta
		flash_timer += delta
		scale = Vector2.ONE * (1.0 + sin(elapsed * 20.0) * 0.05)
		if flash_timer >= flash_interval:
			flash_timer = 0.0
			modulate = Color.RED if modulate == Color.WHITE else Color.WHITE
		if elapsed > explode_time * 0.85:
			flash_interval = 0.05
		elif elapsed > explode_time * 0.6:
			flash_interval = 0.1
		if elapsed >= explode_time:
			explode()

	if moving:
		position = position.move_toward(target_position, speed * delta)
		if position.distance_to(target_position) < 0.1:
			position = target_position
			var next_pos = position + direction * TileManager.tile_size
			if TileManager.is_tile_free(next_pos):
				target_position = next_pos
			else:
				moving = false

func explode() -> void:
	snap_to_grid()
	var tile_pos = TileManager.destructible_tilemap.local_to_map(global_position)
	TileManager.destroy_tile(tile_pos, radius)
	queue_free()

func snap_to_grid() -> void:
	global_position.x = floor(global_position.x / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5
	global_position.y = floor(global_position.y / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5
	moving = false
