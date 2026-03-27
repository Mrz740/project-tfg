extends Sprite2D
class_name Player

const SPEED := 32
const UP := Vector2(0,-1)
const DOWN := Vector2(0,1)
const LEFT := Vector2(-1,0)
const RIGHT := Vector2(1,0)

@onready var bombTimer: Timer = $BombCooldown
@onready var bomb_scene: PackedScene = preload("res://Bomb/Bomb.tscn")

@export var player_id := 1
@export var max_hp := 3

var moving: bool = false
var target_position: Vector2 = Vector2.ZERO
var bomb_ready: bool = true
var input_stack := []
var current_hp: int = max_hp

func _init():
	current_hp = max_hp

func _ready():
	add_to_group("players")

func _physics_process(delta: float):
	update_input_stack()
	var dir = Vector2.ZERO
	if input_stack.size() > 0:
		dir = input_stack[input_stack.size() - 1][1]

	# Movement
	if moving:
		global_position = global_position.move_toward(target_position, SPEED * delta)
		if global_position.distance_to(target_position) < 0.1:
			global_position = target_position
			if dir != Vector2.ZERO and check_collision(dir):
				target_position = global_position + dir * TileManager.tile_size
				set_sprite_frame(dir)
			else:
				moving = false
	else:
		if dir != Vector2.ZERO and check_collision(dir):
			moving = true
			target_position = global_position + dir * TileManager.tile_size
			set_sprite_frame(dir)

func set_sprite_frame(dir: Vector2) -> void:
	if dir == RIGHT:
		frame = 1
	elif dir == LEFT:
		frame = 0
	elif dir == DOWN:
		frame = 2
	elif dir == UP:
		frame = 3

func update_input_stack():
	var directions = {
		"p" + str(player_id) + "_right": RIGHT,
		"p" + str(player_id) + "_left": LEFT,
		"p" + str(player_id) + "_up": UP,
		"p" + str(player_id) + "_down": DOWN
	}
	for i in range(input_stack.size() - 1, -1, -1):
		if not Input.is_action_pressed(input_stack[i][0]):
			input_stack.remove_at(i)
	for action_name in directions.keys():
		if Input.is_action_just_pressed(action_name):
			input_stack.append([action_name, directions[action_name]])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p" + str(player_id) + "_bomb") and bomb_ready:
		drop_bomb()

func check_collision(dir: Vector2) -> bool:
	var next_pos = global_position + dir * TileManager.tile_size

	# Bomb collision
	for bomb in get_tree().get_nodes_in_group("bombs"):
		if bomb.global_position.distance_to(next_pos) < TileManager.tile_size * 0.75:
			# Push bomb in direction if possible
			if bomb.can_be_pushed(dir):
				bomb.push(dir)
				return true
			else:
				return false

	# Tile collision
	return TileManager.is_tile_free(next_pos)

func drop_bomb() -> void:
	var bombInst: Bomb = bomb_scene.instantiate()
	get_parent().add_child(bombInst)
	bombInst.global_position = snap_to_grid(global_position)
	bombInst.activate_bomb()
	bomb_ready = false
	bombTimer.start()

func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5,
		floor(pos.y / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5
	)

func _on_timer_timeout() -> void:
	bomb_ready = true

func take_damage(damage: int) -> void:
	current_hp -= damage
	if current_hp <= 0:
		die()

func die() -> void:
	visible = false
	remove_from_group("players")
