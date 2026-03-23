extends Sprite2D
class_name Bomb

var speed: float = 30
var radius: int = 2

var moving := false
var direction := Vector2.ZERO
var target_position := Vector2.ZERO

var flash_time := 0.0
var flash_interval := 0.2
var explode_time := 2.0
var elapsed := 0.0
var flashing := false

func _ready():
	add_to_group("bombs")
	visible = false

func activate_bomb():
	visible = true
	flashing = true
	elapsed = 0.0
	flash_time = 0.0
	snap_to_grid()

func activate_explosion():
	var tile_pos = TileManager.destructible_tilemap.local_to_map(global_position)
	TileManager.destroy_tile(tile_pos, radius)
	queue_free()

func _physics_process(delta):
	if flashing:
		elapsed += delta
		flash_time += delta
		scale = Vector2.ONE * (1.0 + sin(elapsed * 20.0) * 0.05)
		if flash_time >= flash_interval:
			flash_time = 0.0
			modulate = Color.RED if modulate == Color.WHITE else Color.WHITE
		if elapsed > explode_time * 0.85:
			flash_interval = 0.05
		elif elapsed > explode_time * 0.6:
			flash_interval = 0.1
		if elapsed >= explode_time:
			activate_explosion()

	if moving:
		global_position = global_position.move_toward(target_position, speed * delta)
		if global_position.distance_to(target_position) < 0.1:
			global_position = target_position
			var next_pos = global_position + direction * TileManager.tile_size
			
			var collides_with_player = false
			for player in get_tree().get_nodes_in_group("players"):
				if player.global_position.distance_to(next_pos) < TileManager.tile_size * 0.5:
					collides_with_player = true
					break
			
			if TileManager.is_tile_free(next_pos) and not collides_with_player:
				target_position = next_pos
			else:
				moving = false
func push(dir: Vector2):
	direction = dir
	var next_pos = global_position + direction * TileManager.tile_size
	if TileManager.is_tile_free(next_pos):
		target_position = next_pos
		moving = true

func snap_to_grid():
	global_position.x = floor(global_position.x / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5
	global_position.y = floor(global_position.y / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5
