extends Sprite2D

const TILE_SIZE := 4
const SPEED := 20

const UP := Vector2(0,-1)
const DOWN := Vector2(0,1)
const LEFT := Vector2(-1,0)
const RIGHT := Vector2(1,0)

@onready var bombTimer : Timer = $BombCooldown
@onready var bomb :Resource = preload("res://Bomb/Bomb.tscn")

var moving := false
var target_position := Vector2.ZERO
var bomb_ready : bool = true


func _physics_process(delta):

	if moving:
		position = position.move_toward(target_position, SPEED * delta)

		if position.distance_to(target_position) < 0.1:
			position = target_position
			moving = false

	else:
		var dir = get_input_direction()

		if check_collision(dir,delta):
			moving = true
			target_position = position + dir * TILE_SIZE


func get_input_direction() -> Vector2:

	if Input.is_action_pressed("move_right"):
		frame = 1
		return RIGHT
	if Input.is_action_pressed("move_left"):
		frame = 0
		return LEFT
	if Input.is_action_pressed("move_down"):
		frame = 2
		return DOWN
	if Input.is_action_pressed("move_up"):
		frame = 3
		return UP

	return Vector2.ZERO


func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("drop_bomb") and bomb_ready:
		drop_bomb()
		
func snap_to_grid():
	position.x = round(position.x / 4) * 4
	position.y = round(position.y / 4) * 4
	
func check_collision(target: Vector2, delta: float) -> bool:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	var ray_end = global_position + target * TILE_SIZE	
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position,
		ray_end
	)

	query.exclude = [self]
	query.set_collide_with_areas(false)
	query.set_collide_with_bodies(true)

	var result: Dictionary = space_state.intersect_ray(query)

	return result.is_empty()


func _on_timer_timeout() -> void:
	bomb_ready = true


func drop_bomb() -> void:
	var bombInst : Bomb = bomb.instantiate()

	get_parent().add_child(bombInst)

	bombInst.global_position = global_position
	bombInst.activate_bomb()

	bomb_ready = false
	bombTimer.start()


func check_pickup() -> bool:
	return true
