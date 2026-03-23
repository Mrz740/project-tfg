extends Node2D
class_name Turret

@export var shoot_interval := 2.0
@export var shoot_direction := Vector2.RIGHT
@export var bomb_speed: int = 30
@export var bomb_time: float = 2

@onready var bomb_scene = preload("res://Bomb/Bomb.tscn")

func _ready():
	shoot_loop()

func shoot_loop():
	while true:
		await get_tree().create_timer(shoot_interval).timeout
		shoot()

func shoot():
	var spawn_pos = snap_to_grid(global_position)
	var next_pos = spawn_pos + shoot_direction * TileManager.tile_size

	if not TileManager.is_tile_free(next_pos):
		return

	var bomb = bomb_scene.instantiate()
	get_parent().add_child(bomb)

	bomb.speed = bomb_speed
	bomb.explode_time = bomb_time
	bomb.global_position = spawn_pos
	bomb.activate_bomb()
	bomb.push(shoot_direction)

func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5,
		floor(pos.y / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5
	)
