extends Sprite2D

const TILE_SIZE := 4
const SPEED := 16

const UP := Vector2(0,-1)
const DOWN := Vector2(0,1)
const LEFT := Vector2(-1,0)
const RIGHT := Vector2(1,0)

const MOVE_DELAY := 0.08 

@onready var bombTimer : Timer = $BombCooldown
@onready var bomb :Resource = preload("res://Bomb/Bomb.tscn")

var moving := false
var target_position := Vector2.ZERO
var bomb_ready : bool = true

var hold_time := 0.0
var current_dir := Vector2.ZERO



func _physics_process(delta):

	if moving:
		position = position.move_toward(target_position, SPEED * delta)

		if position.distance_to(target_position) < 0.1:
			position = target_position

			var dir = get_input_direction()

			if dir != Vector2.ZERO and check_collision(dir):
				target_position = position + dir * TILE_SIZE
			else:
				moving = false

	else:
		var dir = get_input_direction()

		if dir != Vector2.ZERO and check_collision(dir):
			moving = true
			target_position = position + dir * TILE_SIZE
				
				
func get_input_direction() -> Vector2:

	if Input.is_action_pressed("move_right"):
		frame = 1
		return RIGHT
	elif Input.is_action_pressed("move_left"):
		frame = 0
		return LEFT
	elif Input.is_action_pressed("move_down"):
		frame = 2
		return DOWN
	elif Input.is_action_pressed("move_up"):
		frame = 3
		return UP

	return Vector2.ZERO


func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("drop_bomb") and bomb_ready:
		drop_bomb()
		

func check_collision(target: Vector2) -> bool:
	var next_pos = global_position + target * TILE_SIZE
	for bomb in get_parent().get_children():
		if bomb is Bomb and bomb.global_position.distance_to(next_pos) < TILE_SIZE / 2:
			bomb.push(target, TileManager.destructible_tilemap)
			return true
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position,
		next_pos
	)
	query.exclude = [self]
	query.set_collide_with_areas(false)
	query.set_collide_with_bodies(true)
	var result: Dictionary = space_state.intersect_ray(query)
	return result.is_empty()


func _on_timer_timeout() -> void:
	bomb_ready = true


func drop_bomb() -> void:
	var bombInst: Bomb = bomb.instantiate()
	get_parent().add_child(bombInst)

	var pos = global_position
	pos.x = floor(pos.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2
	pos.y = floor(pos.y / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2

	bombInst.global_position = pos
	bombInst.activate_bomb()

	bomb_ready = false
	bombTimer.start()


func check_pickup() -> bool:
	return true
