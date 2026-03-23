extends Sprite2D

const SPEED := 32
const UP := Vector2(0,-1)
const DOWN := Vector2(0,1)
const LEFT := Vector2(-1,0)
const RIGHT := Vector2(1,0)

@onready var bombTimer: Timer = $BombCooldown
@onready var bomb_scene: PackedScene = preload("res://Bomb/Bomb.tscn")

var moving := false
var target_position := Vector2.ZERO
var bomb_ready := true
var input_stack := []
var max_hp := int(3)
var current_hp := int(3)

func _init():
	current_hp = max_hp
	
func _ready():
	add_to_group("players")
	
func _physics_process(delta):
	update_input_stack()
	var dir = Vector2.ZERO
	if input_stack.size() > 0:
		dir = input_stack[input_stack.size() - 1][1]
	if moving:
		global_position = global_position.move_toward(target_position, SPEED * delta)
		if global_position.distance_to(target_position) < 0.1:
			global_position = target_position
			if dir != Vector2.ZERO and check_collision(dir):
				target_position = global_position + dir * TileManager.tile_size
				if dir == RIGHT:
					frame = 1
				elif dir == LEFT:
					frame = 0
				elif dir == DOWN:
					frame = 2
				elif dir == UP:
					frame = 3
			else:
				moving = false
	else:
		if dir != Vector2.ZERO and check_collision(dir):
			moving = true
			target_position = global_position + dir * TileManager.tile_size
			if dir == RIGHT:
				frame = 1
			elif dir == LEFT:
				frame = 0
			elif dir == DOWN:
				frame = 2
			elif dir == UP:
				frame = 3

func update_input_stack():
	var directions = {"move_right": RIGHT, "move_left": LEFT, "move_up": UP, "move_down": DOWN}
	for i in range(input_stack.size() - 1, -1, -1):
		if not Input.is_action_pressed(input_stack[i][0]):
			input_stack.remove_at(i)
	for action_name in directions.keys():
		if Input.is_action_just_pressed(action_name):
			input_stack.append([action_name, directions[action_name]])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_bomb") and bomb_ready:
		drop_bomb()

func check_collision(target: Vector2) -> bool:
	var next_pos = global_position + target * TileManager.tile_size
	for bomb_inst in get_tree().get_nodes_in_group("bombs"):
		if bomb_inst.global_position.distance_squared_to(next_pos) < (TileManager.tile_size * TileManager.tile_size) / 4:
			if not bomb_inst.moving:
				bomb_inst.push(target)
			return true
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, next_pos)
	query.exclude = [self]
	query.set_collide_with_areas(false)
	query.set_collide_with_bodies(true)
	return space_state.intersect_ray(query).is_empty()

func _on_timer_timeout() -> void:
	bomb_ready = true

func drop_bomb() -> void:
	var bombInst: Bomb = bomb_scene.instantiate()
	get_parent().add_child(bombInst)
	bombInst.global_position = snap_to_grid(global_position)
	bombInst.activate_bomb()
	bomb_ready = false
	bombTimer.start()

func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5, floor(pos.y / TileManager.tile_size) * TileManager.tile_size + TileManager.tile_size * 0.5)

func take_damage(damage: int) -> void:
	current_hp -= damage
	if (current_hp <= 0):
		die()
	#play damage anim + invulnerability
	
func die() -> void:
	pass
