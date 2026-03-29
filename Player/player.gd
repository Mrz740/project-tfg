extends GridEntity
class_name Player

const UP := Vector2(0,-1)
const DOWN := Vector2(0,1)
const LEFT := Vector2(-1,0)
const RIGHT := Vector2(1,0)

@onready var bombTimer: Timer = $BombCooldown
@onready var bomb_scene: PackedScene = preload("res://Bomb/Bomb.tscn")

@export var player_id := 1
@export var max_hp := 3

var bomb_ready: bool = true
var input_stack := []
var current_hp: int = max_hp

func _init():
	current_hp = max_hp
	speed = 32

func _ready() -> void:
	super()
	add_to_group("players")

func _physics_process(delta: float) -> void:
	var dir = Vector2.ZERO

	if input_stack.size() > 0:
		dir = input_stack[input_stack.size() - 1][1]

	if dir != Vector2.ZERO:
		set_sprite_frame(dir) 
		try_move(dir)         

	move_toward_target(delta)

func set_sprite_frame(dir: Vector2) -> void:
	if dir == RIGHT:
		frame = 1
	elif dir == LEFT:
		frame = 0
	elif dir == DOWN:
		frame = 2
	elif dir == UP:
		frame = 3

func _input(event: InputEvent) -> void:
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

	if event.is_action_pressed("p" + str(player_id) + "_bomb") and bomb_ready:
		drop_bomb()

func drop_bomb() -> void:
	var bombInst: Bomb = bomb_scene.instantiate()
	get_parent().add_child(bombInst)
	bombInst.global_position = get_snapped_position(global_position)
	bombInst.activate_bomb()
	bomb_ready = false
	bombTimer.start()

func _on_timer_timeout() -> void:
	bomb_ready = true

func take_damage(damage: int) -> void:
	current_hp -= damage
	if current_hp <= 0:
		die()

func die() -> void:
	visible = false
	remove_from_group("players")
