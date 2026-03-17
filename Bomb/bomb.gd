extends Sprite2D
class_name Bomb

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@export var radius: int = 1
@export var speed: float = 40
@export var tile_size: int = 4

var moving := false
var direction := Vector2.ZERO
var target_position := Vector2.ZERO
var tilemap = TileManager.destructible_tilemap

func _ready():
	add_to_group("bombs")
	
func activate_bomb() -> void:
	animationPlayer.play("bomb_detonation")

func activate_explosion() -> void:
	snap_to_grid()
	var tile_pos = tilemap.local_to_map(global_position)
	tilemap.destroy_tile(tile_pos, radius)
	queue_free()

func _physics_process(delta: float) -> void:
	if moving:
		position = position.move_toward(target_position, speed * delta)
		if position.distance_to(target_position) < 0.1:
			position = target_position
			var next_pos = position + direction * tile_size
			if TileManager.is_tile_free(next_pos):
				target_position = next_pos
			else:
				moving = false

func push(dir: Vector2):
	if moving:
		return
	direction = dir
	var next_pos = global_position + direction * tile_size
	if TileManager.is_tile_free(next_pos):
		target_position = next_pos
		moving = true
	
func snap_to_grid():
	global_position.x = floor(global_position.x / tile_size) * tile_size + tile_size * 0.5
	global_position.y = floor(global_position.y / tile_size) * tile_size + tile_size * 0.5
